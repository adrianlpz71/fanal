import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import 'data.dart';

// --- Deudas (préstamos reales) -----------------------------------------------------------
class DebtsPage extends ConsumerWidget {
  const DebtsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final debts = ref.watch(debtsProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Deudas y préstamos')),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Nueva deuda',
        onPressed: () => _newDebt(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Deuda'),
      ),
      body: debts.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) => ListView(padding: const EdgeInsets.only(bottom: 96), children: [
          if (items.isEmpty)
            EmptyState(
              icon: Icons.handshake_outlined,
              title: 'Sin deudas',
              text: 'Préstamos reales, a ti o tuyos. Los gastos compartidos van en Personas.',
              actionLabel: 'Nueva deuda',
              onAction: () => _newDebt(context, ref),
            ),
          for (final d in items)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ExpansionTile(
                leading: Icon(d.direction == DebtOutDirectionEnum.debo ? Icons.call_made : Icons.call_received,
                    color: d.direction == DebtOutDirectionEnum.debo ? context.faro.loss : context.faro.gain),
                title: Text(d.name),
                subtitle: Text('${d.direction == DebtOutDirectionEnum.debo ? 'Debo' : 'Me deben'} ${eur(d.remaining)}'
                    ' de ${eur(d.openingBalance)}${d.status == DebtOutStatusEnum.saldada ? ' · saldada' : ''}'),
                children: [
                  for (final m in d.movements)
                    ListTile(dense: true, title: Text(m.concept), subtitle: Text(shortDate(m.date)),
                        trailing: Text(eur(m.amount, plus: true))),
                  if (d.status != DebtOutStatusEnum.saldada)
                    OverflowBar(alignment: MainAxisAlignment.end, children: [
                      FilledButton.tonal(
                        onPressed: () => _payment(context, ref, d),
                        child: Text(d.direction == DebtOutDirectionEnum.debo ? 'Registrar pago' : 'Registrar cobro'),
                      ),
                      const SizedBox(width: 8),
                    ]),
                ],
              ),
            ),
        ]),
      ),
    );
  }
}

Future<void> _newDebt(BuildContext context, WidgetRef ref) async {
  final name = TextEditingController();
  final who = TextEditingController();
  final amount = TextEditingController();
  bool iOwe = true;
  final ok = await showFormPanel<bool>(
    context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => FormPanel(
        title: 'Nueva deuda',
        onSubmit: () => Navigator.pop(c, true),
        actions: FormActions(primaryLabel: 'Crear', onPrimary: () => Navigator.pop(c, true), expand: c.isCompact),
        children: [
          SegmentedField<bool>(
            segments: const [Segment(true, 'Debo'), Segment(false, 'Me deben')],
            value: iOwe,
            onChanged: (v) => setState(() => iOwe = v),
          ),
          FaroTextField(label: 'Descripción', controller: name),
          FaroTextField(label: 'Persona', helper: 'Opcional', controller: who),
          MoneyField(label: 'Importe pendiente', controller: amount),
        ],
      ),
    ),
  );
  final v = parseEsDecimal(amount.text);
  if (ok != true || v == null || name.text.trim().isEmpty) return;
  final now = DateTime.now();
  try {
    await ref.read(apiProvider).getGastosApi().createDebt(
          debtIn: DebtIn(
            name: name.text.trim(),
            personName: who.text.trim().isEmpty ? null : who.text.trim(),
            direction: iOwe ? DebtInDirectionEnum.debo : DebtInDirectionEnum.meDeben,
            openingBalance: apiAmount(v.abs()),
            openingDate: DateTime.utc(now.year, now.month, now.day),
          ),
        );
    refreshAll(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

Future<void> _payment(BuildContext context, WidgetRef ref, DebtOut d) async {
  final amount = TextEditingController();
  final ok = await showFormPanel<bool>(
    context,
    builder: (c) => FormPanel(
      title: d.name,
      onSubmit: () => Navigator.pop(c, true),
      actions: FormActions(primaryLabel: 'Registrar', onPrimary: () => Navigator.pop(c, true), expand: c.isCompact),
      children: [
        MoneyField(label: 'Importe', controller: amount, autofocus: true, helper: 'Pendiente: ${eur(d.remaining)}'),
      ],
    ),
  );
  final v = parseEsDecimal(amount.text);
  if (ok != true || v == null) return;
  try {
    await ref.read(apiProvider).getGastosApi().debtPayment(debtId: d.id, debtPaymentIn: DebtPaymentIn(amount: apiAmount(v.abs())));
    refreshAll(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

// --- Seguimientos -------------------------------------------------------------------------
class TrackersPage extends ConsumerWidget {
  const TrackersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackers = ref.watch(trackersProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Seguimientos')),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Nuevo seguimiento',
        onPressed: () => _editTracker(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Seguimiento'),
      ),
      body: trackers.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) => ListView(padding: const EdgeInsets.only(bottom: 96), children: [
          if (items.isEmpty)
            EmptyState(
              icon: Icons.timeline,
              title: 'Sin seguimientos',
              text: 'Un saldo con nombre (un bote común, una colección) que suman ciertas categorías o palabras.',
              actionLabel: 'Nuevo seguimiento',
              onAction: () => _editTracker(context, ref),
            ),
          for (final t in items)
            Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: ExpansionTile(
                leading: const Icon(Icons.timeline),
                title: Text(t.name),
                subtitle: Text('${t.movementsCount} movimientos desde ${shortDate(t.openingDate)}'),
                trailing: Text(eur(t.balance, plus: true),
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: dec(t.balance).sign < 0 ? context.faro.loss : context.faro.gain)),
                children: [
                  ListTile(dense: true, title: const Text('Saldo inicial'), trailing: Text(eur(t.openingBalance, plus: true))),
                  for (final c in t.byCycle)
                    ListTile(dense: true, title: Text(c.label), trailing: Text(eur(c.amount, plus: true))),
                  OverflowBar(alignment: MainAxisAlignment.end, children: [
                    TextButton(
                      onPressed: () async {
                        final ok = await confirmDialog(context,
                            title: '¿Eliminar ${t.name}?',
                            message: 'Solo se borra el seguimiento: los movimientos no se tocan.');
                        if (!ok) return;
                        await ref.read(apiProvider).getGastosApi().deleteTracker(trackerId: t.id);
                        refreshAll(ref);
                      },
                      child: const Text('Eliminar'),
                    ),
                    TextButton(onPressed: () => _editTracker(context, ref, existing: t), child: const Text('Editar')),
                  ]),
                ],
              ),
            ),
        ]),
      ),
    );
  }
}

