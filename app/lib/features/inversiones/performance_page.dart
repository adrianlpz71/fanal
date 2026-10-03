import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/charts/charts.dart';
import '../../core/dates.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../gastos/data.dart' show shortDate;
import '../patrimonio/data.dart';
import '../imports/import_wizard.dart' show TutorialLinks, ImportSource;
import 'data.dart' show assetsProvider, assetClassesProvider, portfolioProvider, pct, NoAdviceNote;
import 'panels.dart' show allTxProvider;

/// Inversiones → Rendimiento (antes, en Patrimonio): rentabilidad de la cartera, de una
/// categoría o de un activo. El rediseño completo de esta pantalla es de la fase 3.
class PerformancePage extends ConsumerStatefulWidget {
  const PerformancePage({super.key});

  @override
  ConsumerState<PerformancePage> createState() => _PerformancePageState();
}

class _PerformancePageState extends ConsumerState<PerformancePage> {
  PerfScope _scope = (assetId: null, classId: null);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const FaroAppBar(title: PageTitle('Rendimiento')),
        body: RefreshIndicator(
          onRefresh: () async => refreshAnalytics(ref),
          child: ListView(padding: const EdgeInsets.fromLTRB(12, 8, 12, 32), children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: _ScopePicker(scope: _scope, onChanged: (s) => setState(() => _scope = s)),
            ),
            _PerformanceView(scope: _scope),
            const NoAdviceNote(
              text: 'Cálculos con tus datos. TWR: rentabilidad de las inversiones sin el efecto de cuándo '
                  'aportas. XIRR: tu rentabilidad real anual teniendo en cuenta cuándo pusiste el dinero. '
                  'No es una recomendación de inversión.',
            ),
          ]),
        ),
      );
}

/// Ámbito: toda la cartera, una categoría o un activo (con buscador si hay muchos).
class _ScopePicker extends ConsumerWidget {
  const _ScopePicker({required this.scope, required this.onChanged});
  final PerfScope scope;
  final ValueChanged<PerfScope> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Solo lo que tiene algo que medir: activos con alguna operación (historial) o con posición
    // ahora, y las categorías que tienen alguno de ellos
    final txs = ref.watch(allTxProvider).value ?? const <TxOut>[];
    final pf = ref.watch(portfolioProvider).value;
    final withData = {
      for (final t in txs) t.assetId,
      for (final c in pf?.classes ?? const <ClassOut>[])
        for (final p in c.positions)
          if (dec(p.units) > Decimal.zero || dec(p.pending) > Decimal.zero) p.asset.id,
    };
    final assets = (ref.watch(assetsProvider).value ?? const <AssetOut>[])
        .where((a) => !a.watchlist && withData.contains(a.id))
        .toList();
    final usedClasses = {for (final a in assets) a.assetClassId};
    final classes = (ref.watch(assetClassesProvider).value ?? const <AssetClassOut>[])
        .where((c) => usedClasses.contains(c.id))
        .toList();
    final names = {for (final c in classes) c.id: c.name};
    final value = scope.assetId != null ? 'a:${scope.assetId}' : (scope.classId != null ? 'c:${scope.classId}' : 'all');
    return SelectField<String>(
      key: const Key('perf-scope'),
      label: 'Qué mides',
      value: value,
      options: [
        const SelectOption('all', 'Toda la cartera', icon: Icons.pie_chart_outline),
        for (final c in classes) SelectOption('c:${c.id}', c.name, subtitle: 'Categoría', icon: Icons.folder_outlined),
        for (final a in assets)
          SelectOption('a:${a.id}', a.name, subtitle: names[a.assetClassId] ?? 'Sin categoría', icon: Icons.show_chart),
      ],
      onChanged: (v) {
        if (v == 'all') return onChanged((assetId: null, classId: null));
        final id = v.substring(2);
        onChanged(v.startsWith('a:') ? (assetId: id, classId: null) : (assetId: null, classId: id));
      },
    );
  }
}

class _PerformanceView extends ConsumerWidget {
  const _PerformanceView({required this.scope});
  final PerfScope scope;

