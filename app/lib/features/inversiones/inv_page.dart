import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/charts/charts.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../patrimonio/data.dart' show performanceProvider;
import 'data.dart';
import 'prices.dart';
import 'setup_page.dart';
import 'tx_sheet.dart';

/// Inversiones → Cartera (docs/06-rediseno-ui.md §4.2): KPI, asignación frente a objetivos, activos
/// por categoría, evolución, fondo de emergencia y pendientes de VL.
class InvestmentsPage extends ConsumerWidget {
  const InvestmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(invSettingsProvider);
    return s.when(
      loading: () => const Scaffold(body: SkeletonPage()),
      error: (e, _) => Scaffold(body: Center(child: Text(apiErrorMessage(e)))),
      data: (st) => st.configured ? const _Dashboard() : const InvSetupPage(),
    );
  }
}

class _Dashboard extends ConsumerWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(portfolioProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Cartera'), actions: [
        if (context.isCompact) const PricesStatus(compact: true),
        BarAction(
          key: const Key('open-contribution'),
          icon: Icons.call_split,
          label: 'Aportar',
          tonal: true,
          onPressed: () => context.go('/inversiones/aportar'),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-tx'),
        icon: const Icon(Icons.add),
        label: const Text('Operación'),
        onPressed: () => showTxSheet(context, ref),
      ),
      body: p.when(
        loading: () => const SkeletonPage(kpis: 4),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (pf) => RefreshIndicator(
          onRefresh: () async => refreshInv(ref),
          child: LayoutBuilder(builder: (context, box) {
            final main = _mainColumn(context, ref, pf);
            final side = _sideColumn(context, ref, pf);
            if (box.maxWidth < 1000) {
              return ListView(
                padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 96),
                children: [..._top(context, ref, pf), ...side, ...main, const NoAdviceNote()],
              );
            }
            // Escritorio: activos a la izquierda y evolución, emergencia y pendientes a la derecha
            return ListView(
              padding: const EdgeInsets.fromLTRB(Space.lg, Space.sm, Space.lg, 96),
              children: [
                ..._top(context, ref, pf),
                Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.lg, children: [
                  Expanded(flex: 6, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: main)),
                  Expanded(flex: 5, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: side)),
                ]),
                const NoAdviceNote(),
              ],
            );
          }),
        ),
      ),
    );
  }

  List<Widget> _top(BuildContext context, WidgetRef ref, PortfolioOut pf) {
    final targets = ref.watch(targetsProvider).value;
    return [
      if (pf.stale > 0)
        Card(
          color: context.faro.warningContainer,
          child: ListTile(
            leading: Icon(Icons.update, color: context.faro.warning),
            title: Text('${pf.stale} ${pf.stale == 1 ? 'precio' : 'precios'} sin actualizar'),
            subtitle: const Text('Las fuentes no han dado un precio reciente. Se usa el último conocido.'),
            trailing: TextButton(onPressed: () => refreshPrices(context, ref), child: const Text('Reintentar')),
          ),
        ),
      if (targets != null && targets.macro.isEmpty)
        Card(
          child: ListTile(
            leading: const Icon(Icons.track_changes),
            title: const Text('Define los objetivos de tu cartera'),
            subtitle: const Text('Con ellos Fanal calcula los pesos y cómo repartir cada aportación.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/inversiones/objetivos'),
          ),
        ),
      _Kpis(p: pf),
      const SizedBox(height: Space.md),
    ];
  }

  List<Widget> _mainColumn(BuildContext context, WidgetRef ref, PortfolioOut pf) {
    final classes = pf.classes.where(showClass).toList();
    final platforms = {for (final p in ref.watch(platformsProvider).value ?? const <PlatformOut>[]) p.id: p.name};
    bool held(PositionOut x) => dec(x.units) > Decimal.zero || dec(x.pending) > Decimal.zero;
    // Sin posición (compras previstas con objetivo y watchlist): plegados aparte
    final noPosition = [
      for (final c in pf.classes)
        for (final x in c.positions)
          if (!held(x) && showPosition(c, x)) x,
    ];
    final watch =
        (ref.watch(assetsProvider).value ?? const <AssetOut>[]).where((a) => a.watchlist && !a.archived).toList();
    return [
      if (classes.isNotEmpty) _Allocation(classes: classes),
      for (final c in classes)
        if (c.positions.any(held))
          Card(
            key: Key('class-${c.assetClass.id}'),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              SectionHeader(c.assetClass.name, trailing: MoneyText.api(c.value, compact: true)),
              for (final x in c.positions.where(held).toList()..sort((a, b) => dec(b.value).compareTo(dec(a.value))))
                _AssetRow(x: x, platform: platforms[x.asset.platformId]),
              const SizedBox(height: Space.xs),
            ]),
          ),
      if (pf.unclassified.isNotEmpty)
        Card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SectionHeader('Sin categoría'),
            for (final x in pf.unclassified) _AssetRow(x: x, platform: platforms[x.asset.platformId]),
          ]),
        ),
      if (noPosition.isNotEmpty || watch.isNotEmpty)
        Card(
          child: Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              key: const Key('watchlist'),
              leading: const Icon(Icons.visibility_outlined),
              title: Text('Sin posición y watchlist (${noPosition.length + watch.length})'),
              subtitle: const Text('Activos con objetivo que aún no tienes y los que solo sigues'),
              children: [
                for (final x in noPosition)
                  ListRow(
                    title: x.asset.name,
                    subtitle: [
                      if (x.innerTarget != null) 'objetivo ${pct(x.innerTarget, decimals: 0)} en su categoría',
                      positionState(x)?.detail ?? '',
                    ].where((s) => s.isNotEmpty).join(' · '),
                    onTap: () => context.go('/inversiones/activo/${x.asset.id}'),
                  ),
                for (final a in watch)
                  ListRow(
                    title: a.name,
                    subtitle: 'Watchlist',
                    onTap: () => context.go('/inversiones/activo/${a.id}'),
                  ),
              ],
            ),
          ),
        ),
    ];
  }

  List<Widget> _sideColumn(BuildContext context, WidgetRef ref, PortfolioOut pf) {
    final pending = ref.watch(pendingTxProvider).value ?? const <TxOut>[];
    final history =
        ref.watch(performanceProvider((assetId: null, classId: null))).value?.series ?? const <SeriesPointOut>[];
    final cs = Theme.of(context).colorScheme;
    return [
      Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.lg, Space.sm),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
            Text('Tu dinero frente al mercado', style: Theme.of(context).textTheme.titleMedium),
            FaroLineChart(
              periods: true,
              height: 220,
              emptyText: 'La evolución sale cuando haya al menos dos días con precio',
              series: [
                ChartSeries(
                  id: 'value',
                  label: 'Valor',
                  color: cs.primary,
                  area: true,
                  points: [for (final p in history) ChartPoint.at(p.date, dec(p.value).toDouble())],
                ),
                ChartSeries(
                  id: 'contributed',
                  label: 'Aportado (la diferencia es la ganancia)',
                  color: cs.outline,
                  width: 1.5,
                  dashed: true,
                  stepped: true,
                  points: [for (final p in history) ChartPoint.at(p.date, dec(p.contributed).toDouble())],
                ),
              ],
            ),
          ]),
        ),
      ),
      if (pf.emergency != null) _EmergencyCard(e: pf.emergency!),
      if (pending.isNotEmpty) _PendingCard(txs: pending, p: pf),
    ];
  }
}

