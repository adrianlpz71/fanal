import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/api.dart';
import '../../core/money.dart';
import '../../core/offline.dart';
import '../../core/forms/forms.dart';
import '../../core/widgets.dart';
import 'data.dart';
import 'people_page.dart';

/// Añadir gasto en < 5 s: teclado numérico primero, concepto con autocompletado (sugiere
/// categoría e importe del historial) y guardar. Lo demás es opcional y va plegado.
/// `month` (AAAA-MM): ciclo futuro al que va el gasto (o en el que está, si se edita uno de un mes
/// futuro). `null` = el ciclo actual.
Future<void> showMovementSheet(BuildContext context, WidgetRef ref, {MovementOut? existing, String? month}) =>
    showFormPanel(context, builder: (_) => _MovementSheet(existing: existing, month: month));

class _MovementSheet extends ConsumerStatefulWidget {
  const _MovementSheet({this.existing, this.month});
  final MovementOut? existing;
  final String? month;

  @override
  ConsumerState<_MovementSheet> createState() => _MovementSheetState();
}

class _MovementSheetState extends ConsumerState<_MovementSheet> {
  String _digits = ''; // lo tecleado, con coma decimal
  bool _income = false; // en un traspaso: true = el dinero vuelve a la cuenta de gastos
  bool _transfer = false; // traspaso entre tus cuentas (no es gasto ni ingreso)
  String? _toAccount;
  final _concept = TextEditingController();
  final _notes = TextEditingController();
  final _expr = TextEditingController();
  final _amountText = TextEditingController(); // pantallas anchas
  String? _categoryId;
  bool _planned = false;
  DateTime? _date;
  String? _month; // null = ciclo actual
  bool _more = false;
  bool _busy = false;
  String? _error;
  List<SuggestionOut> _suggestions = const [];
  Timer? _debounce;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _month = widget.month;
    final m = widget.existing;
    if (m != null) {
      final a = dec(m.amount);
      _income = a.sign > 0;
      _transfer = m.kind == MovementOutKindEnum.transferencia;
      _digits = (a.sign < 0 ? -a : a).toStringAsFixed(2).replaceAll('.', ',');
      _amountText.text = _digits;
      _concept.text = m.concept;
      _notes.text = m.notes ?? '';
      _expr.text = m.expression ?? '';
      _categoryId = m.categoryId;
      _planned = m.status == MovementOutStatusEnum.planned;
      // En un previsto, la fecha del formulario es la prevista; en un cargado, la de cargo
      _date = _planned || widget.month != null ? (m.dueDate ?? m.date) : m.date;
      _more = m.expression != null || (m.notes ?? '').isNotEmpty;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _concept.dispose();
    _notes.dispose();
    _expr.dispose();
    _amountText.dispose();
    super.dispose();
  }

  Decimal? get _amount {
    final v = parseEsDecimal(_digits);
    if (v == null || v == Decimal.zero) return null;
    return _income ? v : -v;
  }

  void _key(String k) {
    HapticFeedback.selectionClick();
    setState(() {
      if (k == '⌫') {
        if (_digits.isNotEmpty) _digits = _digits.substring(0, _digits.length - 1);
      } else if (k == ',') {
        if (!_digits.contains(',')) _digits = _digits.isEmpty ? '0,' : '$_digits,';
      } else {
        final dec = _digits.split(',');
        if (dec.length == 2 && dec[1].length >= 2) return; // máx. 2 decimales
        if (_digits.replaceAll(',', '').length >= 9) return;
        _digits = _digits == '0' ? k : '$_digits$k';
      }
    });
  }