  /// Coste total del ámbito (PMP × participaciones): de la cartera, de una categoría o de un activo.
  Decimal? _cost(PortfolioOut? pf) {
    if (pf == null) return null;
    if (scope.assetId != null) {
      for (final c in pf.classes) {
        for (final x in c.positions) {
          if (x.asset.id == scope.assetId) return dec(x.cost);
        }
      }
      return null;
    }
    if (scope.classId != null) {
      final c = pf.classes.where((c) => c.assetClass.id == scope.classId).firstOrNull;
      return c?.positions.fold<Decimal>(Decimal.zero, (s, x) => s + dec(x.cost));
    }
    return dec(pf.cost);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(performanceProvider(scope));
    final pf = ref.watch(portfolioProvider).value;
    return p.when(
      loading: () => const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())),
      error: (e, _) => Text(apiErrorMessage(e)),
      data: (p) {
        final tt = Theme.of(context).textTheme;
        final big = FaroText.kpi(context);
        // Inicio del seguimiento: lo anterior, en un solo bloque
        final before = p.beforeUntil == null
            ? null
            : Card(
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text('Antes del seguimiento (hasta el ${shortDate(p.beforeUntil)} ${p.beforeUntil!.year})'),
                  subtitle: Text('Aportaste ${eur(p.beforeContributed)} · valía ${eur(p.beforeValue)} · '
                      'ganancia ${eur((dec(p.beforeValue) - dec(p.beforeContributed)).toString(), plus: true)}. '
                      'Ese valor es el punto de partida de la rentabilidad.'),
                ),
              );
        if (p.first == null) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ?before,
            const EmptyState(
              icon: Icons.insights_outlined,
              title: 'Aún no hay operaciones para calcular la rentabilidad',
              text: 'Impórtalas desde tu plataforma.',
              secondary: TutorialLinks(sources: [ImportSource.myinvestor, ImportSource.neverless, ImportSource.other]),
            ),
          ]);
        }
        // Las métricas anuales necesitan un año de seguimiento: se dice cuánto falta
        final monthsLeft = ((365 - p.days) / 30.4).ceil();
        final needYear = p.days < 365
            ? 'Disponible cuando lleves 1 año de seguimiento (faltan $monthsLeft ${monthsLeft == 1 ? 'mes' : 'meses'})'
            : 'Sin datos suficientes';
        Widget pctKpi(String label, String? v, {String? info, String? note, bool year = false}) => KpiCard(
              label: label,
              info: info,
              note: note,
              value: v == null ? null : DeltaText(dec(v), style: big),
              unavailable: v == null ? (year ? needYear : 'Sin datos suficientes') : null,
            );
        String m(PerformanceMonthOut x) => '${monthNames[x.month - 1]} ${x.year} (${pct(x.ret, plus: true)})';
        final enoughMonths = p.months.length >= 3;
        final worstPositive = p.worst != null && dec(p.worst!.ret) >= Decimal.zero;
        final start = p.beforeUntil == null ? null : dec(p.beforeValue);
        final cost = _cost(pf);

        // Mapa año × mes y total de cada año (rentabilidades encadenadas)
        final cells = <int, Map<int, HeatCell>>{};
        final yearProduct = <int, double>{};
        for (final x in p.months) {
          final r = x.ret == null ? null : dec(x.ret).toDouble();
          cells.putIfAbsent(x.year, () => {})[x.month] =
              HeatCell(ret: r, gain: dec(x.gain).toDouble(), contributed: dec(x.netFlow).toDouble());
          if (r != null) yearProduct[x.year] = (yearProduct[x.year] ?? 1) * (1 + r);
        }

        Widget question(String title, List<Widget> kpis) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SectionHeader(title, padding: const EdgeInsets.fromLTRB(Space.xs, Space.lg, Space.xs, Space.sm)),
                KpiGrid(minWidth: 170, children: kpis),
              ],
            );

        final kpis = [
          Text(p.beforeUntil == null
              ? 'Desde el ${shortDate(p.first)} ${p.first!.year} · ${spanText(p.days)} invirtiendo'
              : 'Seguimiento desde el ${shortDate(p.first)} ${p.first!.year} · ${spanText(p.days)}'),
          if (before != null) ...[const SizedBox(height: Space.sm), before],
          question('¿Cuánto he ganado?', [
            KpiCard(label: 'Valor', value: MoneyText.api(p.value, compact: true, style: big), emphasis: true),
            KpiCard(label: 'Ganancia', value: MoneyText.api(p.gain, plus: true, colored: true, style: big)),
            pctKpi('Rentabilidad acumulada', p.twr, info: 'twr', note: 'Lo que ha hecho la cartera'),
            if (start != null)
              KpiCard(
                label: 'Valor al empezar el seguimiento',
                value: MoneyText(start, compact: true, style: big),
                note: fullDate(p.beforeUntil!.add(const Duration(days: 1))),
              ),
            KpiCard(
              label: start != null ? 'Aportado desde entonces' : 'Aportado',
              value: MoneyText(start != null ? dec(p.contributed) - start : dec(p.contributed), compact: true, style: big),
            ),
            KpiCard(
              label: 'Coste total',
              info: 'pmp',
              value: cost == null ? null : MoneyText(cost, compact: true, style: big),
              unavailable: cost == null ? 'Sin posición ahora' : null,
              note: 'Participaciones × PMP',
            ),
          ]),
          question('¿Qué tal va al año?', [
            pctKpi('Tu rentabilidad anual real', p.xirr, info: 'xirr', note: 'XIRR: cuenta cuándo aportaste'),
            pctKpi('Rentabilidad anual de la cartera', p.twrAnnual,
                info: 'twr', note: 'TWR anual: sin contar cuándo aportas', year: true),
            pctKpi('Este año', p.ytd),
          ]),
          question('¿Cuánto riesgo?', [
            pctKpi('Máxima caída', p.maxDrawdown, info: 'drawdown'),
            // Neutra: no es ni ganancia ni pérdida
            KpiCard(
              label: 'Volatilidad anual',
              info: 'volatility',
              valueText: p.volatility == null ? null : pct(p.volatility),
              unavailable: p.volatility == null ? needYear : null,
            ),
          ]),
          question('Meses', [
            KpiCard(label: 'Meses + / −', valueText: '${p.positiveMonths} / ${p.negativeMonths}'),
            KpiCard(
              label: 'Mejor mes',
              valueText: enoughMonths && p.best != null ? m(p.best!) : null,
              unavailable: enoughMonths ? null : 'Con 3 meses o más',
            ),
            KpiCard(
              label: worstPositive ? 'Mes más flojo' : 'Peor mes',
              valueText: enoughMonths && p.worst != null ? m(p.worst!) : null,
              unavailable: enoughMonths ? null : 'Con 3 meses o más',
            ),
          ]),
        ];
        final charts = [
          _ValueChart(series: p.series),
          if (cells.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Space.lg),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
                  Text('Rentabilidad por mes', style: tt.titleMedium),
                  MonthHeatmap(
                    cells: cells,
                    yearTotals: {for (final e in yearProduct.entries) e.key: e.value - 1},
                  ),
                  Text('Verde, mes en positivo; rojo, en negativo. Pasa el ratón o mantén pulsado para ver el detalle.',
                      style: FaroText.caption(context)),
                ]),
              ),
            ),
          Card(
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                key: const Key('months-table'),
                title: Text('Por mes (${p.months.length})', style: tt.titleMedium),
                children: [
                  for (final x in p.months.reversed)
                    ListRow(
                      title: '${monthNames[x.month - 1]} ${x.year} · ${eur(x.endValue)}',
                      subtitle: 'Aportado ${eur(x.netFlow, plus: true)} · ganancia ${eur(x.gain, plus: true)}'
                          '${x.cumulative != null ? ' · acumulada ${pct(x.cumulative, plus: true)}' : ''}',
                      trailing: DeltaText(x.ret == null ? null : dec(x.ret)),
                    ),
                ],
              ),
            ),
          ),
        ];
        // En pantallas anchas, dos columnas: las cifras a la izquierda y las gráficas a la derecha
        return LayoutBuilder(
          builder: (context, box) => box.maxWidth >= 1100
              ? Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.xl, children: [
                  Expanded(
                    flex: 5,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: kpis),
                  ),
                  Expanded(
                    flex: 6,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const SizedBox(height: Space.lg),
                      ...charts,
                    ]),
                  ),
                ])
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  ...kpis,
                  const SizedBox(height: Space.md),
                  ...charts,
                ]),
        );
      },
    );
  }
}

class _ValueChart extends StatelessWidget {
  const _ValueChart({required this.series});
  final List<SeriesPointOut> series;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 16, 8),
        child: FaroLineChart(
          periods: true,
          series: [
            ChartSeries(
              id: 'value',
              label: 'Valor',
              color: cs.primary,
              area: true,
              points: [for (final p in series) ChartPoint.at(p.date, dec(p.value).toDouble())],
            ),
            ChartSeries(
              id: 'contributed',
              label: 'Aportado (la diferencia es la ganancia)',
              color: cs.outline,
              width: 1.5,
              dashed: true,
              stepped: true,
              points: [for (final p in series) ChartPoint.at(p.date, dec(p.contributed).toDouble())],
            ),
          ],
        ),
      ),
    );
  }
}