class _Kpis extends ConsumerWidget {
  const _Kpis({required this.p});
  final PortfolioOut p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final perf = ref.watch(performanceProvider((assetId: null, classId: null))).value;
    final contrib = ref.watch(contributionsProvider).value;
    final big = FaroText.kpi(context);
    return KpiGrid(minWidth: 165, children: [
      KpiCard(
        label: 'Valor de la cartera',
        emphasis: true,
        value: MoneyText.api(p.value, key: const Key('portfolio-value'), compact: true, style: big),
      ),
      KpiCard(
        label: 'Aportado (coste)',
        info: 'pmp',
        value: MoneyText.api(p.cost, compact: true, style: big),
        note: dec(p.pending) > Decimal.zero ? '+ ${eur(p.pending)} pendiente de VL' : null,
      ),
      KpiCard(
        label: 'Ganancia',
        value: MoneyText.api(p.pnl, key: const Key('portfolio-pnl'), plus: true, colored: true, style: big),
        delta: DeltaText(p.pnlPct == null ? null : dec(p.pnlPct)),
      ),
      KpiCard(
        label: 'Rentabilidad anual',
        info: 'xirr',
        value: perf?.xirr == null ? null : DeltaText(dec(perf!.xirr), style: big),
        unavailable: perf != null && perf.xirr == null ? 'Sale con un poco más de historial' : null,
        note: 'XIRR: con cuándo aportaste',
      ),
      KpiCard(
        label: 'Ritmo mensual',
        value: contrib == null ? null : Text('${MoneyText.format(dec(contrib.paceInvesting), compact: true)}/mes'),
        note: 'Media invertida en 12 meses',
        onTap: () => context.go('/inversiones/aportaciones'),
      ),
      KpiCard(
        label: 'Racha',
        valueText:
            contrib == null ? null : '${contrib.streakInvesting} ${contrib.streakInvesting == 1 ? 'mes' : 'meses'}',
        note: 'Seguidos invirtiendo',
        onTap: () => context.go('/inversiones/aportaciones'),
      ),
      KpiCard(
        label: 'Peor caída',
        info: 'drawdown',
        value: perf?.maxDrawdown == null ? null : DeltaText(dec(perf!.maxDrawdown), style: big),
        unavailable: perf != null && perf.maxDrawdown == null ? 'Sin datos suficientes' : null,
      ),
    ]);
  }
}

