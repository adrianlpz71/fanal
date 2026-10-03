import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/dates.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../gastos/data.dart' show showSnack;
import 'data.dart';

/// Nueva operación: primero el tipo, luego el activo (con buscador), la fecha y solo los campos
/// que pide ese tipo, con una vista previa de lo que va a pasar. En el móvil es una hoja a
/// pantalla completa; en pantallas anchas, un diálogo.
Future<void> showTxSheet(BuildContext context, WidgetRef ref, {String? assetId}) =>
    showFormPanel(context, builder: (_) => _TxForm(assetId: assetId));

const _mainKinds = [TxInKindEnum.compra, TxInKindEnum.venta, TxInKindEnum.aportacionPeriodica];
const _otherKinds = [
  TxInKindEnum.posicionInicial,
  TxInKindEnum.dividendo,
  TxInKindEnum.interes,
  TxInKindEnum.comision,
  TxInKindEnum.recompensa,
];

class _TxForm extends ConsumerStatefulWidget {
  const _TxForm({this.assetId});
  final String? assetId;

  @override
  ConsumerState<_TxForm> createState() => _TxFormState();
}

class _TxFormState extends ConsumerState<_TxForm> {
  String? _asset;
  TxInKindEnum _kind = TxInKindEnum.compra;
  bool _others = false;
  DateTime _date = DateTime.now();
  final _amount = TextEditingController();
  final _units = TextEditingController();
  final _price = TextEditingController();
  final _fee = TextEditingController();
  bool _pending = false;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _asset = widget.assetId;
    for (final c in [_amount, _units, _price]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final c in [_amount, _units, _price, _fee]) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _initial => _kind == TxInKindEnum.posicionInicial;
  bool get _buy => _kind == TxInKindEnum.compra || _kind == TxInKindEnum.aportacionPeriodica;

  /// Tipos con participaciones (el resto solo mueve dinero).
  bool get _hasUnits => const {
        TxInKindEnum.compra, TxInKindEnum.venta, TxInKindEnum.aportacionPeriodica,
        TxInKindEnum.posicionInicial, TxInKindEnum.recompensa,
      }.contains(_kind);

  String? _q(TextEditingController c) => parseEsDecimal(c.text)?.toString();

  void _setKind(TxInKindEnum k) => setState(() {
        _kind = k;
        if (!_buy) _pending = false;
      });

