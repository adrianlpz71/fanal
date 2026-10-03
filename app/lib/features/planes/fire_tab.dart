import 'dart:math' as math;

import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/charts/charts.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../inversiones/data.dart' show pct, fractionFromPct, NoAdviceNote;
import 'data.dart';
import 'fire_form.dart';

/// Planes → Independencia: supuestos arriba (editables), la respuesta en una frase, tres
/// preguntas, Coast FIRE, la proyección, "Cómo se calcula", recortes y Monte Carlo.
class FireTab extends ConsumerWidget {
  const FireTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ref.watch(fireSettingsProvider).when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (st) => st.configured ? const _FireView() : FireForm(settings: st, firstTime: true),
      );
}

/// Edad con decimales → años enteros para el eje y las marcas.
double _age(String? a) => a == null ? double.nan : double.parse(a); // solo para dibujar, no es dinero

class _FireView extends ConsumerWidget {
  const _FireView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(firePlanProvider).when(
          loading: () => const SkeletonPage(),
          error: (e, _) => Center(child: Padding(padding: const EdgeInsets.all(Space.xl), child: Text(apiErrorMessage(e)))),
          data: (f) {
            final b = f.base_;
            final st = f.settings;
            final target = st.targetAge;
            final big = FaroText.kpi(context);
            final auto = st.contributionOverride == null;
            return RefreshIndicator(
              onRefresh: () async => refreshPlanes(ref),
              child: ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.xl), children: [
                _Assumptions(plan: f),
                const SizedBox(height: Space.md),
                _Answer(plan: f),
                const SizedBox(height: Space.sm),
                _Questions(children: [
                  KpiCard(
                    key: const Key('q-when'),
                    label: '¿Cuándo llego al ritmo actual?',
                    value: Text(b.fiAge == null ? 'No antes de los 100' : 'A los ${ageText(b.fiAge)}', style: big),
                    note: 'Aportando ${eur(f.monthlyContribution)}/mes'
                        '${auto && f.cyclesUsed > 0 ? ' (media de tus últimos ${f.cyclesUsed} ciclos)' : ''}',
                  ),
                  KpiCard(
                    key: const Key('q-how-much'),
                    label: '¿Cuánto tendría que aportar para llegar a los $target?',
                    value: Text('${MoneyText.format(dec(b.requiredMonthly), compact: true)}/mes', style: big),
                    info: 'real',
                    note: 'Con una rentabilidad real de ${pct(b.realReturn)} al año',
                  ),
                  KpiCard(
                    key: const Key('q-taxes'),
                    label: '¿Cuánto pagaré de impuestos al retirar?',
                    value: dec(f.taxAnnual).sign > 0
                        ? Text('${MoneyText.format(dec(f.taxAnnual), compact: true)}/año', style: big)
                        : null,
                    unavailable: !st.includeTaxes
                        ? 'No los tienes en cuenta (Supuestos)'
                        : (dec(f.taxAnnual).sign > 0 ? null : 'Nada: no habría ganancia que tribute'),
                    note: dec(f.taxAnnual).sign > 0
                        ? 'Retirarías ${eur(f.grossAnnual)}/año en bruto para que te queden '
                            '${eur((dec(st.monthlySpend) * Decimal.fromInt(12)).toString())} netos'
                            '${f.gainRatio == null ? '' : ' (ganancia supuesta: ${pct(f.gainRatio, decimals: 0)} de lo que retiras)'}'
                        : null,
                  ),
                ]),
                _Coast(plan: f),
                _Projection(plan: f),
                const _HowItWorks(),
                // En ancho, recortes y Monte Carlo lado a lado
                LayoutBuilder(
                  builder: (context, box) => box.maxWidth >= 900
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.sm, children: [
                          Expanded(child: _Cuts(plan: f)),
                          const Expanded(child: MonteCarloCard()),
                        ])
                      : Column(children: [_Cuts(plan: f), const MonteCarloCard()]),
                ),
                const SizedBox(height: Space.sm),
                Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
                  OutlinedButton.icon(
                    key: const Key('open-assumptions'),
                    icon: const Icon(Icons.tune),
                    label: const Text('Todos los supuestos'),
                    onPressed: () => context.go('/planes/independencia/supuestos'),
                  ),
                  FilledButton.tonalIcon(
                    key: const Key('open-compare'),
                    icon: const Icon(Icons.compare_arrows),
                    label: const Text('Comparar otro supuesto'),
                    onPressed: () => context.go('/planes/independencia/comparar'),
                  ),
                ]),
                NoAdviceNote(
                  text: 'Todo en euros de hoy. Supuestos tuyos (${pct(st.swr)} de retiro, ${pct(st.nominalReturn)} '
                      'de rentabilidad, ${pct(st.inflation)} de inflación): cálculos, no una recomendación.',
                ),
              ]),
            );
          },
        );
  }
}