  void _onConcept(String q) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 220), () async {
      if (q.trim().isEmpty) {
        setState(() => _suggestions = const []);
        return;
      }
      try {
        final r = await ref.read(apiProvider).getGastosApi().suggest(q: q.trim());
        if (mounted) setState(() => _suggestions = r.data ?? const []);
      } catch (_) {}
    });
  }

  void _pick(SuggestionOut s) {
    setState(() {
      _concept.text = s.concept;
      _concept.selection = TextSelection.collapsed(offset: s.concept.length);
      _categoryId = s.categoryId ?? _categoryId;
      if (s.amount != null && _digits.isEmpty) {
        final a = dec(s.amount);
        _income = a.sign > 0;
        _digits = (a.sign < 0 ? -a : a).toStringAsFixed(2).replaceAll('.', ',');
        _amountText.text = _digits;
      }
      _suggestions = const [];
    });
  }

  Future<void> _save() async {
    final expr = _expr.text.trim();
    if (_transfer && !_editing && _toAccount == null) return setState(() => _error = 'Elige la cuenta');
    if (_concept.text.trim().isEmpty) return setState(() => _error = 'Pon un concepto');
    if (expr.isEmpty && _amount == null) return setState(() => _error = 'Introduce el importe');
    setState(() {
      _busy = true;
      _error = null;
    });
    final api = ref.read(apiProvider).getGastosApi();
    final future = _month != null;
    try {
      if (_editing) {
        final moved = _month != widget.month;
        await api.patchMovement(
          movementId: widget.existing!.id,
          movementPatch: MovementPatch(
            concept: _concept.text.trim(),
            amount: expr.isEmpty ? apiAmount(_amount!) : null,
            expression: expr.isEmpty ? null : expr,
            categoryId: _categoryId,
            status: future || _planned ? MovementPatchStatusEnum.planned : MovementPatchStatusEnum.posted,
            // Previsto: la fecha es la prevista (due_date); cargado: la de cargo
            date: future || _planned ? null : _date,
            dueDate: future || _planned ? _date : null,
            month: moved ? (_month ?? _currentYm()) : null,
            notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
          ),
        );
      } else {
        final now = DateTime.now();
        final body = MovementIn(
          // UUID del cliente: si se reenvía (p. ej. desde la cola sin conexión) no se duplica
          id: const Uuid().v7(),
          concept: _concept.text.trim(),
          amount: expr.isEmpty ? apiAmount(_amount!) : null,
          expression: expr.isEmpty ? null : expr,
          kind: _transfer
              ? MovementInKindEnum.transferencia
              : (_income ? MovementInKindEnum.ingreso : MovementInKindEnum.gasto),
          toAccountId: _transfer ? _toAccount : null,
          status: future || _planned ? MovementInStatusEnum.planned : MovementInStatusEnum.posted,
          categoryId: _categoryId,
          // La fecha va explícita: si sale más tarde desde la cola, conserva el día real
          date: future || _planned ? null : (_date ?? DateTime.utc(now.year, now.month, now.day)),
          dueDate: future || _planned ? _date : null,
          month: _month,
          notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
        );
        try {
          await api.createMovement(movementIn: body);
        } catch (e) {
          if (!isNetworkError(e)) rethrow;
          await ref.read(pendingMovementsProvider.notifier).enqueue(body);
          if (mounted) {
            Navigator.pop(context);
            showSnack(context, 'Sin conexión: se enviará solo cuando vuelva la red');
          }
          return;
        }
      }
      refreshGastos(ref);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Se puede elegir mes al crear y en previstos (no en cuotas: van con su plan).
  bool get _canChangeMonth {
    final m = widget.existing;
    if (m == null) return true;
    return m.status == MovementOutStatusEnum.planned && m.source_ != 'installment';
  }

  String _currentYm() {
    final ahead = ref.read(monthsAheadProvider).value?.months;
    if (ahead == null || ahead.isEmpty) {
      final now = DateTime.now();
      return '${now.year}-${now.month.toString().padLeft(2, '0')}';
    }
    return prevYm(ahead.first.ym);
  }

  ForecastMonthOut? _futureMonth(List<ForecastMonthOut> ahead) =>
      _month == null ? null : ahead.where((m) => m.ym == _month).firstOrNull;

  void _setMonth(String picked) => setState(() {
        _month = picked.isEmpty ? null : picked;
        _date = null; // la fecha anterior seguramente cae fuera del nuevo mes
      });

  Future<void> _delete() async {
    final m = widget.existing!;
    final ok = await confirmDialog(context, title: '¿Eliminar movimiento?', message: '${m.concept} · ${eur(m.amount)}');
    if (!ok) return;
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider).getGastosApi().deleteMovement(movementId: m.id);
      refreshGastos(ref);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _duplicate() async {
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider).getGastosApi().duplicateMovement(movementId: widget.existing!.id);
      refreshGastos(ref);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final compact = context.isCompact;
    final cats = ref.watch(categoriesProvider).value ?? const [];
    final idx = CategoryIndex(cats);
    final shown = _digits.isEmpty ? '0' : _digits;
    final pickable = cats.where((c) => !c.archived && (c.parentId != null ||
        !cats.any((x) => x.parentId == c.id))).toList();
    final ahead = ref.watch(monthsAheadProvider).value?.months ?? const <ForecastMonthOut>[];
    final current = ref.watch(currentCycleProvider).value?.label ?? 'Este ciclo';
    final planned = _planned || _month != null;
    final fm = _futureMonth(ahead);

    return FormPanel(
      title: _editing ? 'Editar movimiento' : 'Nuevo movimiento',
      onSubmit: _busy ? null : _save,
      // Tipo: gasto, ingreso o traspaso entre tus cuentas (un traspaso ya hecho no cambia de tipo)
      header: SegmentedField<String>(
        buttonKey: const Key('movement-kind'),
        segments: const [
          Segment('gasto', 'Gasto', icon: Icons.remove),
          Segment('ingreso', 'Ingreso', icon: Icons.add),
          Segment('traspaso', 'Traspaso', icon: Icons.swap_horiz),
        ],
        value: _transfer ? 'traspaso' : (_income ? 'ingreso' : 'gasto'),
        onChanged: _editing && (_transfer || widget.existing!.kind == MovementOutKindEnum.transferencia)
            ? null
            : (v) => setState(() {
                  _transfer = v == 'traspaso';
                  _income = v == 'ingreso';
                }),
      ),
      // En el móvil, el teclado propio (con Guardar) queda fijo abajo; en pantallas anchas, botones.
      actions: compact
          ? _Keypad(onKey: _key, onSave: _busy ? null : _save, saveLabel: _editing ? 'Guardar' : 'Añadir')
          : FormActions(
              primaryKey: const Key('save-movement'),
              primaryLabel: _editing ? 'Guardar' : 'Añadir',
              busy: _busy,
              onPrimary: _save,
            ),
      children: [
        // Importe primero (solo se reduce si no cabe; nunca se amplía)
        if (compact)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '${_income ? '+' : '−'}$shown$nbsp€',
              key: const Key('amount-display'),
              textAlign: TextAlign.center,
              style: tt.displaySmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontFeatures: FaroText.tabular,
                color: _income && !_transfer ? context.faro.gain : null,
              ),
            ),
          )
        else
          MoneyField(
            key: const Key('amount-field'),
            controller: _amountText,
            autofocus: !_editing,
            label: _transfer ? 'Importe del traspaso' : (_income ? 'Importe del ingreso' : 'Importe del gasto'),
            style: tt.headlineSmall?.copyWith(fontFeatures: FaroText.tabular),
            onChanged: (v) => setState(() => _digits = v.replaceAll('.', ',').replaceAll('-', '')),
          ),
        if (_transfer && !_editing)
          _TransferTarget(
            value: _toAccount,
            back: _income,
            onAccount: (a) => setState(() {
              _toAccount = a.id;
              if (_concept.text.trim().isEmpty) _concept.text = '${_income ? 'Desde' : 'A'} ${a.name}';
              _categoryId ??= _transferCategory(cats, a);
            }),
            onBack: (v) => setState(() => _income = v),
          ),
        // Concepto con autocompletado
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          FaroTextField(
            key: const Key('concept-field'),
            controller: _concept,
            label: 'Concepto',
            autofocus: !_editing && compact,
            textCapitalization: TextCapitalization.sentences,
            onChanged: _onConcept,
          ),
          for (final s in _suggestions.take(4))
            ListTile(
              dense: true,
              leading: Icon(idx.icon(s.categoryId), color: idx.color(s.categoryId)),
              title: Text(s.concept),
              subtitle: Text(idx.label(s.categoryId)),
              trailing: s.amount == null ? null : Text(eur(s.amount)),
              onTap: () => _pick(s),
            ),
        ]),
        FieldRow(minWidth: 220, children: [
          SelectField<String?>(
            key: const Key('category-field'),
            label: 'Categoría',
            value: _categoryId,
            emptyText: 'Sin categoría',
            options: [
              for (final c in pickable)
                SelectOption<String?>(c.id, idx.label(c.id), icon: idx.icon(c.id), iconColor: idx.color(c.id)),
            ],
            onChanged: (id) => setState(() => _categoryId = id),
          ),
          if (_canChangeMonth)
            SelectField<String>(
              key: const Key('month-chip'),
              label: 'Mes',
              value: _month ?? '',
              options: [
                SelectOption('', '$current (actual)'),
                for (final m in ahead)
                  SelectOption(m.ym, m.label, subtitle: 'Del ${shortDate(m.start)} al ${shortDate(m.end)}'),
              ],
              helper: 'En un mes futuro queda como previsto y suma en su ciclo',
              onChanged: _setMonth,
            ),
        ]),
        SwitchField(
          key: const Key('planned-switch'),
          title: 'Pendiente (aún no se ha cargado)',
          subtitle: _month != null ? 'En un mes futuro siempre queda como previsto' : null,
          value: planned,
          onChanged: _month != null ? null : (v) => setState(() => _planned = v),
        ),
        DateField(
          key: const Key('date-field'),
          label: planned ? 'Fecha prevista' : 'Fecha de cargo',
          value: _date,
          emptyText: _month != null ? 'Al empezar el mes' : (planned ? 'Sin fecha' : 'Hoy'),
          first: fm?.start ?? DateTime(2020),
          last: fm?.end ?? DateTime(2100),
          clearable: true,
          onChanged: (d) => setState(() => _date = d),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            icon: Icon(_more ? Icons.expand_less : Icons.expand_more),
            onPressed: () => setState(() => _more = !_more),
            label: Text(_more ? 'Menos opciones' : 'Más opciones'),
          ),
        ),
        if (_more) ...[
          FaroTextField(
            controller: _expr,
            label: 'Varias líneas (opcional)',
            helper: 'Ej. =-60+20+12 (pagas la cena y te devuelven su parte)',
          ),
          FaroTextField(controller: _notes, label: 'Notas', maxLines: 3, minLines: 1),
        ],
        if (_error != null) ErrorText(_error),
        if (_editing)
          Wrap(spacing: 4, children: [
            TextButton.icon(
              key: const Key('delete-movement'),
              icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
              label: Text('Eliminar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: _busy ? null : _delete,
            ),
            TextButton.icon(
              icon: const Icon(Icons.copy_outlined),
              label: const Text('Duplicar'),
              onPressed: _busy ? null : _duplicate,
            ),
            TextButton.icon(
              key: const Key('share-movement'),
              icon: const Icon(Icons.group_outlined),
              label: const Text('Repartir'),
              onPressed: _busy
                  ? null
                  : () async {
                      final m = widget.existing!;
                      Navigator.pop(context);
                      await showSharesEditor(context, ref, m);
                    },
            ),
          ]),
        if (_editing && widget.existing!.shares.isNotEmpty)
          Wrap(spacing: 6, children: [
            for (final s in widget.existing!.shares)
              Chip(
                avatar: Icon(
                    s.direction == ShareBriefOutDirectionEnum.meDeben ? Icons.call_received : Icons.call_made,
                    size: 16),
                label: Text('${s.personName} ${eur(s.amount)}'
                    '${s.status == ShareBriefOutStatusEnum.saldada ? ' ✓' : ''}'),
              ),
          ]),
      ],
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey, required this.onSave, required this.saveLabel});
  final void Function(String) onKey;
  final VoidCallback? onSave;
  final String saveLabel;

  static const _rows = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    [',', '0', '⌫'],
  ];
  static const _keyH = 48.0;
  static const _gap = 6.0;

  @override
  Widget build(BuildContext context) {
    // Altura fija: un Row "stretch" dentro de un scroll no tiene altura propia.
    const height = _keyH * 4 + _gap * 3;
    return SizedBox(
      height: height,
      child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
          flex: 3,
          child: Column(children: [
            for (final (i, row) in _rows.indexed) ...[
              if (i > 0) const SizedBox(height: _gap),
              SizedBox(
                height: _keyH,
                child: Row(children: [
                  for (final (j, k) in row.indexed) ...[
                    if (j > 0) const SizedBox(width: _gap),
                    Expanded(
                      child: FilledButton.tonal(
                        key: Key('key-$k'),
                        style: FilledButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () => onKey(k),
                        child: Text(k, style: Theme.of(context).textTheme.titleLarge),
                      ),
                    ),
                  ],
                ]),
              ),
            ],
          ]),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: FilledButton(
            key: const Key('save-movement'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: onSave,
            child: Text(saveLabel),
          ),
        ),
      ]),
    );
  }
}

