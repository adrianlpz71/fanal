import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import 'cycle_page.dart';
import 'data.dart';
import 'movement_sheet.dart';
import 'overview_pages.dart';

/// Meses: navegar por los ciclos pasados, el actual y los futuros. En los futuros se ve y se
/// gestiona lo previsto (gastos planificados, cuotas y recurrentes proyectados).
class MonthsPage extends ConsumerStatefulWidget {
  const MonthsPage({super.key, this.initial});

  /// AAAA-MM de un mes futuro para abrirlo directamente.
  final String? initial;

  @override
  ConsumerState<MonthsPage> createState() => _MonthsPageState();
}

/// Un mes en la barra: ciclo existente (`cycle`) o futuro (`future`).
class _Entry {
  _Entry.cycle(CycleOut c) : key = 'c:${c.id}', label = c.label, cycle = c, future = null;
  _Entry.future(ForecastMonthOut m) : key = 'f:${m.ym}', label = m.label, cycle = null, future = m;
  final String key;
  final String label;
  final CycleOut? cycle;
  final ForecastMonthOut? future;

  bool get isOpen => cycle?.status == CycleOutStatusEnum.open;
}

class _MonthsPageState extends ConsumerState<MonthsPage> {
  String? _sel;
  final _chipKeys = <String, GlobalKey>{};
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    if (widget.initial != null) _sel = 'f:${widget.initial}';
  }

  void _select(String key) {
    setState(() => _sel = key);
    _ensureVisible(key);
  }

  void _ensureVisible(String key) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _chipKeys[key]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(ctx, alignment: 0.5, duration: const Duration(milliseconds: 200));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cycles = ref.watch(cyclesProvider);
    final ahead = ref.watch(monthsAheadProvider);
    final idx = CategoryIndex(ref.watch(categoriesProvider).value ?? const []);

    if (cycles.isLoading && !cycles.hasValue || ahead.isLoading && !ahead.hasValue) {
      return Scaffold(
        appBar: FaroAppBar(title: const PageTitle('Meses')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    final err = cycles.error ?? ahead.error;
    if (err != null) {
      return Scaffold(
        appBar: FaroAppBar(title: const PageTitle('Meses')),
        body: Center(child: Text(apiErrorMessage(err))),
      );
    }
    final entries = [
      for (final c in (cycles.value ?? const <CycleOut>[]).reversed) _Entry.cycle(c),
      for (final m in ahead.value?.months ?? const <ForecastMonthOut>[]) _Entry.future(m),
    ];
    if (entries.isEmpty) {
      return Scaffold(
        appBar: FaroAppBar(title: const PageTitle('Meses')),
        body: const Center(child: Text('Aún no hay ciclos')),
      );
    }
    final current = entries.where((e) => e.isOpen).firstOrNull ?? entries.first;
    var i = entries.indexWhere((e) => e.key == _sel);
    if (i < 0) i = entries.indexOf(current);
    final sel = entries[i];
    if (!_scrolled) {
      _scrolled = true;
      _ensureVisible(sel.key);
    }
    final canAdd = sel.future != null || sel.isOpen;

    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Meses'),
        actions: [
          BarAction(
            icon: Icons.view_agenda_outlined,
            label: 'Resumen',
            onPressed: () => context.go('/gastos/meses/resumen'),
          ),
        ],
      ),
      floatingActionButton: canAdd
          ? FloatingActionButton.extended(
              key: const Key('add-to-month'),
              icon: const Icon(Icons.add),
              label: Text('Añadir a ${sel.label}'),
              onPressed: () => showMovementSheet(context, ref, month: sel.future?.ym),
            )
          : null,
      body: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Mes anterior',
                icon: const Icon(Icons.chevron_left),
                onPressed: i > 0 ? () => _select(entries[i - 1].key) : null,
              ),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final e in entries)
                          Padding(
                            key: _chipKeys.putIfAbsent(e.key, GlobalKey.new),
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ChoiceChip(
                              label: Text(e.isOpen ? '${e.label} · actual' : e.label),
                              avatar: e.future != null ? const Icon(Icons.schedule, size: 16) : null,
                              selected: e.key == sel.key,
                              onSelected: (_) => _select(e.key),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Mes siguiente',
                icon: const Icon(Icons.chevron_right),
                onPressed: i < entries.length - 1 ? () => _select(entries[i + 1].key) : null,
              ),
            ],
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => refreshGastos(ref),
              child: sel.cycle != null
                  ? _CyclePane(cycle: sel.cycle!, idx: idx)
                  : _FuturePane(ym: sel.future!.ym, idx: idx),
            ),
          ),
        ],
      ),
    );
  }
}

