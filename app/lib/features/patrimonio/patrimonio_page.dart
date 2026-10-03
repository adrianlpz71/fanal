import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api.dart';
import '../../core/charts/charts.dart';
import '../../core/dates.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../inversiones/data.dart' show pct, NoAdviceNote;
import '../inversiones/prices.dart';
import 'data.dart';

/// Patrimonio → Resumen: el neto y cómo ha cambiado, qué lo compone, lo que debes, los hitos y
/// enlaces a la evolución y a la rentabilidad.
class PatrimonioPage extends ConsumerWidget {
  const PatrimonioPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nw = ref.watch(networthProvider);
    final ev = ref.watch(evolutionProvider).value;
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Patrimonio'), actions: [
        if (context.isCompact) const PricesStatus(compact: true),
      ]),
      body: RefreshIndicator(
        onRefresh: () async => refreshAnalytics(ref),
        child: nw.when(
          loading: () => const SkeletonPage(kpis: 1),
          error: (e, _) => Center(child: Text(apiErrorMessage(e))),
          data: (n) => LayoutBuilder(builder: (context, box) {
            final wide = box.maxWidth >= 1000;
            final distribution = _Distribution(n: n, ev: ev);
            final side = [_Owe(n: n), const _Milestones()];
            final bottom = [_EvolutionMini(ev: ev), const _PerformanceSummary()];
            return ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.xl), children: [
              _Header(n: n, ev: ev),
              if (wide) ...[
                Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.md, children: [
                  Expanded(child: distribution),
                  SizedBox(
                    width: FaroLayout.sidePanel,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: side),
                  ),
                ]),
                Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.md, children: [
                  for (final w in bottom) Expanded(child: w),
                ]),
              ] else ...[
                distribution,
                ...side,
                ...bottom,
              ],
              const NoAdviceNote(text: 'Cálculos con tus datos. No es una recomendación de inversión.'),
            ]);
          }),
        ),
      ),
    );
  }
}

/// Valor del neto al cierre del mes anterior (el último punto de la serie en ese mes o antes).
EvolutionPointOut? _previousMonth(NetWorthEvolutionOut? ev) {
  if (ev == null || ev.points.length < 2) return null;
  final last = ev.points.last.date;
  final monthStart = DateTime(last.year, last.month, 1);
  return ev.points.where((p) => p.date.isBefore(monthStart)).lastOrNull;
}

class _Header extends StatelessWidget {
  const _Header({required this.n, required this.ev});
  final NetWorthOut n;
  final NetWorthEvolutionOut? ev;

  @override
  Widget build(BuildContext context) {
    final prev = _previousMonth(ev);
    final total = dec(n.total);
    final change = prev == null ? null : total - dec(prev.net);
    final base = prev == null ? null : dec(prev.net);
    final caption = FaroText.caption(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.xs, children: [
          Text('Patrimonio neto', style: Theme.of(context).textTheme.labelLarge),
          MoneyText.api(n.total,
              key: const Key('networth-total'), compact: true, style: FaroText.kpi(context).copyWith(fontSize: 36)),
          if (change != null)
            Wrap(spacing: Space.sm, crossAxisAlignment: WrapCrossAlignment.center, children: [
              MoneyText(change, plus: true, colored: true),
              if (base != null && base > Decimal.zero)
                DeltaText((change / base).toDecimal(scaleOnInfinitePrecision: 6)),
              Text('frente al cierre de ${monthYear(prev!.date)}', style: caption),
            ]),
          if (n.afterTax != null)
            Wrap(spacing: Space.xs, crossAxisAlignment: WrapCrossAlignment.center, children: [
              Text('Si vendieras hoy: ', style: caption),
              MoneyText.api(n.afterTax, compact: true, style: caption.copyWith(fontWeight: FontWeight.w600)),
              Text(' tras impuestos', style: caption),
              InfoTip(
                'tras-impuestos',
                size: 16,
                text: 'Ganancia latente si vendieras todo hoy: ${eur(n.unrealizedGain)} (coste FIFO). '
                    'Impuesto con la escala del ahorro ${n.taxYear}: ${eur(n.taxIfSold)}. '
                    'Patrimonio neto menos ese impuesto. Es una estimación.',
              ),
              if (n.taxSource != null)
                TextButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('Fuente oficial'),
                  onPressed: () => launchUrl(Uri.parse(n.taxSource!)),
                ),
            ]),
        ]),
      ),
    );
  }
}