/// Asignación: peso de cada categoría frente a su rango y objetivo (barras tipo bullet).
class _Allocation extends StatelessWidget {
  const _Allocation({required this.classes});
  final List<ClassOut> classes;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      key: const Key('allocation'),
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
          Row(children: [
            Expanded(child: Text('ASIGNACIÓN', style: FaroText.overline(context))),
            const InfoTip(
              'barras',
              title: 'Cómo leer las barras',
              text: 'La franja verde es el rango que admites (mínimo–máximo), la marca vertical es el '
                  'objetivo y la barra, el peso de hoy.',
            ),
          ]),
          for (final c in classes)
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.xs, children: [
              Wrap(spacing: Space.sm, runSpacing: Space.xs, crossAxisAlignment: WrapCrossAlignment.center, children: [
                Text(c.assetClass.name, style: tt.titleSmall),
                Text(pct(c.weight, decimals: 1), style: tt.titleSmall?.copyWith(fontFeatures: FaroText.tabular)),
                if (classState(c) case final st?) StatusPill(st.label, tone: st.tone, tooltip: st.detail),
              ]),
              if (c.target != null)
                BulletBar(
                  value: dec(c.weight).toDouble(),
                  target: dec(c.target).toDouble(),
                  min: dec(c.min).toDouble(),
                  max: dec(c.max).toDouble(),
                  semanticLabel: '${c.assetClass.name}: peso ${pct(c.weight, decimals: 1)}, objetivo '
                      '${pct(c.target, decimals: 0)}',
                ),
              Text(
                [
                  if (c.target != null)
                    'objetivo ${pct(c.target, decimals: 0)} · rango ${pct(c.min, decimals: 0)}–${pct(c.max, decimals: 0)}',
                  // Fuera del rango, cuánto: dentro, el rango ya está dicho
                  if (classState(c) case final st? when c.status != ClassOutStatusEnum.ok) st.detail,
                ].join(' · '),
                style: FaroText.caption(context),
              ),
            ]),
        ]),
      ),
    );
  }
}