class _CyclePane extends ConsumerWidget {
  const _CyclePane({required this.cycle, required this.idx});
  final CycleOut cycle;
  final CategoryIndex idx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final open = cycle.status == CycleOutStatusEnum.open;
    final detail = ref.watch(cycleDetailProvider(cycle.id));
    final s = cycle.summary;
    return detail.when(
      loading: () => const SkeletonPage(),
      error: (e, _) => Center(child: Text(apiErrorMessage(e))),
      data: (cy) {
        final active = cy.movements.where((m) => m.status != MovementOutStatusEnum.cancelled).toList();
        // Mismo orden que Este ciclo: pendientes por fecha prevista, cargados del más reciente al
        // más antiguo (los que no tienen fecha, al final)
        final pending = active.where((m) => m.status == MovementOutStatusEnum.planned).toList()
          ..sort((a, b) => (a.dueDate ?? DateTime(2100)).compareTo(b.dueDate ?? DateTime(2100)));
        final posted = active.where((m) => m.status == MovementOutStatusEnum.posted).toList()
          ..sort((a, b) => (b.date ?? DateTime(1900)).compareTo(a.date ?? DateTime(1900)));
        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            ListTile(
              title: Text('Inicial ${eur(s.opening)} → ${open ? 'previsto' : 'final'} ${eur(s.expectedEnd)}'),
              subtitle: Text(
                'Fijos ${eur(s.fixedSpend)} · variables ${eur(s.variableSpend)}'
                ' · cuotas ${eur(s.installments)} · ahorro ${eur(s.savings)}'
                '${cycle.discrepancy != null && dec(cycle.discrepancy).sign != 0 ? ' · descuadre ${eur(cycle.discrepancy, plus: true)}' : ''}',
              ),
            ),
            if (!open)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Ciclo cerrado: se consulta, no se modifica (su saldo final es el real del banco).'),
              ),
            if (pending.isNotEmpty) _Header('Pendientes (${pending.length})'),
            for (final m in pending) MovementTile(m: m, idx: idx, readOnly: !open),
            _Header('Cargados (${posted.length})'),
            for (final m in posted) MovementTile(m: m, idx: idx, readOnly: !open),
          ],
        );
      },
    );
  }
}

class _FuturePane extends ConsumerWidget {
  const _FuturePane({required this.ym, required this.idx});
  final String ym;
  final CategoryIndex idx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final month = ref.watch(monthProvider(ym));
    return month.when(
      loading: () => const SkeletonPage(),
      error: (e, _) => Center(child: Text(apiErrorMessage(e))),
      data: (mo) => ListView(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 96),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: MonthSummaryCard(m: mo.toSummary()),
          ),
          _Header('Previsto (${mo.items.length})'),
          if (mo.items.isEmpty)
            const ListTile(
              title: Text('Nada previsto todavía'),
              subtitle: Text('Añade lo que planeas gastar este mes: contará en su ciclo y en el acumulado.'),
            ),
          for (final it in mo.items)
            if (it.movement != null)
              MovementTile(m: it.movement!, idx: idx, month: ym)
            else
              _ProjectionTile(item: it, month: mo, idx: idx),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Los recurrentes en cursiva son proyecciones de la plantilla: tócalos para cambiar '
              'el importe solo ese mes, saltarlo o darlo de baja desde ese mes.',
            ),
          ),
        ],
      ),
    );
  }
}

