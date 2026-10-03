import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/dates.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/offline.dart';
import '../../core/widgets.dart';
import 'data.dart';
import 'movement_sheet.dart';
import 'payday_dialog.dart';
import 'setup_page.dart';

/// Pantalla de inicio: el ciclo de nómina actual (docs/06-rediseno-ui.md §4.1).
class CyclePage extends ConsumerWidget {
  const CyclePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(gastosSettingsProvider);
    return settings.when(
      loading: () => const Scaffold(body: SkeletonPage()),
      error: (e, _) => _ErrorScaffold(apiErrorMessage(e), () => ref.invalidate(gastosSettingsProvider)),
      data: (s) => s.configured ? const _CycleView() : const GastosSetupPage(),
    );
  }
}

/// Tramo del desglose del ciclo (mismos criterios que el resumen del servidor,
/// `domain/cycles.summarize`): al tocarlo, la lista enseña solo esos movimientos.
enum _Bucket { inicial, fijos, variables, cuotas, ahorro }

class _Filters {
  const _Filters({
    this.query = '',
    this.category,
    this.installments = false,
    this.recurring = false,
    this.shared = false,
    this.bucket,
  });
  final String query;
  final String? category;
  final bool installments, recurring, shared;
  final _Bucket? bucket;

  bool get active => query.isNotEmpty || category != null || installments || recurring || shared || bucket != null;

  _Filters copy({
    String? query,
    String? category,
    bool clearCategory = false,
    bool? installments,
    bool? recurring,
    bool? shared,
    _Bucket? bucket,
    bool clearBucket = false,
  }) => _Filters(
    query: query ?? this.query,
    category: clearCategory ? null : (category ?? this.category),
    installments: installments ?? this.installments,
    recurring: recurring ?? this.recurring,
    shared: shared ?? this.shared,
    bucket: clearBucket ? null : (bucket ?? this.bucket),
  );
}

String _norm(String s) => s
    .toLowerCase()
    .replaceAll(RegExp('[áà]'), 'a')
    .replaceAll(RegExp('[éè]'), 'e')
    .replaceAll(RegExp('[íì]'), 'i')
    .replaceAll(RegExp('[óò]'), 'o')
    .replaceAll(RegExp('[úùü]'), 'u');

class _CycleView extends ConsumerStatefulWidget {
  const _CycleView();

  @override
  ConsumerState<_CycleView> createState() => _CycleViewState();
}

class _CycleViewState extends ConsumerState<_CycleView> {
  var _f = const _Filters();
  bool _showFilters = false; // en el móvil, plegados detrás de la lupa
  final _search = TextEditingController();
  final _searchFocus = FocusNode();

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  bool _isFixed(CategoryIndex idx, String? id) {
    final c = idx[id];
    return c != null && (c.fixed || (idx[c.parentId]?.fixed ?? false));
  }

  bool _inBucket(MovementOut m, _Bucket b, CategoryIndex idx) {
    final spend =
        (m.kind == MovementOutKindEnum.gasto || m.kind == MovementOutKindEnum.reembolso) && m.source_ != 'installment';
    return switch (b) {
      _Bucket.inicial => m.kind == MovementOutKindEnum.nomina || m.kind == MovementOutKindEnum.ingreso,
      _Bucket.fijos => spend && _isFixed(idx, m.categoryId),
      _Bucket.variables => spend && !_isFixed(idx, m.categoryId),
      _Bucket.cuotas => m.source_ == 'installment',
      _Bucket.ahorro => m.kind == MovementOutKindEnum.transferencia && dec(m.amount) < Decimal.zero,
    };
  }