enum _View { item, type, entity }

/// Qué tienes: donut por cuenta/activo, por tipo o por entidad. Lo que debes va aparte.
class _Distribution extends StatefulWidget {
  const _Distribution({required this.n, required this.ev});
  final NetWorthOut n;
  final NetWorthEvolutionOut? ev;

  @override
  State<_Distribution> createState() => _DistributionState();
}

class _DistributionState extends State<_Distribution> {
  _View _view = _View.item;

  List<DonutSlice> _slices(BuildContext context) {
    final n = widget.n;
    final ev = widget.ev;
    final values = <String, double>{};
    final colors = <String, Color>{};
    void add(String key, String label, double v, {Color? color}) {
      if (v == 0) return;
      values[label] = (values[label] ?? 0) + v;
      if (color != null) colors[label] ??= color;
    }

    final last = ev?.points.lastOrNull;
    if (ev != null && last != null) {
      final palette = context.faro.seriesForAll(ev.components.map((c) => c.key));
      for (final c in ev.components) {
        final v = dec(last.components[c.key]).toDouble();
        switch (_view) {
          case _View.item:
            add(c.key, c.label, v, color: palette[c.key]);
          case _View.type:
            add(c.group, groupLabel(c), v);
          case _View.entity:
            add(c.entity, c.entity.isEmpty ? 'Sin entidad' : c.entity, v);
        }
      }
    } else {
      // Sin serie aún: lo de la tarjeta
      for (final a in n.accounts) {
        add(a.id, _view == _View.type ? (accountKindLabels[a.kind] ?? a.kind) : a.name, dec(a.balance).toDouble());
      }
      add('inv', 'Inversiones', dec(n.investments).toDouble());
    }
    // Gris: aún no es de ningún activo (y así no repite el color del primero de la paleta)
    add('pending', 'Pendiente de VL', dec(n.pending).toDouble(), color: FaroColors.neutral);
    add('receivable', 'Te deben', dec(n.receivable).toDouble());
    final sorted = values.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (final e in sorted) DonutSlice(id: e.key, label: e.key, value: e.value, color: colors[e.key]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final slices = _slices(context);
    final gross = slices.fold<double>(0, (s, x) => s + x.value);
    final owes = dec(widget.n.debts) + dec(widget.n.installments) > Decimal.zero;
    return Card(
      key: const Key('distribution'),
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.md, children: [
          Text('LO QUE TIENES', style: FaroText.overline(context)),
          SegmentedField<_View>(
            segments: const [
              Segment(_View.item, 'Cuenta o activo'),
              Segment(_View.type, 'Tipo'),
              Segment(_View.entity, 'Entidad'),
            ],
            value: _view,
            onChanged: (v) => setState(() => _view = v),
          ),
          if (slices.isEmpty)
            const EmptyState(icon: Icons.pie_chart_outline, title: 'Aún no hay nada que repartir')
          else
            FaroDonut(
              slices: slices,
              center: privacyMode ? '•••' : MoneyText.format(Decimal.parse(gross.toStringAsFixed(2)), compact: true),
              // El neto de arriba es esto menos lo que debes
              centerCaption: owes ? 'antes de\nlo que debes' : 'en total',
            ),
        ]),
      ),
    );
  }
}

/// Lo que debes, aparte del donut: fraccionadas pendientes y deudas.
class _Owe extends StatelessWidget {
  const _Owe({required this.n});
  final NetWorthOut n;

