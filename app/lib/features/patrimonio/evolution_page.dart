import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/charts/charts.dart';
import '../../core/dates.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import 'data.dart';

enum _View { total, components, market, share }

/// Patrimonio → Evolución: total, por componente, tu dinero frente al mercado y reparto en %.
class EvolutionPage extends ConsumerStatefulWidget {
  const EvolutionPage({super.key});

  @override
  ConsumerState<EvolutionPage> createState() => _EvolutionPageState();
}

class _EvolutionPageState extends ConsumerState<EvolutionPage> {
  _View _view = _View.total;

  static const _explain = {
    _View.total: 'Áreas: tus cuentas y tu cartera. Línea: el patrimonio neto (más lo que te deben, menos deudas '
        'y fraccionadas).',
    _View.components: 'Cada cuenta e inversión, una encima de otra. Pulsa la leyenda para ocultar una.',
    _View.market: 'Lo que vale tu cartera frente a lo que has puesto. La diferencia es lo que ha hecho el mercado.',
    _View.share: 'Qué parte de lo que tienes está en cada cuenta e inversión.',
  };

  @override
  Widget build(BuildContext context) {
    final ev = ref.watch(evolutionProvider);
    return Scaffold(
      appBar: const FaroAppBar(title: PageTitle('Evolución')),
      body: RefreshIndicator(
        onRefresh: () async => refreshAnalytics(ref),
        child: ev.when(
          loading: () => const SkeletonPage(kpis: 0),
          error: (e, _) => Center(child: Text(apiErrorMessage(e))),
          data: (ev) => ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.xl), children: [
            SegmentedField<_View>(
              buttonKey: const Key('evolution-view'),
              segments: const [
                Segment(_View.total, 'Total'),
                Segment(_View.components, 'Por componente'),
                Segment(_View.market, 'Tu dinero vs mercado'),
                Segment(_View.share, 'Reparto %'),
              ],
              value: _view,
              onChanged: (v) => setState(() => _view = v),
            ),
            const SizedBox(height: Space.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(Space.md),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
                  KeyedSubtree(key: ValueKey(_view), child: _chart(context, ev)),
                  Text(_explain[_view]!, style: FaroText.caption(context)),
                ]),
              ),
            ),
            _Notes(ev: ev),
          ]),
        ),
      ),
    );
  }

  Widget _chart(BuildContext context, NetWorthEvolutionOut ev) {
    final cs = Theme.of(context).colorScheme;
    final pts = ev.points;
    ChartPoint at(EvolutionPointOut p, String v) => ChartPoint.at(p.date, dec(v).toDouble());
    const empty = 'La evolución sale cuando haya al menos dos puntos';
    final height = context.isWide ? 340.0 : 260.0;
    switch (_view) {
      case _View.total:
        return FaroLineChart(
          height: height,
          stacked: true,
          periods: true,
          emptyText: empty,
          series: [
            ChartSeries(id: 'accounts', label: 'Cuentas', color: cs.tertiary, points: [for (final p in pts) at(p, p.accounts)]),
            ChartSeries(
              id: 'investments',
              label: 'Inversiones',
              color: cs.primary,
              points: [for (final p in pts) at(p, p.investments)],
            ),
            ChartSeries(
              id: 'net',
              label: 'Patrimonio neto',
              color: cs.onSurface,
              overlay: true,
              width: 2,
              points: [for (final p in pts) at(p, p.net)],
            ),
          ],
        );
      case _View.components:
        final palette = context.faro.seriesForAll(ev.components.map((c) => c.key));
        return FaroLineChart(
          height: height,
          stacked: true,
          periods: true,
          emptyText: empty,
          series: [
            for (final c in ev.components)
              ChartSeries(
                id: c.key,
                label: c.label,
                color: palette[c.key],
                points: [for (final p in pts) at(p, p.components[c.key] ?? '0')],
              ),
          ],
        );
      case _View.market:
        final inv = [for (final p in pts) if (dec(p.investments).sign != 0 || dec(p.contributed).sign != 0) p];
        return FaroLineChart(
          height: height,
          periods: true,
          emptyText: 'Sale cuando tengas inversiones con al menos dos puntos',
          bands: const [('value', 'contributed')],
          series: [
            ChartSeries(id: 'value', label: 'Valor', color: cs.primary, points: [for (final p in inv) at(p, p.investments)]),
            ChartSeries(
              id: 'contributed',
              label: 'Aportado',
              color: cs.outline,
              dashed: true,
              stepped: true,
              width: 1.5,
              points: [for (final p in inv) at(p, p.contributed)],
            ),
          ],
        );
      case _View.share:
        // Porcentaje de lo que tienes (sin restar deudas) en cada componente
        final totals = [
          for (final p in pts)
            ev.components.fold<double>(0, (s, c) => s + dec(p.components[c.key] ?? '0').toDouble().clamp(0, double.infinity)),
        ];
        String pctFmt(double v) => '${withMinus(v.toStringAsFixed(0))} %';
        final palette = context.faro.seriesForAll(ev.components.map((c) => c.key));
        return FaroLineChart(
          height: height,
          stacked: true,
          periods: true,
          emptyText: empty,
          yFormat: pctFmt,
          valueFormat: (v) => '${withMinus(v.toStringAsFixed(1).replaceAll('.', ','))} %',
          series: [
            for (final c in ev.components)
              ChartSeries(
                id: c.key,
                label: c.label,
                color: palette[c.key],
                points: [
                  for (final (i, p) in pts.indexed)
                    if (totals[i] > 0)
                      ChartPoint.at(
                        p.date,
                        dec(p.components[c.key] ?? '0').toDouble().clamp(0, double.infinity) / totals[i] * 100,
                      ),
                ],
              ),
          ],
        );
    }
  }
}

/// Desde cuándo es la serie y "cómo se calcula" en un ⓘ (con el porqué del punto por ciclo).
class _Notes extends StatelessWidget {
  const _Notes({required this.ev});
  final NetWorthEvolutionOut ev;

  @override
  Widget build(BuildContext context) {
    final caption = FaroText.caption(context);
    final how = [
      'Los saldos de las cuentas se reconstruyen hacia atrás desde el de hoy (el mismo de Resumen). Antes del '
          'primer movimiento de una cuenta, su saldo sale constante.',
      'Los traspasos a tus cuentas de ahorro que hiciste antes de darlas de alta en Fanal no cambian el total: '
          'ese dinero ya estaba en tu saldo. Los que fueron a inversión sí salen de las cuentas.',
      'Se ve todo el histórico aunque hayas fijado el inicio del seguimiento: esa fecha solo cambia cómo se '
          'mide la rentabilidad en Inversiones.',
      if (ev.perCycleUntil != null)
        'Hasta ${monthYear(ev.perCycleUntil!)} hay un punto por ciclo: los movimientos importados del Excel no '
            'tienen fecha, así que cada punto es lo que había al cerrar el ciclo. Después, uno por semana.',
    ].join('\n\n');
    return Padding(
      padding: const EdgeInsets.fromLTRB(Space.xs, Space.md, Space.xs, 0),
      child: Wrap(spacing: Space.xs, crossAxisAlignment: WrapCrossAlignment.center, children: [
        if (ev.start != null) Text('Desde el ${fullDate(ev.start!)}', style: caption),
        if (ev.perCycleUntil != null) Text('· hasta ${monthYear(ev.perCycleUntil!)}, un punto por ciclo', style: caption),
        Text('· Cómo se calcula', style: caption),
        InfoTip('evolucion', title: 'Cómo se calcula la evolución', text: how, size: 16),
      ]),
    );
  }
}