  bool _matches(MovementOut m, CategoryIndex idx) {
    final f = _f;
    if (f.query.isNotEmpty && !_norm('${m.concept} ${idx.label(m.categoryId)}').contains(_norm(f.query))) {
      return false;
    }
    if (f.category != null && m.categoryId != f.category && idx[m.categoryId]?.parentId != f.category) return false;
    if (f.installments && m.source_ != 'installment') return false;
    if (f.recurring && m.source_ != 'recurring') return false;
    if (f.shared && m.shares.isEmpty) return false;
    if (f.bucket != null && !_inBucket(m, f.bucket!, idx)) return false;
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final cycle = ref.watch(currentCycleProvider);
    final idx = CategoryIndex(ref.watch(categoriesProvider).value ?? const []);
    final c = cycle.value;

    void add() {
      if (c != null) showMovementSheet(context, ref);
    }

    return Shortcuts(
      // Atajos en web: N = nuevo gasto · / = buscar (no saltan mientras escribes en un campo)
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyN): _NewIntent(),
        SingleActivator(LogicalKeyboardKey.slash): _SearchIntent(),
      },
      child: Actions(
        actions: {
          _NewIntent: _KeyAction<_NewIntent>(add),
          _SearchIntent: _KeyAction<_SearchIntent>(_searchFocus.requestFocus),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            appBar: FaroAppBar(
              title: PageTitle(c?.label ?? 'Gastos'),
              actions: [
                if (context.isCompact)
                  IconButton(
                    key: const Key('toggle-filters'),
                    tooltip: _showFilters ? 'Ocultar búsqueda y filtros' : 'Buscar y filtrar',
                    isSelected: _showFilters || _f.active,
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _showFilters = !_showFilters),
                  ),
                if (c != null)
                  FilledButton.icon(
                    key: const Key('payday'),
                    icon: const Icon(Icons.payments_outlined),
                    label: const Text('He cobrado'),
                    onPressed: () => showPaydayDialog(context, ref, c),
                  ),
              ],
            ),
            floatingActionButton: c == null
                ? null
                : FloatingActionButton.extended(
                    key: const Key('add-movement'),
                    tooltip: 'Añadir gasto (N)',
                    icon: const Icon(Icons.add),
                    label: const Text('Gasto'),
                    onPressed: add,
                  ),
            body: cycle.when(
              loading: () => const SkeletonPage(),
              error: (e, _) => Center(child: Text(apiErrorMessage(e))),
              data: (c) => c == null
                  ? const _NoOpenCycle()
                  : RefreshIndicator(
                      onRefresh: () async => refreshGastos(ref),
                      child: LayoutBuilder(
                        builder: (context, box) {
                          final list = _list(c, idx);
                          if (box.maxWidth < 1000) return list;
                          // Escritorio: lista con ancho legible (concepto e importe cerca) y, al lado,
                          // el panel con el resumen del ciclo
                          final listW = (box.maxWidth - FaroLayout.sidePanel - Space.xl).clamp(
                            500.0,
                            FaroLayout.readable,
                          );
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(width: Space.sm),
                              SizedBox(width: listW, child: list),
                              const SizedBox(width: Space.xl),
                              SizedBox(
                                width: FaroLayout.sidePanel,
                                child: _SidePanel(cycle: c, idx: idx),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _list(CycleDetailOut cycle, CategoryIndex idx) {
    final all = cycle.movements.where((m) => m.status != MovementOutStatusEnum.cancelled).toList();
    final shown = all.where((m) => _matches(m, idx)).toList();
    final pending = shown.where((m) => m.status == MovementOutStatusEnum.planned).toList()
      ..sort((a, b) => (a.dueDate ?? DateTime(2100)).compareTo(b.dueDate ?? DateTime(2100)));
    final posted = shown.where((m) => m.status == MovementOutStatusEnum.posted).toList();
    final dated = posted.where((m) => m.date != null).toList()..sort((a, b) => b.date!.compareTo(a.date!));
    final undated = posted.where((m) => m.date == null).toList();
    final byDay = <DateTime, List<MovementOut>>{};
    for (final m in dated) {
      byDay.putIfAbsent(DateTime(m.date!.year, m.date!.month, m.date!.day), () => []).add(m);
    }
    final pendingTotal = pending.fold(Decimal.zero, (s, m) => s + dec(m.amount));
    final recurring = ref.watch(recurringProvider).value ?? const [];
    final priceAlerts = recurring.where((r) => r.priceChanges.isNotEmpty).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        const _OfflineBanner(),
        _Header(
          cycle: cycle,
          selected: _f.bucket,
          onBucket: (b) => setState(() => _f = b == null ? _f.copy(clearBucket: true) : _f.copy(bucket: b)),
        ),
        _UndoPaydayBanner(cycle: cycle),
        for (final r in priceAlerts) _PriceAlert(r: r),
        if (!context.isCompact || _showFilters || _f.active)
          _FilterBar(
            search: _search,
            focus: _searchFocus,
            filters: _f,
            idx: idx,
            onChanged: (f) => setState(() => _f = f),
          ),
        if (_f.active && shown.isEmpty)
          EmptyState(
            icon: Icons.filter_alt_off_outlined,
            title: 'Nada coincide con los filtros',
            actionLabel: 'Quitar filtros',
            onAction: () => setState(() {
              _search.clear();
              _f = const _Filters();
            }),
          ),
        if (pending.isNotEmpty) ...[
          SectionHeader(
            'Pendientes (${pending.length})',
            trailing: Text(formatEur(pendingTotal, showPlus: true)),
            padding: EdgeInsets.fromLTRB(
              Space.lg,
              Space.lg,
              Space.lg + Space.md + (context.isWide ? ListRow.primaryWidth : 48),
              Space.xs,
            ),
          ),
          for (final m in pending) MovementTile(m: m, idx: idx),
        ],
        if (!_f.active || dated.isNotEmpty) SectionHeader('Cargados (${dated.length + undated.length})'),
        for (final e in byDay.entries) ...[_DayHeader(e.key), for (final m in e.value) MovementTile(m: m, idx: idx)],
        if (undated.isNotEmpty) ...[
          SectionHeader(
            'Sin fecha (${undated.length})',
            action: TextButton.icon(
              key: const Key('date-all'),
              icon: const Icon(Icons.event_outlined, size: 18),
              label: const Text('Poner fecha a todos'),
              onPressed: () => _dateAll(context, ref, undated, cycle),
            ),
          ),
          for (final m in undated) MovementTile(m: m, idx: idx),
        ],
      ],
    );
  }
}

/// "Hoy", "Ayer" o "jue 1 oct".
class _NewIntent extends Intent {
  const _NewIntent();
}

class _SearchIntent extends Intent {
  const _SearchIntent();
}

/// Atajo de teclado que se desactiva mientras se escribe en un campo de texto, para que la tecla
/// llegue al campo.
class _KeyAction<T extends Intent> extends Action<T> {
  _KeyAction(this.run);
  final VoidCallback run;

  static bool _typing() {
    final f = FocusManager.instance.primaryFocus?.context;
    return f != null && (f.widget is EditableText || f.findAncestorWidgetOfExactType<EditableText>() != null);
  }

  @override
  bool isEnabled(T intent) => !_typing();

  @override
  Object? invoke(T intent) {
    run();
    return null;
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.day);
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(day).inDays;
    final label = diff == 0
        ? 'Hoy'
        : diff == 1
        ? 'Ayer'
        : '${weekdaysShortEs[day.weekday - 1]} ${dayMonth(day)}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.lg, Space.md, Space.lg, 0),
      child: Text(label, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

/// Pone la misma fecha de cargo a todos los cargados sin fecha (los que vinieron del Excel).
Future<void> _dateAll(BuildContext context, WidgetRef ref, List<MovementOut> ms, CycleDetailOut c) async {
  final d = await showDatePicker(
    context: context,
    initialDate: c.startDate,
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    helpText: 'Fecha de cargo para los ${ms.length}',
  );
  if (d == null) return;
  final api = ref.read(apiProvider).getGastosApi();
  try {
    for (final m in ms) {
      await api.patchMovement(
        movementId: m.id,
        movementPatch: MovementPatch(date: apiDay(d)),
      );
    }
    refreshGastos(ref);
    if (context.mounted) showSnack(context, 'Fecha puesta a ${ms.length} movimientos');
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.cycle, required this.selected, required this.onBucket});
  final CycleDetailOut cycle;
  final _Bucket? selected;
  final ValueChanged<_Bucket?> onBucket;

  @override
  Widget build(BuildContext context) {
    final s = cycle.summary;
    final f = context.faro;
    final cs = Theme.of(context).colorScheme;
    final rate = s.savingsRate == null ? null : (dec(s.savingsRate) * Decimal.fromInt(100)).round();
    Widget money(String v, Key key) => MoneyText.api(
      v,
      key: key,
      compact: true,
      style: TextStyle(color: dec(v) < Decimal.zero ? f.loss : null),
    );

    // Barra del ciclo: días que han pasado frente a dinero gastado
    final now = DateTime.now();
    final elapsed = DateTime(now.year, now.month, now.day).difference(cycle.startDate).inDays.clamp(0, 400);
    final total = elapsed + (s.daysToPayday ?? 0);
    final timeShare = total > 0 ? elapsed / total : 0.0;
    final opening = dec(s.opening).toDouble();
    final spent = opening - dec(s.availableNow).toDouble();
    final spentShare = opening > 0 ? (spent / opening).clamp(0.0, 1.0) : 0.0;

    double v(String x) => dec(x).toDouble().abs();
    final segments = [
      SummarySegment(id: 'inicial', label: 'Inicial', value: 0, color: cs.outline, text: eur(s.opening)),
      SummarySegment(id: 'fijos', label: 'Fijos', value: v(s.fixedSpend), color: f.series[1], text: eur(s.fixedSpend)),
      SummarySegment(
        id: 'variables',
        label: 'Variables',
        value: v(s.variableSpend),
        color: f.series[2],
        text: eur(s.variableSpend),
      ),
      SummarySegment(
        id: 'cuotas',
        label: 'Cuotas',
        value: v(s.installments),
        color: f.series[3],
        text: eur(s.installments),
      ),
      SummarySegment(
        id: 'ahorro',
        label: 'Ahorro',
        value: v(s.savings),
        color: f.series[0],
        text: '${eur(s.savings)}${rate != null ? ' ($rate %)' : ''}',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.md,
        children: [
          KpiGrid(
            minWidth: 170,
            children: [
              KpiCard(
                label: 'Disponible ahora',
                value: money(s.availableNow, const Key('available-now')),
                emphasis: true,
              ),
              KpiCard(label: 'Previsto fin de ciclo', value: money(s.expectedEnd, const Key('expected-end'))),
              if (!context.isCompact && (s.perDay != null || s.daysToPayday != null))
                KpiCard(
                  label: 'Puedes gastar',
                  valueText: s.perDay == null ? '—' : '${eur(s.perDay)}/día',
                  note: s.daysToPayday == null ? null : '${s.daysToPayday} días hasta la nómina',
                ),
            ],
          ),
          if (context.isCompact && (s.perDay != null || s.daysToPayday != null))
            Text(
              [
                if (s.perDay != null) 'Puedes gastar ${eur(s.perDay)}/día',
                if (s.daysToPayday != null) '${s.daysToPayday} días hasta la nómina',
              ].join(' · '),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
          if (total > 0)
            Semantics(
              label:
                  'Ciclo: ha pasado el ${(timeShare * 100).round()} % del tiempo y se ha gastado el '
                  '${(spentShare * 100).round()} % de lo inicial',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Space.xs,
                children: [
                  _Progress(label: 'Tiempo · día ${elapsed + 1} de $total', value: timeShare, color: cs.outline),
                  _Progress(
                    label: 'Gastado · ${(spentShare * 100).round()} % de lo inicial',
                    value: spentShare,
                    color: spentShare > timeShare + 0.1 ? f.warning : cs.primary,
                  ),
                ],
              ),
            ),
          SummaryBar(
            segments: segments,
            selected: selected?.name,
            onSelect: (id) => onBucket(id == null ? null : _Bucket.values.byName(id)),
          ),
        ],
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.label, required this.value, required this.color});
  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    spacing: Space.md,
    children: [
      SizedBox(width: 210, child: Text(label, style: FaroText.caption(context))),
      Expanded(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: value, minHeight: 6, color: color),
        ),
      ),
    ],
  );
}

/// Búsqueda y filtros (concepto, categoría, cuotas, recurrentes y compartidos).
class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.search,
    required this.focus,
    required this.filters,
    required this.idx,
    required this.onChanged,
  });
  final TextEditingController search;
  final FocusNode focus;
  final _Filters filters;
  final CategoryIndex idx;
  final ValueChanged<_Filters> onChanged;