  @override
  Widget build(BuildContext context) {
    final inst = dec(n.installments);
    final debts = dec(n.debts);
    return Card(
      key: const Key('owe'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SectionHeader('Lo que debes'),
        if (inst.sign == 0 && debts.sign == 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
            child: Text('Nada pendiente: ni compras fraccionadas ni deudas.', style: FaroText.caption(context)),
          ),
        if (inst.sign > 0)
          ListRow(
            title: 'Compras fraccionadas pendientes',
            trailing: MoneyText(inst),
            onTap: () => context.go('/gastos/fraccionadas'),
          ),
        if (debts.sign > 0)
          ListRow(title: 'Deudas', trailing: MoneyText(debts), onTap: () => context.go('/gastos/deudas')),
      ]),
    );
  }
}

/// Hitos: primera vez que el neto cruzó cada umbral y el siguiente "al ritmo actual" (D10).
class _Milestones extends ConsumerWidget {
  const _Milestones();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(milestonesProvider).value;
    final caption = FaroText.caption(context);
    return Card(
      key: const Key('milestones'),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SectionHeader(
          'Hitos',
          trailing: IconButton(
            key: const Key('edit-milestones'),
            tooltip: 'Elegir los hitos',
            icon: const Icon(Icons.edit_outlined, size: 20),
            onPressed: m == null ? null : () => _editMilestones(context, ref, m),
          ),
        ),
        if (m == null)
          const Padding(padding: EdgeInsets.all(Space.lg), child: LinearProgressIndicator())
        else if (m.items.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.lg),
            child: Text('Sin hitos. Pulsa el lápiz para elegirlos.', style: caption),
          )
        else ...[
          // Los que ya tenías al empezar la serie, en una sola fila
          if (m.items.where((x) => x.beforeStart).toList() case final early when early.isNotEmpty)
            ListRow(
              key: const Key('milestones-early'),
              leading: Icon(Icons.check_circle, size: 20, color: context.faro.gain),
              title: early.map((x) => _threshold(x.amount)).join(' · '),
              subtitle: 'Ya los superabas al empezar la serie (${monthYear(early.first.reachedOn!)})',
            ),
          for (final x in m.items.where((x) => !x.beforeStart))
            ListRow(
              key: Key('milestone-${dec(x.amount).toBigInt()}'),
              leading: Icon(
                x.reachedOn != null ? Icons.check_circle : Icons.radio_button_unchecked,
                size: 20,
                color: x.reachedOn != null ? context.faro.gain : Theme.of(context).colorScheme.outline,
              ),
              title: _threshold(x.amount),
              trailing: x.reachedOn == null ? null : Text(monthYear(x.reachedOn!), style: caption),
              // El siguiente, con la proyección debajo (en el móvil no cabe a la derecha)
              extra: (x.reachedOn == null && m.next != null && m.next!.amount == x.amount && m.next!.eta != null)
                  ? Wrap(spacing: Space.xs, crossAxisAlignment: WrapCrossAlignment.center, children: [
                      Text('al ritmo actual ~${monthYear(m.next!.eta!)}', style: caption),
                      const InfoTip('proyeccion-hito', size: 16),
                    ])
                  : null,
            ),
        ],
      ]),
    );
  }
}

/// Los umbrales son redondos: sin céntimos.
String _threshold(String s) => formatEur(dec(s), decimals: 0);

Future<void> _editMilestones(BuildContext context, WidgetRef ref, MilestonesOut m) =>
    showFormPanel<void>(context, builder: (_) => _MilestonesForm(initial: [for (final t in m.thresholds) dec(t)]));

class _MilestonesForm extends ConsumerStatefulWidget {
  const _MilestonesForm({required this.initial});
  final List<Decimal> initial;

  @override
  ConsumerState<_MilestonesForm> createState() => _MilestonesFormState();
}

class _MilestonesFormState extends ConsumerState<_MilestonesForm> {
  late final List<Decimal> _values = [...widget.initial];
  final _new = TextEditingController();
  bool _busy = false;
  String? _error;

  static final _defaults = [1000, 2500, 5000, 10000, 25000, 50000, 100000].map(Decimal.fromInt).toList();