/// Supuestos arriba como píldoras: se tocan para cambiarlos sin ir al formulario entero.
class _Assumptions extends ConsumerWidget {
  const _Assumptions({required this.plan});
  final FirePlanOut plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = plan.settings;
    final auto = st.contributionOverride == null;
    return Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
      EditChip(
        key: const Key('chip-spend'),
        label: 'Gasto',
        value: '${eur(st.monthlySpend)}/mes',
        onTap: () => _edit(context, ref, _Edit.spend, plan),
      ),
      EditChip(
        key: const Key('chip-age'),
        label: 'A los',
        value: '${st.targetAge}',
        onTap: () => _edit(context, ref, _Edit.age, plan),
      ),
      EditChip(label: 'Retiro', value: pct(st.swr), onTap: () => _edit(context, ref, _Edit.swr, plan)),
      EditChip(label: 'Rentabilidad', value: pct(st.nominalReturn), onTap: () => _edit(context, ref, _Edit.ret, plan)),
      EditChip(label: 'Inflación', value: pct(st.inflation), onTap: () => _edit(context, ref, _Edit.inf, plan)),
      EditChip(
        key: const Key('chip-contribution'),
        label: 'Aporto',
        value: '${eur(plan.monthlyContribution)}/mes',
        note: auto ? 'auto' : null,
        onTap: () => _edit(context, ref, _Edit.contribution, plan),
      ),
    ]);
  }
}

enum _Edit { spend, age, swr, ret, inf, contribution }

Future<void> _edit(BuildContext context, WidgetRef ref, _Edit what, FirePlanOut plan) =>
    showFormPanel<void>(context, builder: (_) => _QuickEdit(what: what, plan: plan));

/// Cambiar un supuesto suelto (y, en la aportación, volver a lo automático).
class _QuickEdit extends ConsumerStatefulWidget {
  const _QuickEdit({required this.what, required this.plan});
  final _Edit what;
  final FirePlanOut plan;

  @override
  ConsumerState<_QuickEdit> createState() => _QuickEditState();
}

class _QuickEditState extends ConsumerState<_QuickEdit> {
  late final st = widget.plan.settings;
  late final _c = TextEditingController(
    text: switch (widget.what) {
      _Edit.spend => dec(st.monthlySpend).toStringAsFixed(0),
      _Edit.age => '${st.targetAge}',
      _Edit.swr => pctText(st.swr),
      _Edit.ret => pctText(st.nominalReturn),
      _Edit.inf => pctText(st.inflation),
      _Edit.contribution => dec(widget.plan.monthlyContribution).toStringAsFixed(0),
    },
  );
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _save({bool backToAuto = false}) async {
    final t = _c.text;
    final body = switch (widget.what) {
      _Edit.spend => FireSettingsIn(monthlySpend: parseEsDecimal(t) == null ? null : apiAmount(parseEsDecimal(t)!)),
      _Edit.age => FireSettingsIn(targetAge: int.tryParse(t)),
      _Edit.swr => FireSettingsIn(swr: fractionFromPct(t)),
      _Edit.ret => FireSettingsIn(nominalReturn: fractionFromPct(t)),
      _Edit.inf => FireSettingsIn(inflation: fractionFromPct(t)),
      _Edit.contribution => backToAuto
          ? FireSettingsIn(clearContributionOverride: true)
          : FireSettingsIn(contributionOverride: parseEsDecimal(t) == null ? null : apiAmount(parseEsDecimal(t)!)),
    };
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiProvider).getPlanesApi().putFireSettings(fireSettingsIn: body);
      refreshPlanes(ref);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.plan;
    final (String title, Widget field) = switch (widget.what) {
      _Edit.spend => (
          'Gasto mensual deseado',
          MoneyField(label: 'Gasto mensual', controller: _c, suffix: '€/mes', autofocus: true,
              helper: 'Neto y en euros de hoy'),
        ),
      _Edit.age => (
          'Edad objetivo',
          UnitsField(label: 'Edad objetivo', controller: _c, integer: true, suffix: 'años'),
        ),
      _Edit.swr => (
          'Tasa de retiro',
          PercentField(label: 'Tasa de retiro', controller: _c, helper: '4 % es la referencia clásica'),
        ),
      _Edit.ret => ('Rentabilidad anual', PercentField(label: 'Rentabilidad anual (nominal)', controller: _c)),
      _Edit.inf => ('Inflación', PercentField(label: 'Inflación', controller: _c)),
      _Edit.contribution => (
          'Aportación mensual',
          MoneyField(label: 'Aportación mensual', controller: _c, suffix: '€/mes',
              helper: 'Automático: ${eur(p.contributionAuto)}/mes (media de ${p.cyclesUsed} ciclos)'),
        ),
    };
    return FormPanel(
      title: title,
      onSubmit: _busy ? null : _save,
      actions: FormActions(
        primaryLabel: 'Guardar',
        busy: _busy,
        onPrimary: _save,
        expand: context.isCompact,
        secondary: [
          if (widget.what == _Edit.contribution && p.settings.contributionOverride != null)
            TextButton(onPressed: () => _save(backToAuto: true), child: const Text('Volver a automático')),
        ],
      ),
      children: [field, if (_error != null) ErrorText(_error)],
    );
  }
}