  @override
  Widget build(BuildContext context) {
    final f = filters;
    final roots = idx.byId.values.where((c) => !c.archived).toList()
      ..sort((a, b) => idx.label(a.id).compareTo(idx.label(b.id)));
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Space.sm,
        children: [
          FaroTextField(
            key: const Key('cycle-search'),
            controller: search,
            focusNode: focus,
            label: 'Buscar',
            hint: context.isWide ? 'Concepto o categoría (atajo: /)' : 'Concepto o categoría',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: search.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Borrar la búsqueda',
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      search.clear();
                      onChanged(f.copy(query: ''));
                    },
                  ),
            onChanged: (q) => onChanged(f.copy(query: q)),
          ),
          Wrap(
            spacing: Space.sm,
            runSpacing: Space.xs,
            children: [
              InputChip(
                key: const Key('filter-category'),
                avatar: Icon(f.category == null ? Icons.category_outlined : idx.icon(f.category), size: 18),
                label: Text(f.category == null ? 'Categoría' : idx.label(f.category)),
                selected: f.category != null,
                onDeleted: f.category == null ? null : () => onChanged(f.copy(clearCategory: true)),
                onPressed: () async {
                  final p = await showSelectPicker<String>(
                    context,
                    title: 'Filtrar por categoría',
                    search: true,
                    selected: f.category,
                    options: [
                      for (final c in roots)
                        SelectOption(c.id, idx.label(c.id), icon: idx.icon(c.id), iconColor: idx.color(c.id)),
                    ],
                  );
                  if (p != null) onChanged(f.copy(category: p.value));
                },
              ),
              FilterChip(
                label: const Text('Cuotas'),
                selected: f.installments,
                onSelected: (v) => onChanged(f.copy(installments: v)),
              ),
              FilterChip(
                label: const Text('Recurrentes'),
                selected: f.recurring,
                onSelected: (v) => onChanged(f.copy(recurring: v)),
              ),
              FilterChip(
                label: const Text('Compartidos'),
                selected: f.shared,
                onSelected: (v) => onChanged(f.copy(shared: v)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Panel lateral en escritorio: resumen del ciclo, próximos cargos, compromisos y gasto por
/// categoría.
class _SidePanel extends StatelessWidget {
  const _SidePanel({required this.cycle, required this.idx});
  final CycleDetailOut cycle;
  final CategoryIndex idx;

  @override
  Widget build(BuildContext context) {
    final s = cycle.summary;
    final tt = Theme.of(context).textTheme;
    final active = cycle.movements.where((m) => m.status != MovementOutStatusEnum.cancelled).toList();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final soon =
        active
            .where(
              (m) =>
                  m.status == MovementOutStatusEnum.planned &&
                  m.dueDate != null &&
                  m.dueDate!.isBefore(today.add(const Duration(days: 7))),
            )
            .toList()
          ..sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
    final planned = active.where((m) => m.status == MovementOutStatusEnum.planned);
    Decimal sumOf(Iterable<MovementOut> ms) => ms.fold(Decimal.zero, (a, m) => a + dec(m.amount));
    final cuotas = planned.where((m) => m.source_ == 'installment');
    final recs = planned.where((m) => m.source_ == 'recurring');
    // Gasto por categoría principal (lo cargado y lo previsto)
    final byCat = <String?, Decimal>{};
    for (final m in active.where((m) => m.kind == MovementOutKindEnum.gasto)) {
      final root = idx[m.categoryId]?.parentId ?? m.categoryId;
      byCat[root] = (byCat[root] ?? Decimal.zero) - dec(m.amount);
    }
    final cats = byCat.entries.where((e) => e.value > Decimal.zero).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxCat = cats.isEmpty ? 1.0 : cats.first.value.toDouble();

    Widget line(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(k, style: tt.bodyMedium)),
          Text(v, style: tt.bodyMedium?.copyWith(fontFeatures: FaroText.tabular)),
        ],
      ),
    );
    Widget card(String title, List<Widget> children) => Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Space.xs,
          children: [
            Text(title.toUpperCase(), style: FaroText.overline(context)),
            const SizedBox(height: Space.xs),
            ...children,
          ],
        ),
      ),
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, Space.sm, Space.md, 96),
      children: [
        card('Resumen del ciclo', [
          line('Arrastre', eur(s.carried)),
          line('Nómina', eur(s.payroll)),
          line('Cargado', eur((dec(s.availableNow) - dec(s.opening)).toString(), plus: true)),
          line('Pendiente', eur(s.pendingTotal, plus: true)),
          const Divider(),
          line('Previsto al cobrar', eur(s.expectedEnd)),
        ]),
        card('Próximos 7 días', [
          if (soon.isEmpty) Text('Nada previsto', style: FaroText.caption(context)),
          for (final m in soon.take(8)) line('${dayMonth(m.dueDate!)} · ${m.concept}', eur(m.amount)),
        ]),
        card('Compromisos del ciclo', [
          line('Cuotas pendientes (${cuotas.length})', eur(sumOf(cuotas).toString())),
          line('Recurrentes pendientes (${recs.length})', eur(sumOf(recs).toString())),
        ]),
        if (cats.isNotEmpty)
          card('Gasto por categoría (cargado y previsto)', [
            for (final e in cats.take(8))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: 2,
                  children: [
                    line(idx.label(e.key), formatEur(e.value)),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: e.value.toDouble() / maxCat,
                        minHeight: 5,
                        color: idx.color(e.key),
                      ),
                    ),
                  ],
                ),
              ),
          ]),
      ],
    );
  }
}