Future<void> _editTracker(BuildContext context, WidgetRef ref, {TrackerOut? existing}) async {
  final cats = await ref.read(categoriesProvider.future);
  if (!context.mounted) return;
  final idx = CategoryIndex(cats);
  final name = TextEditingController(text: existing?.name ?? '');
  final opening = TextEditingController(
      text: existing == null ? '0' : dec(existing.openingBalance).toStringAsFixed(2).replaceAll('.', ','));
  final keywords = TextEditingController(text: existing?.keywords.join(', ') ?? '');
  final selected = <String>{...?existing?.categoryIds};
  DateTime date = existing?.openingDate ?? DateTime.now();
  final ok = await showFormPanel<bool>(
    context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => FormPanel(
        title: existing == null ? 'Nuevo seguimiento' : existing.name,
        onSubmit: () => Navigator.pop(c, true),
        actions: FormActions(primaryLabel: 'Guardar', onPrimary: () => Navigator.pop(c, true), expand: c.isCompact),
        children: [
          FaroTextField(label: 'Nombre', hint: 'P. ej. Bote del piso', controller: name),
          FieldRow(children: [
            MoneyField(label: 'Saldo inicial', controller: opening, allowNegative: true),
            DateField(
              label: 'Desde',
              value: date,
              first: DateTime(2015),
              last: DateTime(2100),
              onChanged: (d) => setState(() => date = d ?? date),
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, spacing: Space.sm, children: [
            Text('Categorías que lo alimentan', style: FaroText.caption(c)),
            Wrap(spacing: Space.sm, runSpacing: Space.xs, children: [
              for (final cat in cats.where((x) => x.parentId == null && x.kind != 'transferencia'))
                FilterChip(
                  avatar: Icon(idx.icon(cat.id), size: 16, color: idx.color(cat.id)),
                  label: Text(cat.name),
                  selected: selected.contains(cat.id),
                  onSelected: (v) => setState(() => v ? selected.add(cat.id) : selected.remove(cat.id)),
                ),
            ]),
          ]),
          FaroTextField(label: 'Y/o palabras del concepto', helper: 'Separadas por comas', controller: keywords),
        ],
      ),
    ),
  );
  if (ok != true || name.text.trim().isEmpty) return;
  final kws = keywords.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
  final api = ref.read(apiProvider).getGastosApi();
  final open = apiAmount(parseEsDecimal(opening.text) ?? dec('0'));
  final d = DateTime.utc(date.year, date.month, date.day);
  try {
    if (existing == null) {
      await api.createTracker(
          trackerIn: TrackerIn(name: name.text.trim(), openingBalance: open, openingDate: d,
              categoryIds: selected.toList(), keywords: kws));
    } else {
      await api.patchTracker(
          trackerId: existing.id,
          trackerPatch: TrackerPatch(name: name.text.trim(), openingBalance: open, openingDate: d,
              categoryIds: selected.toList(), keywords: kws));
    }
    refreshAll(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}