  Future<void> _save() async {
    if (_asset == null) return setState(() => _error = 'Elige el activo');
    if (!_initial && parseEsDecimal(_amount.text) == null) {
      return setState(() => _error = 'Introduce el importe');
    }
    if (_initial && (parseEsDecimal(_units.text) == null || parseEsDecimal(_price.text) == null)) {
      return setState(() => _error = 'Pon las participaciones y el precio medio');
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final amount = parseEsDecimal(_amount.text);
    try {
      await ref.read(apiProvider).getInversionesApi().createTransaction(
            txIn: TxIn(
              assetId: _asset!,
              kind: _kind,
              tradeDate: apiDay(_date),
              amountEur: amount == null ? '0' : apiAmount(amount.abs()),
              units: _hasUnits && !_pending ? _q(_units) : null,
              price: _initial || _pending ? null : _q(_price),
              avgCost: _initial ? _q(_price) : null,
              fee: parseEsDecimal(_fee.text) == null ? '0' : apiAmount(parseEsDecimal(_fee.text)!),
              pending: _pending,
            ),
          );
      refreshInv(ref);
      if (mounted) {
        Navigator.pop(context);
        showSnack(context, 'Operación guardada');
      }
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Vista previa: participaciones que salen y cómo cambia el PMP (solo informativa: el cálculo
  /// real lo hace el servidor al guardar).
  String? _preview(PositionOut? pos) {
    if (privacyMode) return null;
    final amount = parseEsDecimal(_amount.text);
    final units = parseEsDecimal(_units.text);
    final price = parseEsDecimal(_price.text) ?? (pos?.price == null ? null : dec(pos!.price));
    String u(Decimal d) => d.toStringAsFixed(4).replaceAll('.', ',');
    if (_initial) {
      if (units == null || price == null) return null;
      return 'Posición de ${u(units)} participaciones con un coste de ${formatEur(units * price)}';
    }
    if (_buy) {
      if (_pending) return amount == null ? null : 'Se confirmará con el valor liquidativo del ${dayMonth(_date)}';
      final got = units ?? (amount != null && price != null && price > Decimal.zero
          ? (amount / price).toDecimal(scaleOnInfinitePrecision: 6)
          : null);
      if (got == null || amount == null || got == Decimal.zero) return null;
      final per = (amount / got).toDecimal(scaleOnInfinitePrecision: 4);
      final lines = ['Equivale a ${u(got)} participaciones a ${formatEur(per)}'];
      if (pos != null && dec(pos.units) > Decimal.zero) {
        final oldUnits = dec(pos.units);
        final oldAvg = dec(pos.avgCost);
        final newAvg = ((oldUnits * oldAvg + amount) / (oldUnits + got)).toDecimal(scaleOnInfinitePrecision: 4);
        lines.add('Tu PMP pasa de ${formatEur(oldAvg)} a ${formatEur(newAvg)}');
      }
      return lines.join('\n');
    }
    if (_kind == TxInKindEnum.venta && pos != null && units != null) {
      final left = dec(pos.units) - units;
      return 'Te quedarán ${u(left < Decimal.zero ? Decimal.zero : left)} participaciones';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final assets = (ref.watch(assetsProvider).value ?? const <AssetOut>[]).where((a) => !a.archived).toList();
    final classes = {for (final c in ref.watch(assetClassesProvider).value ?? const <AssetClassOut>[]) c.id: c.name};
    final platforms = {for (final p in ref.watch(platformsProvider).value ?? const <PlatformOut>[]) p.id: p.name};
    final positions = {
      for (final c in ref.watch(portfolioProvider).value?.classes ?? const <ClassOut>[])
        for (final p in c.positions) p.asset.id: p,
    };
    final asset = assets.where((a) => a.id == _asset).firstOrNull;
    final isFund = asset?.type == AssetOutTypeEnum.fondo || asset?.type == AssetOutTypeEnum.etf;
    final preview = _preview(positions[_asset]);

    return FormPanel(
      title: 'Nueva operación',
      onSubmit: _busy ? null : _save,
      header: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: 12, children: [
        SegmentedField<String>(
          buttonKey: const Key('tx-kind'),
          segments: [
            for (final k in _mainKinds) Segment(k.value, txKindLabels[k]!),
            const Segment('otros', 'Más tipos', icon: Icons.expand_more),
          ],
          value: _others ? 'otros' : _kind.value,
          onChanged: (v) {
            if (v == 'otros') {
              setState(() => _others = true);
              _setKind(_otherKinds.first);
            } else {
              setState(() => _others = false);
              _setKind(_mainKinds.firstWhere((k) => k.value == v));
            }
          },
        ),
        if (_others)
          ChoiceChipsField<TxInKindEnum>(
            options: [for (final k in _otherKinds) Segment(k, txKindLabels[k]!)],
            value: _kind,
            onChanged: _setKind,
          ),
      ]),
      actions: FormActions(
        primaryKey: const Key('save-tx'),
        primaryLabel: 'Guardar',
        busy: _busy,
        expand: context.isCompact,
        onPrimary: _save,
      ),
      children: [
        SelectField<String>(
          key: const Key('tx-asset'),
          label: 'Activo',
          value: _asset,
          emptyText: 'Elige el activo',
          options: [
            for (final a in assets)
              SelectOption(
                a.id,
                a.name,
                subtitle: [
                  {for (final e in assetTypeLabels.entries) e.key.value: e.value}[a.type.value] ?? a.type.value,
                  if (a.assetClassId != null) classes[a.assetClassId] ?? '',
                  if (a.platformId != null) platforms[a.platformId] ?? '',
                ].where((x) => x.isNotEmpty).join(' · '),
              ),
          ],
          onChanged: (v) => setState(() => _asset = v),
        ),
        DateField(
          key: const Key('tx-date'),
          label: 'Fecha',
          value: _date,
          last: DateTime.now(),
          onChanged: (d) => setState(() => _date = d ?? _date),
        ),
        if (!_initial)
          MoneyField(
            key: const Key('tx-amount'),
            controller: _amount,
            label: switch (_kind) {
              TxInKindEnum.venta => 'Importe recibido',
              TxInKindEnum.recompensa => 'Valor al recibirla',
              _ => 'Importe',
            },
          ),
        if (_buy && isFund)
          SwitchField(
            title: 'Pendiente de valor liquidativo',
            subtitle: 'Aún no sabes las participaciones: se confirmará con el VL de esa fecha.',
            value: _pending,
            onChanged: (v) => setState(() => _pending = v),
          ),
        if (_hasUnits && !_pending) ...[
          UnitsField(key: const Key('tx-units'), controller: _units, label: 'Participaciones / unidades'),
          if (_kind != TxInKindEnum.recompensa)
            MoneyField(
              key: const Key('tx-price'),
              controller: _price,
              label: _initial ? 'Precio medio de compra (PMP)' : 'Precio por unidad (opcional)',
              helper: _initial ? null : 'Si no pones participaciones, se calculan con importe ÷ precio.',
            ),
        ],
        if (!_initial && _kind != TxInKindEnum.comision)
          MoneyField(key: const Key('tx-fee'), controller: _fee, label: 'Comisión'),
        if (preview != null)
          Card(
            key: const Key('tx-preview'),
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(Space.md),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.sm, children: [
                const Icon(Icons.visibility_outlined, size: 18),
                Expanded(child: Text(preview)),
              ]),
            ),
          ),
        if (_error != null) ErrorText(_error),
      ],
    );
  }
}

/// Confirmar una aportación pendiente: con las participaciones que da el broker o con el VL.
Future<void> showSettleDialog(BuildContext context, WidgetRef ref, TxOut t) =>
    showFormPanel(context, builder: (_) => _SettleForm(t: t));

class _SettleForm extends ConsumerStatefulWidget {
  const _SettleForm({required this.t});
  final TxOut t;

  @override
  ConsumerState<_SettleForm> createState() => _SettleFormState();
}

class _SettleFormState extends ConsumerState<_SettleForm> {
  final _units = TextEditingController();
  final _price = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _units.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (parseEsDecimal(_units.text) == null && parseEsDecimal(_price.text) == null) {
      return setState(() => _error = 'Pon las participaciones o el valor liquidativo');
    }
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider).getInversionesApi().settleTransaction(
            txId: widget.t.id,
            txSettleIn: TxSettleIn(
              units: parseEsDecimal(_units.text)?.toString(),
              price: parseEsDecimal(_price.text)?.toString(),
            ),
          );
      refreshInv(ref);
      if (mounted) {
        Navigator.pop(context);
        showSnack(context, 'Aportación confirmada');
      }
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FormPanel(
        title: 'Confirmar ${eur(widget.t.amountEur)}',
        onSubmit: _busy ? null : _save,
        actions: FormActions(primaryLabel: 'Confirmar', busy: _busy, onPrimary: _save, expand: context.isCompact),
        children: [
          const Text('Indica las participaciones que te ha dado el broker, o el valor liquidativo.'),
          UnitsField(controller: _units, label: 'Participaciones'),
          MoneyField(controller: _price, label: 'O valor liquidativo'),
          if (_error != null) ErrorText(_error),
        ],
      );
}