/// Los primeros días tras "He cobrado", por si fue sin querer: se puede deshacer mientras el ciclo
/// siga abierto (después, el aviso ya no sale para no estorbar).
class _UndoPaydayBanner extends ConsumerWidget {
  const _UndoPaydayBanner({required this.cycle});
  final CycleDetailOut cycle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final undo = ref.watch(paydayUndoProvider).value;
    final now = DateTime.now();
    final days = DateTime(now.year, now.month, now.day).difference(cycle.startDate).inDays;
    if (undo == null || !undo.available || days > 7) return const SizedBox.shrink();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
      child: ListTile(
        leading: const Icon(Icons.undo),
        title: Text('Ciclo abierto con «He cobrado» el ${shortDate(cycle.startDate)}'),
        subtitle: const Text('Si fue sin querer, puedes deshacerlo mientras este ciclo siga abierto.'),
        trailing: TextButton(
          key: const Key('undo-payday'),
          onPressed: () => undoPayday(context, ref),
          child: const Text('Deshacer'),
        ),
      ),
    );
  }
}

class _PriceAlert extends ConsumerWidget {
  const _PriceAlert({required this.r});
  final RecurringOut r;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = r.priceChanges.first;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: Space.md, vertical: Space.xs),
      color: context.faro.warningContainer,
      child: ListTile(
        leading: Icon(Icons.trending_up, color: context.faro.warning),
        title: Text('${r.concept} ha cambiado de precio'),
        subtitle: Text('${eur(c.oldAmount)} → ${eur(c.newAmount)}'),
        trailing: TextButton(
          child: const Text('Visto'),
          onPressed: () async {
            await ref.read(apiProvider).getGastosApi().ackPrice(templateId: r.id);
            ref.invalidate(recurringProvider);
          },
        ),
      ),
    );
  }
}