/// Categoría de transferencia según la cuenta de destino (refugio, inversión u otra).
String? _transferCategory(List<CategoryOut> cats, AccountOut a) {
  final name = switch (a.kind.value) {
    'refugio' => 'A refugio',
    'inversion' => 'A inversión',
    _ => 'Entre cuentas',
  };
  return cats.where((c) => c.name == name && c.parentId != null && !c.archived).firstOrNull?.id;
}

/// Traspaso: a qué cuenta va (o de cuál vuelve) el dinero de la cuenta de gastos.
class _TransferTarget extends ConsumerWidget {
  const _TransferTarget({required this.value, required this.back, required this.onAccount, required this.onBack});
  final String? value;
  final bool back;
  final ValueChanged<AccountOut> onAccount;
  final ValueChanged<bool> onBack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final main = ref.watch(gastosSettingsProvider).value?.mainAccountId;
    final accounts = (ref.watch(accountsProvider).value ?? const <AccountOut>[])
        .where((a) => a.id != main && !a.archived)
        .toList();
    if (accounts.isEmpty) {
      return const Text('No tienes otras cuentas. Añádelas en Gastos → Cuentas (p. ej. tu cuenta de ahorro).');
    }
    final selected = accounts.where((a) => a.id == value).firstOrNull;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 4, children: [
      SelectField<String>(
        key: const Key('transfer-account'),
        label: back ? 'Desde la cuenta' : 'A la cuenta',
        value: value,
        emptyText: 'Elige la cuenta',
        helper: [
          if (selected != null) 'Saldo ahora: ${eur(selected.balance)}',
          'No cuenta como gasto: el dinero pasa de una cuenta tuya a otra',
        ].join('. '),
        options: [for (final a in accounts) SelectOption(a.id, a.name, subtitle: eur(a.balance))],
        onChanged: (id) => onAccount(accounts.firstWhere((a) => a.id == id)),
      ),
      SwitchField(
        title: 'Traer dinero de esa cuenta a la de gastos',
        value: back,
        onChanged: onBack,
      ),
    ]);
  }
}