/// La respuesta en una frase y la barra de progreso.
class _Answer extends StatelessWidget {
  const _Answer({required this.plan});
  final FirePlanOut plan;

  @override
  Widget build(BuildContext context) {
    final b = plan.base_;
    final st = plan.settings;
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
          Text.rich(
            TextSpan(style: tt.titleMedium, children: [
              const TextSpan(text: 'Necesitas '),
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: MoneyText.api(b.needed, key: const Key('fire-needed'), compact: true,
                    style: FaroText.kpi(context)),
              ),
              TextSpan(text: ' (euros de hoy) para vivir con ${eur(st.monthlySpend)}/mes netos a los ${st.targetAge}.'),
            ]),
          ),
          Text('${_big(b.neededNominal)} en euros de cuando tengas ${st.targetAge} años'
              '${dec(b.bridge).sign > 0 ? ' · incluye ${eur(b.bridge)} de puente hasta la pensión' : ''}',
              style: FaroText.caption(context)),
          ClipRRect(
            borderRadius: BorderRadius.circular(Radii.sm),
            child: LinearProgressIndicator(value: dec(b.progress).toDouble().clamp(0, 1), minHeight: 10),
          ),
          Text('Llevas ${_big(plan.capital)} · ${pct(b.progress, decimals: 1)}'
              '${plan.settings.capitalOverride == null ? '' : ' (capital puesto a mano)'}'),
        ]),
      ),
    );
  }
}

/// Las tres preguntas: una debajo de otra en el móvil; en fila a partir de tablet.
class _Questions extends StatelessWidget {
  const _Questions({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, box) => box.maxWidth < 600
            ? Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: children)
            : IntrinsicHeight(
                child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
                  for (final c in children) Expanded(child: c),
                ]),
              ),
      );
}

String _big(String? amount) => MoneyText.format(dec(amount), compact: true);

class _Coast extends StatelessWidget {
  const _Coast({required this.plan});
  final FirePlanOut plan;

  @override
  Widget build(BuildContext context) {
    final b = plan.base_;
    final target = plan.settings.targetAge;
    return Card(
      child: ListTile(
        key: const Key('coast'),
        leading: Icon(b.coastReached ? Icons.check_circle : Icons.sailing_outlined,
            color: b.coastReached ? context.faro.gain : null),
        title: Row(spacing: Space.xs, children: [
          const Flexible(child: Text('Coast FIRE')),
          const InfoTip('coast', size: 16),
        ]),
        subtitle: Text(b.coastReached
            ? 'Ya lo tienes: aunque no aportes ni un euro más, llegarías a los $target.'
            : 'Si hoy tuvieras ${_big(b.coast)}, sin aportar más llegarías a los $target.'),
      ),
    );
  }
}

