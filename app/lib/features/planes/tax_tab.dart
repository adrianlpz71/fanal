import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../inversiones/data.dart' show pct, portfolioProvider, NoAdviceNote;
import 'data.dart';

/// Planes → Impuestos: para qué sirve, prellenado con tus datos, el cálculo paso a paso con la
/// barra de tramos y "¿Y si vendo X € hoy?" (D8).
class TaxTab extends ConsumerStatefulWidget {
  const TaxTab({super.key});

  @override
  ConsumerState<TaxTab> createState() => _TaxTabState();
}

class _TaxTabState extends ConsumerState<TaxTab> {
  final _general = TextEditingController();
  final _savings = TextEditingController();
  bool _remember = true;
  bool _filled = false;
  bool _busy = false;
  TaxOut? _r;
  String? _error;

  @override
  void dispose() {
    _general.dispose();
    _savings.dispose();
    super.dispose();
  }

  void _prefill(TaxPrefillOut p) {
    if (_filled) return;
    _filled = true;
    if (p.baseGeneral != null) _general.text = dec(p.baseGeneral).toStringAsFixed(2).replaceAll('.', ',');
    _savings.text = dec(p.baseSavings).toStringAsFixed(2).replaceAll('.', ',');
  }

  Decimal get _bg => parseEsDecimal(_general.text) ?? Decimal.zero;
  Decimal get _bs => parseEsDecimal(_savings.text) ?? Decimal.zero;

  Future<void> _calc() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await ref.read(apiProvider).getPlanesApi().simulateTax(
            taxIn: TaxIn(
              baseGeneral: apiAmount(_bg),
              baseSavings: apiAmount(_bs),
              rememberBaseGeneral: _remember && _bg > Decimal.zero,
            ),
          );
      if (_remember) ref.invalidate(taxPrefillProvider);
      setState(() => _r = r.data);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pre = ref.watch(taxPrefillProvider).value;
    if (pre != null) _prefill(pre);
    final r = _r;
    final data = _data(context, pre);
    final sell = _SellPreview(key: ValueKey('$_bg|$_bs'), baseGeneral: _bg, baseSavings: _bs);
    return ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.xl), children: [
      Card(
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
            Row(children: [
              Flexible(child: Text('¿Para qué sirve?', style: Theme.of(context).textTheme.titleMedium)),
              const InfoTip(
                '',
                title: 'Cómo se calcula',
                text: 'Base → mínimo personal → tramos → cuota estatal y autonómica → total, con tipo medio y '
                    'marginal. Con las escalas oficiales del año, sin deducciones. Sirve para estimar tu Renta '
                    'o para ver cuánto te costaría vender parte de tu cartera.',
              ),
            ]),
            const Text('Estima tu IRPF y Patrimonio del año, o lo que te costaría vender parte de la cartera.'),
          ]),
        ),
      ),
      const SizedBox(height: Space.md),
      // En ancho, tus datos y "¿y si vendo?" lado a lado
      LayoutBuilder(
        builder: (context, box) => box.maxWidth >= 900
            ? IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
                  Expanded(child: data),
                  Expanded(child: sell),
                ]),
              )
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [data, sell]),
      ),
      if (r != null) ...[const SizedBox(height: Space.md), _Steps(r: r)],
      const NoAdviceNote(
        text: 'Escalas y mínimos de la tabla de parámetros fiscales de Fanal, cada uno con su fuente oficial '
            '(AEAT/BOE/BOC). Sin deducciones ni reducciones: es una estimación.',
      ),
    ]);
  }

  Widget _data(BuildContext context, TaxPrefillOut? pre) => Card(
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: FormSubmitScope(
            onSubmit: _busy ? null : _calc,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: FaroTheme.fieldGap, children: [
              Row(children: [
                Flexible(
                  child: Text('Tus datos de ${pre?.year ?? DateTime.now().year}',
                      style: Theme.of(context).textTheme.titleMedium),
                ),
                // El detalle de la base general (la ayuda del campo se queda en una línea)
                InfoTip(
                  '',
                  title: 'Base liquidable general',
                  text: 'Tu sueldo menos los gastos deducibles (Seguridad Social…) y las reducciones. No es la '
                      'nómina neta: búscala en tu certificado de retenciones o en el borrador de la renta.'
                      '${pre == null ? '' : ' Tu nómina neta cobrada en ${pre.year} fue de ${eur(pre.payrollNet)} (de tus ciclos).'}',
                ),
              ]),
              MoneyField(
                key: const Key('tax-general'),
                label: 'Base liquidable general',
                info: 'base-general',
                controller: _general,
                onChanged: (_) => setState(() {}),
                suffix: '€/año',
                helper: pre == null
                    ? 'Tu sueldo menos gastos deducibles y reducciones'
                    : 'Tu nómina neta ${pre.year}: ${eur(pre.payrollNet)} (no es la base)',
              ),
              SwitchField(
                title: 'Recordar la base para la próxima vez',
                value: _remember,
                onChanged: (v) => setState(() => _remember = v),
              ),
              MoneyField(
                key: const Key('tax-savings'),
                label: 'Base del ahorro',
                info: 'base-ahorro',
                controller: _savings,
                onChanged: (_) => setState(() {}),
                suffix: '€/año',
                allowNegative: true,
                helper: pre == null
                    ? 'Ganancias de ventas, intereses y dividendos'
                    : 'De tu Informe fiscal ${pre.year}: '
                        '${pre.sales == 0 ? 'este año no has vendido nada' : 'ganancias de ${pre.sales} ${pre.sales == 1 ? 'venta' : 'ventas'} ${eur(pre.realizedGains, plus: true)} (FIFO)'}'
                        ' e intereses y dividendos ${eur(pre.income)}.',
              ),
              Wrap(spacing: Space.sm, runSpacing: Space.sm, crossAxisAlignment: WrapCrossAlignment.center, children: [
                FilledButton(key: const Key('tax-calc'), onPressed: _busy ? null : _calc, child: const Text('Calcular')),
                TextButton.icon(
                  key: const Key('to-tax-report'),
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: const Text('Ver el Informe fiscal'),
                  onPressed: () => context.go('/patrimonio/informe-fiscal'),
                ),
              ]),
              if (_error != null) ErrorText(_error),
            ]),
          ),
        ),
      );
}