  @override
  void dispose() {
    _new.dispose();
    super.dispose();
  }

  void _add() {
    final v = parseEsDecimal(_new.text);
    if (v == null || v <= Decimal.zero) {
      setState(() => _error = 'Escribe un importe mayor que 0');
      return;
    }
    setState(() {
      if (!_values.contains(v)) _values.add(v);
      _values.sort();
      _new.clear();
      _error = null;
    });
  }

  Future<void> _save() async {
    setState(() => _busy = true);
    try {
      await ref.read(apiProvider).getAnalyticsApi().putMilestones(
            milestonesIn: MilestonesIn(thresholds: [for (final v in _values) apiAmount(v)]),
          );
      ref.invalidate(milestonesProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FormPanel(
        title: 'Hitos del patrimonio',
        onSubmit: _busy ? null : _save,
        actions: FormActions(
          primaryLabel: 'Guardar',
          busy: _busy,
          onPrimary: _save,
          expand: context.isCompact,
          secondary: [
            TextButton(
              onPressed: () => setState(() => _values
                ..clear()
                ..addAll(_defaults)),
              child: const Text('Restablecer'),
            ),
          ],
        ),
        children: [
          Text('La primera fecha en que tu patrimonio neto superó cada importe.', style: FaroText.caption(context)),
          Wrap(spacing: Space.sm, runSpacing: Space.sm, children: [
            for (final v in _values)
              InputChip(
                key: Key('threshold-${v.toBigInt()}'),
                label: Text(formatEur(v, decimals: 0)),
                onDeleted: () => setState(() => _values.remove(v)),
                deleteButtonTooltipMessage: 'Quitar',
              ),
          ]),
          Row(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.sm, children: [
            Expanded(
              child: MoneyField(
                key: const Key('new-threshold'),
                label: 'Añadir un hito',
                controller: _new,
                error: _error,
                onSubmitted: (_) => _add(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: Space.xs),
              child: OutlinedButton(onPressed: _add, child: const Text('Añadir')),
            ),
          ]),
        ],
      );
}

/// Evolución en pequeño: la línea del neto y el enlace a la pestaña.
class _EvolutionMini extends StatelessWidget {
  const _EvolutionMini({required this.ev});
  final NetWorthEvolutionOut? ev;

  @override
  Widget build(BuildContext context) {
    final pts = ev?.points ?? const <EvolutionPointOut>[];
    return Card(
      child: ListTile(
        key: const Key('evolution-mini'),
        leading: const Icon(Icons.timeline),
        title: const Text('Evolución'),
        subtitle: pts.length < 2
            ? const Text('Sale cuando haya al menos dos puntos')
            : Text('Desde el ${fullDate(ev!.start ?? pts.first.date)}'),
        trailing: Row(mainAxisSize: MainAxisSize.min, spacing: Space.sm, children: [
          if (pts.length >= 2) Sparkline([for (final p in pts) dec(p.net).toDouble()], width: 88),
          const Icon(Icons.chevron_right),
        ]),
        onTap: () => context.go('/patrimonio/evolucion'),
      ),
    );
  }
}

/// Resumen de la rentabilidad; el detalle está en Inversiones → Rendimiento.
class _PerformanceSummary extends ConsumerWidget {
  const _PerformanceSummary();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(performanceProvider((assetId: null, classId: null))).value;
    if (p == null || p.first == null) return const SizedBox.shrink();
    return Card(
      child: ListTile(
        key: const Key('perf-summary'),
        leading: const Icon(Icons.insights_outlined),
        title: const Text('Rentabilidad de la cartera'),
        subtitle: Text([
          'Ganancia ${eur(p.gain, plus: true)}',
          if (p.twr != null) 'acumulada ${pct(p.twr, plus: true)}',
          if (p.xirr != null) 'XIRR ${pct(p.xirr, plus: true)}',
        ].join(' · ')),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.go('/inversiones/rendimiento'),
      ),
    );
  }
}