/// Proyección: banda pesimista–optimista, la base, lo que necesitas y las marcas de las edades.
class _Projection extends StatelessWidget {
  const _Projection({required this.plan});
  final FirePlanOut plan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final target = plan.settings.targetAge.toDouble();
    final fi = _age(plan.base_.fiAge);
    // Hasta la mayor de (edad objetivo, edad estimada) + 5
    final until = (fi.isNaN ? target : math.max(target, fi)) + 5;
    final pts = plan.projection.where((p) => _age(p.age) <= until).toList();
    ChartPoint at(ProjectionPointOut p, String v) => ChartPoint(_age(p.age), dec(v).toDouble());
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.md),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
          Text('Proyección (euros de hoy)', style: Theme.of(context).textTheme.titleMedium),
          FaroLineChart(
            height: context.isWide ? 300 : 240,
            valueFormat: (v) => privacyMode ? '•••' : MoneyText.format(Decimal.parse(v.toStringAsFixed(2)), compact: true),
            xAxis: ChartXAxis.numeric(format: (v) => '${v.round()}', interval: 5),
            includeZero: true,
            bands: const [('pessimistic', 'optimistic')],
            horizontalMarkers: [ChartMarker(dec(plan.base_.needed).toDouble(), 'Necesitas', color: cs.outline)],
            verticalMarkers: [
              ChartMarker(target, 'Objetivo ${target.round()}', color: cs.outline),
              if (!fi.isNaN && (fi - target).abs() >= 0.5)
                ChartMarker(fi, 'Llegas ~${fi.round()}', color: context.faro.gain),
            ],
            // Dónde el escenario base alcanza lo que necesitas
            dots: [if (!fi.isNaN) ChartDot(fi, dec(plan.base_.needed).toDouble(), color: context.faro.gain)],
            series: [
              ChartSeries(id: 'pessimistic', label: 'Pesimista', color: cs.primary, width: 0.8,
                  showInLegend: false, points: [for (final p in pts) at(p, p.pessimistic)]),
              ChartSeries(id: 'base', label: pts.isEmpty ? 'Base' : 'Escenario base a los ${_age(pts.last.age).round()}',
                  color: cs.primary, width: 3,
                  points: [for (final p in pts) at(p, p.base_)]),
              ChartSeries(id: 'optimistic', label: 'Optimista', color: cs.primary, width: 0.8,
                  showInLegend: false, points: [for (final p in pts) at(p, p.optimistic)]),
            ],
          ),
          Text('La banda va del escenario pesimista al optimista (rentabilidad esperada ∓ 2 puntos). '
              'La línea discontinua es lo que necesitas.', style: FaroText.caption(context)),
        ]),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const steps = [
      ('Lo que necesitas', 'Tu gasto anual dividido entre la tasa de retiro (con un 4 %, 25 veces el gasto). Si '
          'cuentas con pensión, se resta lo que cubre a partir de su edad y se suma el puente hasta entonces. Con '
          'impuestos, se calcula lo que hay que retirar en bruto para que te quede el gasto.'),
      ('Rentabilidad real', 'La rentabilidad esperada menos los costes, descontada la inflación: lo que crece tu '
          'poder de compra cada año. Todo se calcula en euros de hoy.'),
      ('Cuándo llegas', 'Tu capital crece cada año a la rentabilidad real y le sumas tu aportación mensual. La edad '
          'es el primer momento en que alcanza lo que necesitas.'),
      ('Coast FIRE', 'El capital que, sin aportar más, crecería solo hasta lo que necesitas a tu edad objetivo.'),
    ];
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: const Key('how-it-works'),
          title: Text('Cómo se calcula', style: tt.titleMedium),
          childrenPadding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (t, x) in steps)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.sm),
                child: Text.rich(TextSpan(children: [
                  TextSpan(text: '$t. ', style: const TextStyle(fontWeight: FontWeight.w600)),
                  TextSpan(text: x),
                ])),
              ),
          ],
        ),
      ),
    );
  }
}

/// Si recortas gastos: cuántos años antes llegarías con cada recorte.
class _Cuts extends StatelessWidget {
  const _Cuts({required this.plan});
  final FirePlanOut plan;

  @override
  Widget build(BuildContext context) {
    final base = _age(plan.base_.fiAge);
    final rows = [
      for (final c in plan.cutEffect)
        (c, base.isNaN || c.fiAge == null ? null : base - _age(c.fiAge)),
    ];
    if (rows.isEmpty) return const SizedBox.shrink();
    final most = rows.map((r) => r.$2 ?? 0).fold<double>(0.01, math.max);
    String years(double y) {
      final months = (y * 12).round();
      if (months < 12) return '$months ${months == 1 ? 'mes' : 'meses'} antes';
      final yy = months ~/ 12, mm = months % 12;
      return '$yy ${yy == 1 ? 'año' : 'años'}${mm == 0 ? '' : ' y $mm ${mm == 1 ? 'mes' : 'meses'}'} antes';
    }

    return Card(
      key: const Key('cuts'),
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
          Text('Si recortas gastos', style: Theme.of(context).textTheme.titleMedium),
          Text('Necesitas menos y ahorras más cada mes.', style: FaroText.caption(context)),
          BarList(items: [
            for (final (c, y) in rows)
              BarItem(
                label: '−${eur(c.cut)}/mes',
                value: y == null ? 'llegas con ${ageText(c.fiAge)}' : years(y),
                fraction: (y ?? 0) / most,
                detail: c.fiAge == null ? null : 'Llegarías con ${ageText(c.fiAge)}',
                color: context.faro.gain,
              ),
          ]),
        ]),
      ),
    );
  }
}