String _range(TaxBracketOut b) => b.hi == null
    ? 'Más de ${MoneyText.format(dec(b.lo), compact: true)}'
    : '${MoneyText.format(dec(b.lo), compact: true)} – ${MoneyText.format(dec(b.hi), compact: true)}';

/// Tramos como barras: cuánto de la base cae en cada uno, a qué tipo y cuánto paga.
class _Brackets extends StatelessWidget {
  const _Brackets({required this.title, required this.rows});
  final String title;
  final List<TaxBracketOut> rows;

  @override
  Widget build(BuildContext context) {
    final used = rows.where((b) => dec(b.amount) > Decimal.zero).toList();
    if (used.isEmpty) return const SizedBox.shrink();
    final most = used.map((b) => dec(b.amount).toDouble()).reduce((a, b) => a > b ? a : b);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
      Text(title, style: Theme.of(context).textTheme.titleSmall),
      BarList(items: [
        for (final b in used)
          BarItem(
            label: '${_range(b)} · al ${pct(b.rate, decimals: 2)}',
            value: eur(b.tax),
            fraction: dec(b.amount).toDouble() / most,
            detail: '${eur(b.amount)} en este tramo',
          ),
      ]),
    ]);
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.r});
  final TaxOut r;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    Widget step(int n, String title, List<Widget> body) => Padding(
          padding: const EdgeInsets.only(bottom: Space.lg),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.md, children: [
            CircleAvatar(radius: 13, child: Text('$n', style: tt.labelLarge)),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.xs, children: [
                Text(title, style: tt.titleSmall),
                ...body,
              ]),
            ),
          ]),
        );
    Widget line(String k, String v, {bool bold = false}) => Row(children: [
          Expanded(child: Text(k)),
          Text(v, style: TextStyle(fontWeight: bold ? FontWeight.w700 : null, fontFeatures: FaroText.tabular)),
        ]);
    return Card(
      key: const Key('tax-steps'),
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('IRPF ${r.year} · ${r.region == 'ES-CN' ? 'Canarias' : r.region}', style: tt.titleMedium),
          const SizedBox(height: Space.md),
          step(1, 'Base', [
            line('Base general (tu sueldo)', eur(r.baseGeneral)),
            line('Base del ahorro (ganancias, intereses y dividendos)', eur(r.baseSavings)),
          ]),
          step(2, 'Mínimo personal', [
            Text('La parte de la renta que no tributa: ${eur(r.minimumState)} en la escala estatal y '
                '${eur(r.minimumRegional)} en la autonómica. Se calcula la cuota de ese mínimo '
                '(${eur(r.minimumQuota)}) y se resta.'),
          ]),
          step(3, 'Tramos', [
            _Brackets(title: 'Base general (escala estatal + autonómica)', rows: r.generalBrackets),
            const SizedBox(height: Space.sm),
            _Brackets(title: 'Base del ahorro', rows: r.savingsBrackets),
          ]),
          step(4, 'Cuotas', [
            line('Estatal (general)', eur(r.irpfGeneralState)),
            line('Autonómica (general)', eur(r.irpfGeneralRegional)),
            line('Del ahorro', eur(r.irpfSavings)),
          ]),
          step(5, 'Total', [
            line('IRPF', eur(r.irpfTotal), bold: true),
            if (r.averageRate != null) line('Tipo medio', pct(r.averageRate)),
            line('Tipo marginal (general)', pct(r.marginalGeneral, decimals: 1)),
            line('Tipo marginal (ahorro)', pct(r.marginalSavings, decimals: 0)),
            Text('El marginal es lo que pagarías por el siguiente euro; el medio, lo que pagas de media.',
                style: FaroText.caption(context)),
          ]),
          const Divider(),
          Text('Impuesto sobre el Patrimonio (con tu patrimonio neto actual)', style: tt.titleSmall),
          const SizedBox(height: Space.xs),
          line('Base liquidable', eur(r.wealthTaxable)),
          line('Cuota', eur(r.wealthQuota), bold: true),
          if (r.wealthJointLimitApplied) const Text('Reducida por el límite conjunto IRPF + Patrimonio (60 %).'),
          Text(r.wealthObliged ? 'Estarías obligado a declarar Patrimonio.' : 'No estarías obligado a declarar Patrimonio.'),
          if (r.solidarityWarning) const Text('Más de 3 M€: revisa el Impuesto Temporal de Solidaridad de las Grandes Fortunas.'),
        ]),
      ),
    );
  }
}