/// Fila de movimiento: siempre con su fecha (de cargo, o prevista si está pendiente). Botón
/// visible para marcar cargado; al pasar el ratón, volver a previsto, duplicar y eliminar. En el
/// móvil además se puede deslizar (derecha = cargado/previsto, izquierda = eliminar).
class MovementTile extends ConsumerWidget {
  const MovementTile({super.key, required this.m, required this.idx, this.readOnly = false, this.month});
  final MovementOut m;
  final CategoryIndex idx;
  final bool readOnly;

  /// Ciclo futuro (AAAA-MM) en el que está, si no es el actual.
  final String? month;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = dec(m.amount);
    final planned = m.status == MovementOutStatusEnum.planned;
    final when = planned ? m.dueDate : m.date;
    final editable = !readOnly && m.kind != MovementOutKindEnum.nomina;
    final sub = [
      idx.label(m.categoryId),
      if (m.lines.length > 1) '${m.lines.length} líneas',
      if (m.source_ == 'installment') 'cuota',
      if (m.source_ == 'recurring') 'recurrente',
      if (m.shares.isNotEmpty)
        'compartido (${m.shares.where((s) => s.status == ShareBriefOutStatusEnum.pendiente).length} pendientes)',
      if (m.debtId != null) 'deuda',
      if (!planned && m.date == null) 'sin fecha de cargo',
    ].join(' · ');
    final row = ListRow(
      key: Key('mv-row-${m.id}'),
      reserveAction: !readOnly,
      lead: when == null ? '—' : dayMonth(when),
      leading: idx.avatar(context, m.categoryId),
      title: m.concept,
      subtitle: sub,
      muted: planned,
      trailing: Text(
        formatEur(amount, showPlus: true),
        style: TextStyle(
          color: amount > Decimal.zero
              ? context.faro.gain
              : (planned ? Theme.of(context).colorScheme.onSurfaceVariant : null),
        ),
      ),
      extra: editable && m.categoryId == null && m.kind != MovementOutKindEnum.transferencia
          ? Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                key: Key('categorize-${m.id}'),
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact, padding: EdgeInsets.zero),
                icon: const Icon(Icons.label_outline, size: 18),
                label: Text(m.source_ == 'installment' ? 'Elegir categoría (para toda la compra)' : 'Elegir categoría'),
                onPressed: () => categorizeMovement(context, ref, m, idx),
              ),
            )
          : null,
      onTap: readOnly ? null : () => showMovementSheet(context, ref, existing: m, month: month),
      actions: !editable
          ? const []
          : [
              if (planned && month == null)
                RowAction(
                  key: Key('post-${m.id}'),
                  icon: Icons.check_circle_outline,
                  label: 'Marcar cargado',
                  primary: true,
                  onPressed: () => setPosted(context, ref, m, true),
                ),
              if (!planned)
                RowAction(
                  icon: Icons.undo,
                  label: 'Volver a previsto',
                  onPressed: () => setPosted(context, ref, m, false),
                ),
              if (!planned && m.date == null)
                RowAction(icon: Icons.event_outlined, label: 'Poner fecha', onPressed: () => _setDate(context, ref, m)),
              RowAction(icon: Icons.copy_outlined, label: 'Duplicar', onPressed: () => _duplicate(context, ref, m)),
              RowAction(
                icon: Icons.delete_outline,
                label: 'Eliminar',
                onPressed: () => deleteMovement(context, ref, m),
              ),
            ],
    );
    if (!editable || !context.isCompact) return row;
    return Dismissible(
      key: ValueKey('mv-${m.id}-${m.status}'),
      background: Container(
        color: context.faro.gain.withValues(alpha: 0.85),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: Icon(planned ? Icons.check : Icons.undo, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Theme.of(context).colorScheme.error,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (dir) async =>
          dir == DismissDirection.startToEnd ? setPosted(context, ref, m, planned) : deleteMovement(context, ref, m),
      child: row,
    );
  }
}