/// Fila de activo: nombre completo, valor grande, ganancia en € y %, y su peso frente al objetivo.
class _AssetRow extends StatelessWidget {
  const _AssetRow({required this.x, this.platform});
  final PositionOut x;
  final String? platform;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final st = positionState(x);
    final pending = dec(x.pending) > Decimal.zero;
    return InkWell(
      key: Key('asset-${x.asset.id}'),
      onTap: () => context.go('/inversiones/activo/${x.asset.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.lg, vertical: Space.md),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.md, children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: 2, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(child: Text(x.asset.name, style: tt.titleSmall)),
                if (x.stale)
                  Tooltip(
                    message: x.priceDate == null ? 'Sin precio' : 'Precio del ${dayMonth(x.priceDate!)}',
                    child: Icon(Icons.update, size: 16, color: context.faro.warning),
                  ),
              ]),
              Text(
                [
                  ?platform,
                  '${qty(x.units)} × ${x.price != null ? eur(x.price) : '—'}',
                  if (pending) '${eur(x.pending)} pendiente de VL',
                ].join(' · '),
                style: FaroText.caption(context),
              ),
              if (st != null)
                Padding(
                  padding: const EdgeInsets.only(top: Space.xs),
                  child: StatusPill(st.label, tone: st.tone, tooltip: st.detail),
                ),
            ]),
          ),
          SizedBox(
            width: 150,
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, spacing: 2, children: [
              MoneyText.api(x.value, style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              Wrap(alignment: WrapAlignment.end, crossAxisAlignment: WrapCrossAlignment.center, children: [
                MoneyText.api(x.pnl, plus: true, colored: true, style: tt.bodySmall),
                Text(' ${pct(x.pnlPct, plus: true)}', style: tt.bodySmall?.copyWith(fontFeatures: FaroText.tabular)),
              ]),
              if (x.innerTarget != null) ...[
                const SizedBox(height: Space.xs),
                BulletBar(
                  value: dec(x.innerWeight).toDouble(),
                  target: dec(x.innerTarget).toDouble(),
                  height: 8,
                  semanticLabel: 'Peso ${pct(x.innerWeight, decimals: 1)} de su categoría, objetivo '
                      '${pct(x.innerTarget, decimals: 0)}',
                ),
                Text('peso ${pct(x.innerWeight, decimals: 1)} · obj. ${pct(x.innerTarget, decimals: 0)}',
                    style: FaroText.caption(context)),
              ],
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Fondo de emergencia, compacto: progreso, lo que falta y lo sugerido al mes.
class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.e});
  final EmergencyOut e;

  @override
  Widget build(BuildContext context) {
    final cov = dec(e.coverage).toDouble().clamp(0.0, 1.0);
    final missing = dec(e.missing) > Decimal.zero;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(Radii.md),
        onTap: () => context.go('/gastos/cuentas'),
        child: Padding(
          padding: const EdgeInsets.all(Space.lg),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
            Row(spacing: Space.sm, children: [
              const Icon(Icons.shield_outlined, size: 20),
              const Expanded(child: Text('Fondo de emergencia')),
              Flexible(
                child: Text('${eur(e.current)} de ${eur(e.target)}',
                    textAlign: TextAlign.end, style: const TextStyle(fontFeatures: FaroText.tabular)),
              ),
            ]),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: cov, minHeight: 8, color: missing ? null : context.faro.gain),
            ),
            Text(
              missing
                  ? 'Cobertura ${pct(e.coverage, decimals: 0)} · faltan ${eur(e.missing)}'
                      '${dec(e.suggestedMonthly) > Decimal.zero ? ' · sugerido ${eur(e.suggestedMonthly)}/mes' : ''}'
                  : 'Completo ✓',
              style: FaroText.caption(context),
            ),
          ]),
        ),
      ),
    );
  }
}

class _PendingCard extends ConsumerWidget {
  const _PendingCard({required this.txs, required this.p});
  final List<TxOut> txs;
  final PortfolioOut p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = {
      for (final c in p.classes)
        for (final x in c.positions) x.asset.id: x.asset.name,
      for (final x in p.unclassified) x.asset.id: x.asset.name,
    };
    for (final a in ref.watch(assetsProvider).value ?? const <AssetOut>[]) {
      names.putIfAbsent(a.id, () => a.name);
    }
    return Card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ListTile(
          leading: Icon(Icons.hourglass_top, color: context.faro.info),
          title: const Text('Pendientes de valor liquidativo'),
          subtitle: const Text('Los fondos se confirman solos al salir el VL; lo demás, tocando la fila.'),
        ),
        // Fila normal (fecha, activo, importe): en la columna lateral del escritorio, el hueco del botón
        // "Confirmar" dejaba el nombre en tres líneas. Se confirma tocando la fila.
        for (final t in txs)
          ListRow(
            lead: dayMonth(t.tradeDate),
            title: names[t.assetId] ?? 'Activo',
            subtitle: txKindLabel(t.kind),
            trailing: MoneyText.api(t.amountEur),
            onTap: () => showSettleDialog(context, ref, t),
          ),
      ]),
    );
  }
}
