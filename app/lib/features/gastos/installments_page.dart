import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import 'data.dart';

const _providers = {
  'paypal': 'PayPal',
  'klarna': 'Klarna',
  'tarjeta': 'Tarjeta',
  'amazon': 'Amazon',
  'eci': 'El Corte Inglés',
  'otro': 'Otro',
};

class InstallmentsPage extends ConsumerStatefulWidget {
  const InstallmentsPage({super.key});

  @override
  ConsumerState<InstallmentsPage> createState() => _InstallmentsPageState();
}

class _InstallmentsPageState extends ConsumerState<InstallmentsPage> {
  bool _closed = false;

  @override
  Widget build(BuildContext context) {
    final plans = ref.watch(plansProvider(_closed));
    final debt = ref.watch(forecastProvider).value?.liveInstallmentDebt;
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Compras fraccionadas')),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Nueva compra fraccionada',
        onPressed: () => _newPlan(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Nueva compra'),
      ),
      // El filtro va en el cuerpo y no en la barra: allí dejaba sin sitio al título en el móvil
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(Space.md, Space.md, Space.md, 0),
          child: SegmentedField<bool>(
            key: const Key('plans-closed'),
            segments: const [Segment(false, 'En curso'), Segment(true, 'Con las cerradas')],
            value: _closed,
            onChanged: (v) => setState(() => _closed = v),
          ),
        ),
        Expanded(child: _list(context, plans, debt)),
      ]),
    );
  }

  Widget _list(BuildContext context, AsyncValue<List<InstallmentPlanOut>> plans, String? debt) => plans.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) => ListView(padding: const EdgeInsets.only(bottom: 96), children: [
          if (debt != null)
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined),
              title: const Text('Deuda fraccionada viva'),
              trailing: Text(eur(debt)),
            ),
          const Divider(),
          if (items.isEmpty) const ListTile(title: Text('No hay compras fraccionadas')),
          for (final p in items) _PlanCard(p: p),
        ]),
      );
}

class _PlanCard extends ConsumerWidget {
  const _PlanCard({required this.p});
  final InstallmentPlanOut p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final idx = CategoryIndex(ref.watch(categoriesProvider).value ?? const []);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        title: Text(p.description),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${_providers[p.provider.value]} · ${idx.label(p.categoryId)} · cuota ${p.paid}/${p.n} · '
              'quedan ${eur(p.remainingAmount)}'
              '${p.nextDue != null ? ' · próxima ${shortDate(p.nextDue)}' : ''}'
              '${p.status != 'activa' ? ' · ${p.status}' : ''}'),
          const SizedBox(height: 6),
          LinearProgressIndicator(value: p.n == 0 ? 0 : p.paid / p.n),
        ]),
        trailing: Text(eur(p.total), style: tt.titleSmall),
        children: [
          for (final i in p.installments)
            ListTile(
              dense: true,
              leading: Icon(switch (i.status) {
                'pagada' => Icons.check_circle,
                'adelantada' => Icons.fast_forward,
                'cancelada' => Icons.cancel_outlined,
                _ => Icons.radio_button_unchecked,
              }),
              title: Text('Cuota ${i.seq} · ${shortDate(i.dueDate)}'),
              subtitle: Text(i.status),
              trailing: Text(eur(i.amount)),
            ),
          OverflowBar(alignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () => _rename(context, ref, p), child: const Text('Renombrar')),
            TextButton(
              key: Key('plan-category-${p.id}'),
              onPressed: () => _category(context, ref, p, idx),
              child: const Text('Categoría'),
            ),
            if (p.status == 'activa') ...[
              TextButton(
                onPressed: () => _action(context, ref, () async {
                  await ref.read(apiProvider).getGastosApi().cancelPlan(planId: p.id);
                  return 'Compra cancelada';
                }, confirm: 'Las cuotas pendientes se cancelan (devolución). ¿Seguro?'),
                child: const Text('Cancelar / devolución'),
              ),
              FilledButton.tonal(
                onPressed: () => _action(context, ref, () async {
                  final r = await ref.read(apiProvider).getGastosApi().advancePlan(
                      planId: p.id, advanceIn: AdvanceIn(merge: true));
                  return '${r.data!.moved} cuotas adelantadas a este ciclo (${eur(r.data!.amount)})';
                }, confirm: 'Las ${p.n - p.paid} cuotas pendientes (${eur(p.remainingAmount)}) pasan a un único cargo en el ciclo actual.'),
                child: const Text('Adelantar pago'),
              ),
            ],
            const SizedBox(width: 8),
          ]),
        ],
      ),
    );
  }
}

Future<void> _action(BuildContext context, WidgetRef ref, Future<String> Function() run,
    {required String confirm}) async {
  final ok = await confirmDialog(context, title: confirm, confirmLabel: 'Sí, seguir', destructive: false);
  if (!ok) return;
  try {
    final msg = await run();
    refreshGastos(ref);
    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }
}

