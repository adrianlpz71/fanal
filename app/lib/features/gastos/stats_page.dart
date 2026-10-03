import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/charts/charts.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import 'data.dart';

/// Estadísticas de gastos por ciclo. Los importes se muestran desde Decimal; los double solo
/// se usan para dibujar las gráficas.
class StatsPage extends ConsumerStatefulWidget {
  const StatsPage({super.key});

  @override
  ConsumerState<StatsPage> createState() => _StatsPageState();
}

class _StatsPageState extends ConsumerState<StatsPage> {
  int _cycles = 6;

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(statsProvider(_cycles));
    final idx = CategoryIndex(ref.watch(categoriesProvider).value ?? const []);
    return Scaffold(
      appBar: const FaroAppBar(title: PageTitle('Estadísticas')),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, 0),
          child: SegmentedField<int>(
            segments: const [Segment(3, '3 ciclos'), Segment(6, '6 ciclos'), Segment(12, '12 ciclos')],
            value: _cycles,
            onChanged: (v) => setState(() => _cycles = v),
          ),
        ),
        Expanded(child: _body(context, st, idx)),
      ]),
    );
  }

  Widget _body(BuildContext context, AsyncValue<StatsOut> st, CategoryIndex idx) => st.when(
        loading: () => const SkeletonPage(kpis: 3),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (s) => ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.xl), children: [
          KpiGrid(minWidth: 165, children: [
            KpiCard(label: 'Gasto medio por ciclo', value: MoneyText.api(s.avgSpend, compact: true), emphasis: true),
            KpiCard(
              label: 'Tasa de ahorro media',
              valueText: s.avgSavingsRate == null
                  ? null
                  : '${(dec(s.avgSavingsRate) * dec('100')).toStringAsFixed(1).replaceAll('.', ',')} %',
              unavailable: s.avgSavingsRate == null ? 'Sin ciclos cerrados' : null,
            ),
            if (s.cycles.isNotEmpty)
              KpiCard(label: 'Gasto ${s.cycles.last.label}', value: MoneyText.api(s.cycles.last.spend, compact: true)),
          ]),
          const SectionHeader('Gasto por ciclo y categoría', padding: EdgeInsets.fromLTRB(0, Space.lg, 0, Space.sm)),
          _SpendChart(cycles: s.cycles, idx: idx),
          const SectionHeader('Por ciclo', padding: EdgeInsets.fromLTRB(0, Space.lg, 0, Space.xs)),
          for (final c in s.cycles.reversed)
            ListTile(
              dense: true,
              title: Text(c.label),
              subtitle: Text('Ingresos extra ${eur(c.income)} · fijos ${eur(c.fixed)} · cuotas ${eur(c.installments)}'),
              trailing: Text('${eur(c.spend)}'
                  '${c.savingsRate != null ? ' · ahorro ${(dec(c.savingsRate) * dec('100')).toStringAsFixed(0)} %' : ''}'),
            ),
          const SectionHeader('Categorías (ciclo actual frente a la media)', padding: EdgeInsets.fromLTRB(0, Space.lg, 0, 0)),
          Text('Toca una categoría para fijarle un presupuesto por ciclo.', style: FaroText.caption(context)),
          for (final c in s.categories) _CategoryRow(c: c, idx: idx),
          const SectionHeader('Conceptos con más gasto', padding: EdgeInsets.fromLTRB(0, Space.lg, 0, 0)),
          for (final t in s.topConcepts)
            ListTile(dense: true, title: Text(t.concept), subtitle: Text('${t.count} ${t.count == 1 ? 'vez' : 'veces'}'), trailing: Text(eur(t.total))),
        ]),
      );
}

class _SpendChart extends StatelessWidget {
  const _SpendChart({required this.cycles, required this.idx});
  final List<CycleStatsOut> cycles;
  final CategoryIndex idx;

  @override
  Widget build(BuildContext context) {
    // Una serie por categoría con gasto en alguno de los ciclos, en orden de aparición
    final ids = <String?>[];
    for (final c in cycles) {
      for (final a in c.byCategory.where((a) => dec(a.amount) > dec('0'))) {
        if (!ids.contains(a.categoryId)) ids.add(a.categoryId);
      }
    }
    // Colores de la paleta de series (no los de cada categoría, que pueden parecerse mucho entre
    // sí): en una gráfica apilada, cada categoría con un color distinto
    final colors = context.faro.seriesForAll(ids.map((id) => id ?? ''));
    return FaroBarChart(
      height: 240,
      emptyText: 'Sin datos',
      series: [
        for (final id in ids) (id: id ?? '', label: idx.label(id), color: colors[id ?? '']!),
      ],
      groups: [
        for (final c in cycles)
          BarGroup(
            c.label.split(' ').first.substring(0, 3),
            [
              for (final id in ids)
                c.byCategory
                    .where((a) => a.categoryId == id && dec(a.amount) > dec('0'))
                    .fold(0.0, (t, a) => t + dec(a.amount).toDouble()),
            ],
            tooltipTitle: c.label,
          ),
      ],
    );
  }
}

class _CategoryRow extends ConsumerWidget {
  const _CategoryRow({required this.c, required this.idx});
  final CategoryStatOut c;
  final CategoryIndex idx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final used = c.budgetUsed == null ? null : dec(c.budgetUsed);
    final over = used != null && used > dec('1');
    final warn = used != null && used >= dec('0.8');
    return ListTile(
      leading: Icon(idx.icon(c.categoryId), color: idx.color(c.categoryId)),
      title: Text(c.name),
      subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Este ciclo ${eur(c.current)} · media ${eur(c.average)}'
            '${c.budget != null ? ' · presupuesto ${eur(c.budget)}' : ''}'),
        if (used != null) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: used.toDouble().clamp(0, 1),
            color: over ? context.faro.loss : (warn ? context.faro.warning : context.faro.gain),
          ),
        ],
      ]),
      trailing: over ? Icon(Icons.warning_amber, color: context.faro.loss) : null,
      onTap: c.categoryId == null ? null : () => _budget(context, ref, c),
    );
  }
}

Future<void> _budget(BuildContext context, WidgetRef ref, CategoryStatOut c) async {
  final ctrl = TextEditingController(
      text: c.budget == null ? '' : dec(c.budget).toStringAsFixed(2).replaceAll('.', ','));
  final res = await showFormPanel<String>(
    context,
    builder: (d) => FormPanel(
      title: 'Presupuesto · ${c.name}',
      onSubmit: () => Navigator.pop(d, 'save'),
      actions: FormActions(
        primaryLabel: 'Guardar',
        onPrimary: () => Navigator.pop(d, 'save'),
        expand: d.isCompact,
        secondary: [
          if (c.budget != null) TextButton(onPressed: () => Navigator.pop(d, 'delete'), child: const Text('Quitar')),
        ],
      ),
      children: [
        MoneyField(label: 'Por ciclo', controller: ctrl, autofocus: true, helper: 'Media actual: ${eur(c.average)}'),
      ],
    ),
  );
  final api = ref.read(apiProvider).getGastosApi();
  try {
    if (res == 'delete') {
      await api.deleteBudget(categoryId: c.categoryId!);
    } else if (res == 'save' && parseEsDecimal(ctrl.text) != null) {
      await api.putBudget(categoryId: c.categoryId!, budgetIn: BudgetIn(amount: apiAmount(parseEsDecimal(ctrl.text)!.abs())));
    } else {
      return;
    }
    ref.invalidate(statsProvider);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}
