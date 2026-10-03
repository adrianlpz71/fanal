import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/charts/charts.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../inversiones/data.dart' show fractionFromPct, NoAdviceNote;

/// Planes → Interés compuesto: cuánto crece un capital con aportaciones; el resultado, con una
/// gráfica de lo aportado frente a los intereses y la tabla año a año.
class CompoundTab extends ConsumerStatefulWidget {
  const CompoundTab({super.key});

  @override
  ConsumerState<CompoundTab> createState() => _CompoundTabState();
}

class _CompoundTabState extends ConsumerState<CompoundTab> {
  final _initial = TextEditingController(text: '10000');
  final _contrib = TextEditingController(text: '300');
  final _rate = TextEditingController(text: '7');
  final _years = TextEditingController(text: '20');
  final _increase = TextEditingController(text: '0');
  final _inflation = TextEditingController(text: '0');
  bool _monthly = true;
  bool _start = false;
  bool _effective = false;
  bool _taxes = false;
  bool _busy = false;
  CompoundOut? _r;
  String? _error;

  @override
  void dispose() {
    for (final c in [_initial, _contrib, _rate, _years, _increase, _inflation]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _calc() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await ref.read(apiProvider).getPlanesApi().compound(compoundIn: CompoundIn(
        initial: apiAmount(parseEsDecimal(_initial.text) ?? dec('0')),
        contribution: apiAmount(parseEsDecimal(_contrib.text) ?? dec('0')),
        periods: _monthly ? CompoundInPeriodsEnum.number12 : CompoundInPeriodsEnum.number1,
        timing: _start ? CompoundInTimingEnum.inicio : CompoundInTimingEnum.final_,
        annualIncrease: fractionFromPct(_increase.text),
        annualRate: fractionFromPct(_rate.text) ?? '0',
        years: int.tryParse(_years.text) ?? 1,
        convention: _effective ? CompoundInConventionEnum.efectivo : CompoundInConventionEnum.nominal,
        inflation: fractionFromPct(_inflation.text),
        taxOnWithdrawal: _taxes,
      ));
      setState(() => _r = r.data);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _form() => FormSubmitScope(
        onSubmit: _busy ? null : _calc,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: FaroTheme.fieldGap, children: [
          FieldRow(children: [
            MoneyField(key: const Key('ci-initial'), label: 'Capital inicial', controller: _initial),
            MoneyField(
              key: const Key('ci-contrib'),
              label: 'Aportación',
              controller: _contrib,
              suffix: _monthly ? '€/mes' : '€/año',
            ),
          ]),
          FieldRow(children: [
            PercentField(label: 'Rentabilidad anual', controller: _rate),
            UnitsField(label: 'Años', controller: _years, integer: true, suffix: 'años'),
          ]),
          FieldRow(children: [
            PercentField(label: 'Subida anual de la aportación', controller: _increase),
            PercentField(label: 'Inflación (para el valor real)', controller: _inflation),
          ]),
          SegmentedField<bool>(
            label: 'Aportas cada',
            segments: const [Segment(true, 'Mes'), Segment(false, 'Año')],
            value: _monthly,
            onChanged: (v) => setState(() => _monthly = v),
          ),
          SegmentedField<bool>(
            label: 'La aportación entra',
            segments: const [Segment(true, 'Al principio del periodo'), Segment(false, 'Al final')],
            value: _start,
            onChanged: (v) => setState(() => _start = v),
          ),
          SegmentedField<bool>(
            label: 'Tipo por periodo',
            segments: const [Segment(false, 'Anual / 12'), Segment(true, 'Efectivo')],
            value: _effective,
            onChanged: (v) => setState(() => _effective = v),
          ),
          SwitchField(
            title: 'Impuestos al rescatarlo todo',
            subtitle: 'Escala del ahorro sobre los intereses',
            value: _taxes,
            onChanged: (v) => setState(() => _taxes = v),
          ),
          FormActions(primaryKey: const Key('ci-calc'), primaryLabel: 'Calcular', busy: _busy, onPrimary: _calc),
          if (_error != null) ErrorText(_error),
        ]),
      );

  Widget _result(CompoundOut r) {
    final big = FaroText.kpi(context);
    final cs = Theme.of(context).colorScheme;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
      KpiGrid(minWidth: 160, children: [
        KpiCard(
          label: 'Total',
          value: MoneyText.api(r.total, key: const Key('ci-total'), compact: true, style: big),
          emphasis: true,
        ),
        KpiCard(label: 'Aportado', value: MoneyText.api(r.contributed, compact: true, style: big)),
        KpiCard(label: 'Intereses', value: MoneyText.api(r.interest, compact: true, style: big)),
        KpiCard(
          label: 'En euros de hoy',
          value: MoneyText.api(r.realTotal, compact: true, style: big),
          note: 'Descontada la inflación',
        ),
      ]),
      if (r.taxIfWithdrawn != null)
        Text('Si lo rescatas todo: ${eur(r.taxIfWithdrawn)} de impuestos → ${eur(r.netIfWithdrawn)} netos'),
      Card(
        child: Padding(
          padding: const EdgeInsets.all(Space.md),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
            Text('Aportado e intereses, año a año', style: Theme.of(context).textTheme.titleMedium),
            FaroBarChart(
              key: const Key('ci-chart'),
              height: 240,
              series: [
                (id: 'contributed', label: 'Aportado', color: cs.outline),
                (id: 'interest', label: 'Intereses', color: context.faro.gain),
              ],
              groups: [
                for (final y in r.rows)
                  BarGroup('${y.year}', [dec(y.contributed).toDouble(), dec(y.interest).toDouble()],
                      tooltipTitle: 'Año ${y.year}'),
              ],
            ),
            Text(r.conventionNote, style: FaroText.caption(context)),
          ]),
        ),
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final r = _r;
    return LayoutBuilder(builder: (context, box) {
      final wide = box.maxWidth >= 1000;
      final intro = Text(
        'Cuánto crece un capital si aportas cada mes o cada año y lo dejas crecer. Es una calculadora: no usa '
        'tus datos.',
        style: FaroText.caption(context),
      );
      final result = r == null
          ? const EmptyState(icon: Icons.calculate_outlined, title: 'Pon las cifras y pulsa Calcular')
          : _result(r);
      return ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, Space.xl), children: [
        intro,
        const SizedBox(height: Space.md),
        if (wide)
          Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.xl, children: [
            SizedBox(width: FaroLayout.sidePanel, child: _form()),
            Expanded(child: result),
          ])
        else ...[
          _form(),
          const SizedBox(height: Space.lg),
          result,
        ],
        const NoAdviceNote(text: 'Rentabilidad constante supuesta: los mercados reales suben y bajan.'),
      ]);
    });
  }
}