extension on MonthOut {
  ForecastMonthOut toSummary() => ForecastMonthOut(
    label: label,
    ym: ym,
    start: start,
    end: end,
    payroll: payroll,
    recurring: recurring,
    installments: installments,
    other: other,
    free: free,
    cumulative: cumulative,
  );
}

class _ProjectionTile extends ConsumerWidget {
  const _ProjectionTile({required this.item, required this.month, required this.idx});
  final MonthItemOut item;
  final MonthOut month;
  final CategoryIndex idx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: idx.avatar(context, item.categoryId, radius: 20, size: 20),
      title: Text(item.concept, style: TextStyle(color: cs.onSurfaceVariant)),
      subtitle: Text('${idx.label(item.categoryId)} · recurrente · ${shortDate(item.date)}'),
      trailing: Text(
        eur(item.amount, plus: true),
        style: TextStyle(fontWeight: FontWeight.w600, fontStyle: FontStyle.italic, color: cs.onSurfaceVariant),
      ),
      onTap: () => _actions(context, ref),
    );
  }

  Future<void> _actions(BuildContext context, WidgetRef ref) async {
    final action = (await showSelectPicker<String>(
      context,
      title: '${item.concept} · ${month.label} · ${eur(item.amount)}',
      options: [
        const SelectOption(
          'editar',
          'Cambiar solo este mes',
          subtitle: 'Importe, fecha o concepto; la plantilla no cambia',
          icon: Icons.edit_outlined,
        ),
        const SelectOption('saltar', 'Saltar este mes', icon: Icons.skip_next_outlined),
        SelectOption(
          'baja',
          'Dar de baja desde ${month.label}',
          subtitle: 'Deja de aparecer desde este mes; los anteriores no cambian',
          icon: Icons.event_busy_outlined,
          iconColor: context.faro.loss,
        ),
      ],
    ))
        ?.value;
    if (action == null || !context.mounted) return;
    final api = ref.read(apiProvider).getGastosApi();
    try {
      switch (action) {
        case 'editar':
          final mv = (await api.recurringOccurrence(
            templateId: item.templateId!,
            occurrenceIn: OccurrenceIn(date: item.date, action: OccurrenceInActionEnum.editar),
          )).data!;
          refreshGastos(ref);
          if (context.mounted) await showMovementSheet(context, ref, existing: mv, month: month.ym);
        case 'saltar':
          final mv = (await api.recurringOccurrence(
            templateId: item.templateId!,
            occurrenceIn: OccurrenceIn(date: item.date, action: OccurrenceInActionEnum.saltar),
          )).data!;
          refreshGastos(ref);
          if (context.mounted) {
            showUndoSnack(
              context,
              '${item.concept}: saltado en ${month.label}',
              onUndo: () async {
                await api.patchMovement(
                  movementId: mv.id,
                  movementPatch: MovementPatch(status: MovementPatchStatusEnum.planned),
                );
                refreshGastos(ref);
              },
            );
          }
        case 'baja':
          final ok = await confirmDialog(
            context,
            title: '¿Dar de baja ${item.concept}?',
            message: 'Dejará de aparecer a partir del ${shortDate(item.date)} (${month.label}). '
                'Puedes reactivarlo en Recurrentes.',
            confirmLabel: 'Dar de baja',
            destructive: false,
          );
          if (!ok) return;
          await api.patchRecurring(
            templateId: item.templateId!,
            recurringPatch: RecurringPatch(endDate: item.date.subtract(const Duration(days: 1))),
          );
          refreshGastos(ref);
          if (context.mounted) showSnack(context, '${item.concept} de baja desde ${month.label}');
      }
    } catch (e) {
      if (context.mounted) showSnack(context, apiErrorMessage(e));
    }
  }
}

class _Header extends StatelessWidget {
  const _Header(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(title.toUpperCase(), style: Theme.of(context).textTheme.labelLarge),
  );
}