/// Marca cargado (con fecha de hoy, que el servidor pone si no la tiene) o vuelve a previsto, con
/// Deshacer. Devuelve si ha ido bien.
Future<bool> setPosted(BuildContext context, WidgetRef ref, MovementOut m, bool posted) async {
  final api = ref.read(apiProvider).getGastosApi();
  Future<void> patch(bool p) => api.patchMovement(
    movementId: m.id,
    movementPatch: MovementPatch(status: p ? MovementPatchStatusEnum.posted : MovementPatchStatusEnum.planned),
  );
  try {
    await patch(posted);
    refreshGastos(ref);
    if (context.mounted) {
      showUndoSnack(
        context,
        posted ? '${m.concept}: cargado hoy' : '${m.concept}: vuelve a previsto',
        onUndo: () async {
          await patch(!posted);
          refreshGastos(ref);
        },
      );
    }
    return true;
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
    return false;
  }
}

/// Eliminar con la confirmación común.
Future<bool> deleteMovement(BuildContext context, WidgetRef ref, MovementOut m) async {
  final ok = await confirmDialog(context, title: '¿Eliminar movimiento?', message: '${m.concept} · ${eur(m.amount)}');
  if (!ok) return false;
  try {
    await ref.read(apiProvider).getGastosApi().deleteMovement(movementId: m.id);
    refreshGastos(ref);
    return true;
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
    return false;
  }
}