/// Categoría de la compra: la heredan sus cuotas pendientes (y las que se generen).
Future<void> _category(BuildContext context, WidgetRef ref, InstallmentPlanOut p, CategoryIndex idx) async {
  final cats = idx.byId.values
      .where((c) => !c.archived && (c.parentId != null || !idx.byId.values.any((x) => x.parentId == c.id)))
      .toList()
    ..sort((a, b) => idx.label(a.id).compareTo(idx.label(b.id)));
  final picked = await showSelectPicker<String>(
    context,
    title: 'Categoría de ${p.description}',
    search: true,
    selected: p.categoryId,
    options: [for (final c in cats) SelectOption(c.id, idx.label(c.id), icon: idx.icon(c.id), iconColor: idx.color(c.id))],
  );
  if (picked == null) return;
  try {
    await ref.read(apiProvider).getGastosApi().patchPlan(
        planId: p.id, installmentPlanPatch: InstallmentPlanPatch(categoryId: picked.value));
    refreshGastos(ref);
    ref.invalidate(plansProvider);
    if (context.mounted) showSnack(context, 'Categoría puesta a la compra y a sus cuotas pendientes');
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

Future<void> _rename(BuildContext context, WidgetRef ref, InstallmentPlanOut p) async {
  final ctrl = TextEditingController(text: p.description);
  final ok = await showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Renombrar compra'),
      content: FaroTextField(controller: ctrl, autofocus: true, label: 'Qué compraste'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancelar')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Guardar')),
      ],
    ),
  );
  if (ok != true || ctrl.text.trim().isEmpty) return;
  try {
    await ref.read(apiProvider).getGastosApi().patchPlan(
        planId: p.id, installmentPlanPatch: InstallmentPlanPatch(description: ctrl.text.trim()));
    refreshGastos(ref);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }
}

Future<void> _newPlan(BuildContext context, WidgetRef ref) =>
    showFormPanel(context, builder: (_) => const _NewPlanForm());

class _NewPlanForm extends ConsumerStatefulWidget {
  const _NewPlanForm();

  @override
  ConsumerState<_NewPlanForm> createState() => _NewPlanFormState();
}

class _NewPlanFormState extends ConsumerState<_NewPlanForm> {
  final _desc = TextEditingController();
  final _total = TextEditingController();
  final _n = TextEditingController(text: '3');
  final _paid = TextEditingController(text: '0');
  String _provider = 'paypal';
  String? _category;
  DateTime _first = DateTime.now();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    for (final c in [_desc, _total, _n, _paid]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final t = parseEsDecimal(_total.text);
    final nn = int.tryParse(_n.text);
    if (_desc.text.trim().isEmpty || t == null || nn == null || nn < 1) {
      return setState(() => _error = 'Pon qué compraste, el total y el número de cuotas');
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiProvider).getGastosApi().createPlan(
            installmentPlanIn: InstallmentPlanIn(
              description: _desc.text.trim(),
              provider: InstallmentPlanInProviderEnum.values.firstWhere((e) => e.value == _provider),
              total: apiAmount(t),
              n: nn,
              firstDue: DateTime.utc(_first.year, _first.month, _first.day),
              paidCount: int.tryParse(_paid.text) ?? 0,
              categoryId: _category,
            ),
          );
      refreshGastos(ref);
      ref.invalidate(plansProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final idx = CategoryIndex(ref.watch(categoriesProvider).value ?? const []);
    final cats = idx.byId.values
        .where((c) => !c.archived && (c.parentId != null || !idx.byId.values.any((x) => x.parentId == c.id)))
        .toList()
      ..sort((a, b) => idx.label(a.id).compareTo(idx.label(b.id)));
    return FormPanel(
      title: 'Nueva compra fraccionada',
      onSubmit: _busy ? null : _save,
      actions: FormActions(primaryLabel: 'Crear', busy: _busy, onPrimary: _save, expand: context.isCompact),
      children: [
        FaroTextField(controller: _desc, label: 'Qué compraste', autofocus: true),
        FieldRow(minWidth: 200, children: [
          SelectField<String>(
            label: 'Forma de pago',
            value: _provider,
            options: [for (final e in _providers.entries) SelectOption(e.key, e.value)],
            onChanged: (v) => setState(() => _provider = v),
          ),
          SelectField<String?>(
            key: const Key('plan-category'),
            label: 'Categoría',
            value: _category,
            emptyText: 'Sin categoría',
            helper: 'La heredan todas sus cuotas',
            options: [
              for (final c in cats) SelectOption<String?>(c.id, idx.label(c.id), icon: idx.icon(c.id), iconColor: idx.color(c.id)),
            ],
            onChanged: (v) => setState(() => _category = v),
          ),
        ]),
        MoneyField(controller: _total, label: 'Total'),
        FieldRow(minWidth: 120, children: [
          UnitsField(controller: _n, label: 'Cuotas', integer: true),
          UnitsField(controller: _paid, label: 'Ya pagadas', integer: true),
        ]),
        DateField(
          label: 'Primera cuota',
          value: _first,
          first: DateTime(2020),
          onChanged: (d) => setState(() => _first = d ?? _first),
        ),
        const Text('Las cuotas se reparten a partes iguales; la última ajusta los céntimos.'),
        if (_error != null) ErrorText(_error),
      ],
    );
  }
}