/// ¿Y si vendo X € hoy? De un activo o de toda la cartera en proporción a su peso (D8).
class _SellPreview extends ConsumerStatefulWidget {
  const _SellPreview({super.key, required this.baseGeneral, required this.baseSavings});
  final Decimal baseGeneral, baseSavings;

  @override
  ConsumerState<_SellPreview> createState() => _SellPreviewState();
}

class _SellPreviewState extends ConsumerState<_SellPreview> {
  final _amount = TextEditingController();
  String _asset = 'all';
  bool _busy = false;
  SellPreviewOut? _r;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  Future<void> _calc() async {
    final amount = parseEsDecimal(_amount.text);
    if (amount == null || amount <= Decimal.zero) {
      setState(() => _error = 'Escribe cuánto venderías');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await ref.read(apiProvider).getPlanesApi().sellPreview(
            sellPreviewIn: SellPreviewIn(
              amount: apiAmount(amount),
              assetId: _asset == 'all' ? null : _asset,
              baseGeneral: apiAmount(widget.baseGeneral),
              baseSavings: apiAmount(widget.baseSavings),
            ),
          );
      setState(() => _r = r.data);
    } catch (e) {
      setState(() {
        _r = null;
        _error = apiErrorMessage(e);
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pf = ref.watch(portfolioProvider).value;
    final positions = [
      for (final c in pf?.classes ?? const <ClassOut>[])
        for (final p in c.positions)
          if (dec(p.units) > Decimal.zero && p.price != null) p,
    ];
    final r = _r;
    final tt = Theme.of(context).textTheme;
    final noBase = widget.baseGeneral <= Decimal.zero;
    return Card(
      key: const Key('sell-preview'),
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: FormSubmitScope(
          onSubmit: _busy ? null : _calc,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: FaroTheme.fieldGap, children: [
            Text('¿Y si vendo X € hoy?', style: tt.titleMedium),
            Text('Ganancia con tus lotes reales (FIFO) e impuesto que la venta añade a tu IRPF del año.',
                style: FaroText.caption(context)),
            SelectField<String>(
              key: const Key('sell-asset'),
              label: 'Qué vendes',
              value: _asset,
              options: [
                const SelectOption('all', 'Toda la cartera', subtitle: 'En proporción a lo que pesa cada activo'),
                for (final p in positions)
                  SelectOption(p.asset.id, p.asset.name, subtitle: 'Vale ${eur(p.value)}'),
              ],
              onChanged: (v) => setState(() {
                _asset = v;
                _r = null;
              }),
            ),
            MoneyField(key: const Key('sell-amount'), label: 'Importe que vendes', controller: _amount),
            // Sin base general, el mínimo personal pasaría al ahorro y el impuesto saldría más bajo
            if (noBase)
              Row(key: const Key('sell-needs-base'), crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.sm, children: [
                Icon(Icons.warning_amber_rounded, size: 20, color: context.faro.warning, semanticLabel: 'Aviso'),
                Expanded(
                  child: Text('Escribe tu base general en «Tus datos» para que el impuesto de la venta sea real.',
                      style: TextStyle(color: context.faro.warning)),
                ),
              ]),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton(
                key: const Key('sell-calc'),
                onPressed: _busy || noBase ? null : _calc,
                child: const Text('Calcular'),
              ),
            ),
            if (_error != null) ErrorText(_error),
            if (r != null) ...[
              KpiGrid(minWidth: 150, children: [
                KpiCard(label: 'Ganancia (FIFO)', info: 'fifo', value: MoneyText.api(r.gain, plus: true, colored: true)),
                KpiCard(label: 'Impuesto de esa venta', value: MoneyText.api(r.tax)),
                KpiCard(label: 'Te quedan', value: MoneyText.api(r.net), emphasis: true),
              ]),
              if (r.parts.length > 1)
                for (final p in r.parts)
                  ListRow(
                    title: p.name,
                    subtitle: '${eur(p.amount)} · ganancia ${eur(p.gain, plus: true)}',
                    trailing: Text('${dec(p.units).toStringAsFixed(4).replaceAll('.', ',')}${nbsp}part.'),
                  ),
            ],
          ]),
        ),
      ),
    );
  }
}