Future<void> _duplicate(BuildContext context, WidgetRef ref, MovementOut m) async {
  try {
    final d = (await ref.read(apiProvider).getGastosApi().duplicateMovement(movementId: m.id)).data!;
    refreshGastos(ref);
    if (context.mounted) {
      showUndoSnack(
        context,
        'Duplicado: ${m.concept}',
        onUndo: () async {
          await ref.read(apiProvider).getGastosApi().deleteMovement(movementId: d.id);
          refreshGastos(ref);
        },
      );
    }
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

Future<void> _setDate(BuildContext context, WidgetRef ref, MovementOut m) async {
  final d = await showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2000),
    lastDate: DateTime.now(),
    helpText: 'Fecha de cargo de ${m.concept}',
  );
  if (d == null) return;
  try {
    await ref
        .read(apiProvider)
        .getGastosApi()
        .patchMovement(
          movementId: m.id,
          movementPatch: MovementPatch(date: apiDay(d)),
        );
    refreshGastos(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

/// Categorizar rápido un movimiento "Sin categoría". Si es una cuota, la categoría se pone a la
/// compra fraccionada, así que también la heredan sus cuotas pendientes.
Future<void> categorizeMovement(BuildContext context, WidgetRef ref, MovementOut m, CategoryIndex idx) async {
  final cats =
      idx.byId.values
          .where((c) => !c.archived && (c.parentId != null || !idx.byId.values.any((x) => x.parentId == c.id)))
          .toList()
        ..sort((a, b) => idx.label(a.id).compareTo(idx.label(b.id)));
  final p = await showSelectPicker<String>(
    context,
    title: 'Categoría de ${m.concept}',
    search: true,
    options: [
      for (final c in cats) SelectOption(c.id, idx.label(c.id), icon: idx.icon(c.id), iconColor: idx.color(c.id)),
    ],
  );
  if (p == null) return;
  final api = ref.read(apiProvider).getGastosApi();
  try {
    await api.patchMovement(
      movementId: m.id,
      movementPatch: MovementPatch(categoryId: p.value),
    );
    final plan = m.source_ == 'installment' ? m.sourceRef : null;
    if (plan != null) {
      await api.patchPlan(
        planId: plan,
        installmentPlanPatch: InstallmentPlanPatch(categoryId: p.value),
      );
    }
    refreshGastos(ref);
    ref.invalidate(plansProvider);
    if (context.mounted) {
      showSnack(
        context,
        plan != null ? 'Categoría puesta a la compra y a sus cuotas pendientes' : 'Categoría guardada',
      );
    }
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

class _NoOpenCycle extends ConsumerWidget {
  const _NoOpenCycle();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Center(
    child: EmptyState(
      icon: Icons.event_repeat,
      title: 'No hay ningún ciclo abierto',
      text: 'Empieza uno con el saldo de hoy de tu cuenta de gastos.',
      actionLabel: 'Empezar ciclo',
      onAction: () => showStartCycleDialog(context, ref),
    ),
  );
}

class _ErrorScaffold extends StatelessWidget {
  const _ErrorScaffold(this.message, this.retry);
  final String message;
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const FaroAppBar(title: PageTitle('Gastos')),
    body: Center(
      child: EmptyState(icon: Icons.cloud_off, title: message, actionLabel: 'Reintentar', onAction: retry),
    ),
  );
}

/// Sin conexión: de cuándo son los datos y qué gastos esperan a enviarse.
class _OfflineBanner extends ConsumerWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final since = ref.watch(offlineSinceProvider);
    final pending = ref.watch(pendingMovementsProvider);
    if (since == null && pending.isEmpty) return const SizedBox.shrink();
    final hh = since == null
        ? ''
        : '${since.hour.toString().padLeft(2, '0')}:${since.minute.toString().padLeft(2, '0')}';
    return Card(
      margin: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 0),
      color: context.faro.warningContainer,
      child: ListTile(
        leading: Icon(Icons.cloud_off, color: context.faro.warning),
        title: Text(since != null ? 'Sin conexión · datos de las $hh' : 'Gastos pendientes de enviar'),
        subtitle: pending.isEmpty
            ? null
            : Text(
                '${pending.length} ${pending.length == 1 ? 'gasto apuntado' : 'gastos apuntados'} sin red: '
                '${pending.map((m) => m.concept).take(3).join(', ')}${pending.length > 3 ? ' y más' : ''}',
              ),
        trailing: TextButton(
          onPressed: () async {
            final sent = await ref.read(pendingMovementsProvider.notifier).flush();
            refreshGastos(ref);
            if (context.mounted && sent > 0) showSnack(context, '$sent enviados');
          },
          child: const Text('Reintentar'),
        ),
      ),
    );
  }
}