/// Monte Carlo: probabilidad de éxito con un semáforo, una línea de explicación y la banda.
class MonteCarloCard extends ConsumerStatefulWidget {
  const MonteCarloCard({super.key});

  @override
  ConsumerState<MonteCarloCard> createState() => _MonteCarloCardState();
}

class _MonteCarloCardState extends ConsumerState<MonteCarloCard> {
  MonteCarloOut? _r;
  bool _busy = false;
  String? _error;

  Future<void> _run() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await ref.read(apiProvider).getPlanesApi().montecarlo(fireSettingsIn: FireSettingsIn());
      setState(() => _r = r.data);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = _r;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final success = r == null ? null : dec(r.success);
    final (String light, PillTone tone) = success == null
        ? ('', PillTone.neutral)
        : success >= dec('0.8')
            ? ('Bien encaminado', PillTone.ok)
            : success >= dec('0.5')
                ? ('Con riesgo', PillTone.warning)
                : ('Poco probable', PillTone.above);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
          Text('¿Y si los mercados van a trompicones?', style: tt.titleMedium),
          Text('Monte Carlo: 2.000 simulaciones con una rentabilidad distinta cada año, en vez de la misma siempre.',
              style: FaroText.caption(context)),
          if (r == null)
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.tonalIcon(
                key: const Key('run-montecarlo'),
                icon: _busy
                    ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.casino_outlined),
                label: const Text('Calcular probabilidad'),
                onPressed: _busy ? null : _run,
              ),
            ),
          ErrorText(_error),
          if (r != null) ...[
            Wrap(spacing: Space.sm, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text('${pct(r.success, decimals: 0)} de éxito', key: const Key('mc-success'), style: FaroText.kpi(context)),
              StatusPill(light, tone: tone),
            ]),
            Text('Retirándote a los ${r.targetAge}, el dinero te dura hasta los ${r.horizonAge} en '
                '${pct(r.success, decimals: 0)} de los escenarios. Llegas al capital necesario a tiempo en '
                '${pct(r.reach, decimals: 0)} de ellos.'),
            Text('Lo tendrías a los ${r.fiAgeP10 ?? '—'} si va bien, a los ${r.fiAgeP50 ?? 'más de ${r.horizonAge}'} '
                'en lo típico y a los ${r.fiAgeP90 ?? 'más de ${r.horizonAge}'} si va mal'
                '${r.depletionMedianAge == null ? '.' : '. Cuando sale mal, el dinero se suele acabar hacia los ${r.depletionMedianAge}.'}'),
            FaroLineChart(
              height: 220,
              xAxis: ChartXAxis.numeric(format: (v) => '${v.round()}', interval: 10),
              includeZero: true,
              bands: const [('p10', 'p90')],
              series: [
                ChartSeries(id: 'p10', label: '10 % peor', color: cs.primary, width: 0.8, showInLegend: false,
                    points: [for (final b in r.bands) ChartPoint(b.age.toDouble(), dec(b.p10).toDouble())]),
                ChartSeries(id: 'p50', label: 'Escenario típico', color: cs.primary, width: 2.5,
                    points: [for (final b in r.bands) ChartPoint(b.age.toDouble(), dec(b.p50).toDouble())]),
                ChartSeries(id: 'p90', label: '10 % mejor', color: cs.primary, width: 0.8, showInLegend: false,
                    points: [for (final b in r.bands) ChartPoint(b.age.toDouble(), dec(b.p90).toDouble())]),
              ],
            ),
            Text('Banda: del 10 % peor al 10 % mejor de los escenarios. Volatilidad supuesta: '
                '${pct(r.volatility, decimals: 0)} al año.', style: FaroText.caption(context)),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(onPressed: _busy ? null : _run, child: const Text('Recalcular')),
            ),
          ],
        ]),
      ),
    );
  }
}
