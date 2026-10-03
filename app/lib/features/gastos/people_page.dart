import 'package:decimal/decimal.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import 'data.dart';

/// Personas con saldo: quién me debe y a quién debo (gastos compartidos).
class PeoplePage extends ConsumerWidget {
  const PeoplePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final people = ref.watch(peopleProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Personas · me deben / debo')),
      body: people.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) {
          final owed = items.fold(dec('0'), (a, p) => a + dec(p.owedToMe));
          final owe = items.fold(dec('0'), (a, p) => a + dec(p.iOwe));
          if (items.isEmpty) {
            return ListView(children: [
              EmptyState(
                icon: Icons.group_outlined,
                title: 'Aún no hay gastos compartidos',
                text: 'Abre un gasto y pulsa “Repartir” para asignar partes a otras personas.',
                actionLabel: 'Ir a los gastos del ciclo',
                onAction: () => context.go('/gastos'),
              ),
            ]);
          }
          return ListView(children: [
            ListTile(
              title: const Text('Total'),
              subtitle: Text('Me deben ${formatEur(owed)} · debo ${formatEur(owe)}'),
            ),
            const Divider(),
            for (final p in items)
              ListTile(
                leading: CircleAvatar(child: Text(p.name.isEmpty ? '?' : p.name[0].toUpperCase())),
                title: Text(p.name),
                subtitle: Text('Me debe ${eur(p.owedToMe)} · le debo ${eur(p.iOwe)}'),
                trailing: Text(eur(p.net, plus: true),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: dec(p.net).sign > 0 ? context.faro.gain : (dec(p.net).sign < 0 ? context.faro.loss : null),
                    )),
                onTap: () => context.go('/gastos/personas/${p.id}'),
              ),
          ]);
        },
      ),
    );
  }
}

class PersonDetailPage extends ConsumerWidget {
  const PersonDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shares = ref.watch(personSharesProvider(id));
    final person = ref.watch(peopleProvider).value?.where((p) => p.id == id).firstOrNull;
    return Scaffold(
      appBar: FaroAppBar(title: PageTitle(person?.name ?? 'Persona')),
      body: shares.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) => ListView(children: [
          for (final s in items) ShareTile(s: s, showMovement: true),
        ]),
      ),
    );
  }
}

/// Parte de un gasto (pendiente / saldada) con botón para saldar.
class ShareTile extends ConsumerWidget {
  const ShareTile({super.key, required this.s, this.showMovement = false});
  final ShareOut s;
  final bool showMovement;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owed = s.direction == ShareOutDirectionEnum.meDeben;
    final pending = s.status == ShareOutStatusEnum.pendiente;
    return ListTile(
      leading: Icon(owed ? Icons.call_received : Icons.call_made,
          color: owed ? context.faro.gain : context.faro.loss),
      title: Text(showMovement ? (s.movementConcept ?? '—') : s.personName),
      subtitle: Text('${owed ? 'Me debe' : 'Le debo'} ${eur(s.amount)}'
          '${showMovement && s.movementDate != null ? ' · ${shortDate(s.movementDate)}' : ''}'
          '${pending ? '' : ' · saldada'}'),
      trailing: pending
          ? FilledButton.tonal(
              onPressed: () async {
                try {
                  await ref.read(apiProvider).getGastosApi().settle(shareId: s.id, settleIn: SettleIn());
                  refreshAll(ref);
                  if (context.mounted) {
                    showSnack(context, owed ? 'Anotado el reembolso de ${s.personName}' : 'Anotado el pago a ${s.personName}');
                  }
                } catch (e) {
                  if (context.mounted) showSnack(context, apiErrorMessage(e));
                }
              },
              child: const Text('Saldar'),
            )
          : const Icon(Icons.check),
    );
  }
}

/// Editor de reparto de un gasto: qué parte es de cada persona.
Future<void> showSharesEditor(BuildContext context, WidgetRef ref, MovementOut m) async {
  final api = ref.read(apiProvider).getGastosApi();
  final existing = (await api.getShares(movementId: m.id)).data ?? const [];
  if (!context.mounted) return;
  final rows = <_ShareRow>[
    for (final s in existing.where((s) => s.status == ShareOutStatusEnum.pendiente))
      _ShareRow(s.personName, dec(s.amount).toStringAsFixed(2).replaceAll('.', ','),
          owed: s.direction == ShareOutDirectionEnum.meDeben),
  ];
  if (rows.isEmpty) rows.add(_ShareRow('', '', owed: true));
  final people = ref.read(peopleProvider).value ?? const [];
  final ok = await showFormPanel<bool>(
    context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) {
        final total = dec(m.amount).abs();
        return FormPanel(
          title: 'Repartir “${m.concept}”',
          onSubmit: () => Navigator.pop(c, true),
          actions: FormActions(primaryLabel: 'Guardar', onPrimary: () => Navigator.pop(c, true), expand: c.isCompact),
          children: [
            Text('Importe total: ${formatEur(total)}'),
            for (final r in rows)
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Expanded(
                  child: FieldRow(flex: const [3, 2], minWidth: 160, children: [
                    Autocomplete<String>(
                      initialValue: TextEditingValue(text: r.name),
                      optionsBuilder: (v) => people
                          .map((p) => p.name)
                          .where((n) => n.toLowerCase().contains(v.text.toLowerCase())),
                      onSelected: (v) => r.name = v,
                      fieldViewBuilder: (_, ctrl, focus, onFieldSubmitted) => FaroTextField(
                        label: 'Persona',
                        controller: ctrl,
                        focusNode: focus,
                        onChanged: (v) => r.name = v,
                        onSubmitted: (_) => onFieldSubmitted(),
                      ),
                    ),
                    MoneyField(label: 'Importe', controller: r.amount),
                  ]),
                ),
                IconButton(
                  tooltip: r.owed ? 'Me debe' : 'Le debo',
                  icon: Icon(r.owed ? Icons.call_received : Icons.call_made,
                      color: r.owed ? context.faro.gain : context.faro.loss),
                  onPressed: () => setState(() => r.owed = !r.owed),
                ),
              ]),
            Wrap(spacing: Space.sm, children: [
              TextButton.icon(
                icon: const Icon(Icons.person_add_alt),
                label: const Text('Añadir persona'),
                onPressed: () => setState(() => rows.add(_ShareRow('', '', owed: true))),
              ),
              TextButton(
                onPressed: () => setState(() {
                  // Partes iguales entre las personas y yo
                  final n = rows.length + 1;
                  final each = (total / dec('$n')).toDecimal(scaleOnInfinitePrecision: 2);
                  for (final r in rows) {
                    r.amount.text = each.toStringAsFixed(2).replaceAll('.', ',');
                  }
                }),
                child: const Text('A partes iguales'),
              ),
            ]),
            Text('↙ me debe  ·  ↗ le debo (pagó la otra persona)', style: FaroText.caption(c)),
          ],
        );
      },
    ),
  );
  if (ok != true) return;
  final items = [
    for (final r in rows)
      if (r.name.trim().isNotEmpty && (parseEsDecimal(r.amount.text) ?? dec('0')) > dec('0'))
        ShareIn(
          personName: r.name.trim(),
          amount: apiAmount(parseEsDecimal(r.amount.text)!),
          direction: r.owed ? ShareInDirectionEnum.meDeben : ShareInDirectionEnum.debo,
        ),
  ];
  try {
    await api.putShares(movementId: m.id, shareIn: items);
    refreshAll(ref);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

class _ShareRow {
  _ShareRow(this.name, String amount, {required this.owed}) : amount = TextEditingController(text: amount);
  String name;
  final TextEditingController amount;
  bool owed;
}
