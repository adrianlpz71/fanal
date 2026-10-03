import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../auth/auth_controller.dart' show userApi;
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../gastos/data.dart' as gastos show accountsProvider, refreshGastos, showSnack, shortDate;
import 'data.dart';

final contributionPlansProvider =
    FutureProvider<List<PlanOut>>((ref) async => (await userApi(ref).getInversionesApi().listPlans()).data!);

const _freq = {1: 'Mensual', 2: 'Bimestral', 3: 'Trimestral', 6: 'Semestral', 12: 'Anual'};

/// Aportaciones periódicas: cada fecha crea una compra pendiente de valor liquidativo.
class PlansPage extends ConsumerWidget {
  const PlansPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(contributionPlansProvider);
    final names = {for (final a in ref.watch(assetsProvider).value ?? const <AssetOut>[]) a.id: a.name};
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Aportaciones periódicas')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-plan'),
        icon: const Icon(Icons.add),
        label: const Text('Aportación periódica'),
        onPressed: () => _planDialog(context, ref, null),
      ),
      body: plans.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.event_repeat,
                title: 'Sin aportaciones periódicas',
                text: 'Si tienes un plan automático en tu bróker, añádelo: Fanal anotará cada aportación '
                    'como pendiente de valor liquidativo.',
                actionLabel: 'Añadir aportación periódica',
                onAction: () => _planDialog(context, ref, null),
              )
            : ListView(padding: const EdgeInsets.only(bottom: 96), children: [
                for (final p in items)
                  ListRow(
                    key: Key('plan-${p.id}'),
                    leading: Icon(p.active ? Icons.event_repeat : Icons.pause_circle_outline),
                    title: names[p.assetId] ?? 'Activo',
                    muted: !p.active,
                    subtitle: [
                      _freqText(p.everyMonths),
                      'día ${p.dayOfMonth}',
                      if (p.active && p.nextDate != null) 'próxima ${gastos.shortDate(p.nextDate)}',
                      if (p.fromAccountId != null) 'sale de la cuenta de gastos',
                    ].join(' · '),
                    // Estado con texto e icono, no solo con el color
                    extra: p.active
                        ? null
                        : const Padding(
                            padding: EdgeInsets.only(top: Space.xs),
                            child: StatusPill('Pausada', key: Key('plan-paused')),
                          ),
                    trailing: MoneyText.api(p.amount),
                    onTap: () => _planDialog(context, ref, p),
                    actions: [
                      RowAction(
                        key: Key('plan-edit-${p.id}'),
                        icon: Icons.edit_outlined,
                        label: 'Editar',
                        primary: true,
                        onPressed: () => _planDialog(context, ref, p),
                      ),
                    ],
                  ),
              ]),
      ),
    );
  }
}

/// "Cada mes", "Cada 3 meses"…
String _freqText(int every) => every == 1 ? 'Cada mes' : 'Cada $every meses';

Future<void> _planDialog(BuildContext context, WidgetRef ref, PlanOut? p) async {
  final assets = (ref.read(assetsProvider).value ?? const <AssetOut>[]).where((a) => !a.archived && !a.watchlist).toList();
  final accounts = ref.read(gastos.accountsProvider).value ?? const <AccountOut>[];
  final gastosAcc = accounts.where((a) => a.kind.value == 'gastos').firstOrNull;
  String? asset = p?.assetId ?? (assets.isEmpty ? null : assets.first.id);
  final amount = TextEditingController(text: p == null ? '' : dec(p.amount).toStringAsFixed(2).replaceAll('.', ','));
  final day = TextEditingController(text: '${p?.dayOfMonth ?? 1}');
  var every = p?.everyMonths ?? 1;
  var active = p?.active ?? true;
  var fromGastos = p == null ? gastosAcc != null : p.fromAccountId != null;
  String? error;
  final res = await showFormPanel<String>(
    context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) {
        void save() {
          final v = parseEsDecimal(amount.text);
          final d = int.tryParse(day.text);
          if (asset == null || v == null || d == null || d < 1 || d > 31) {
            return setState(() => error = 'Revisa activo, importe y día (1–31)');
          }
          Navigator.pop(c, 'save');
        }

        return FormPanel(
          title: p == null ? 'Nueva aportación periódica' : 'Aportación periódica',
          onSubmit: save,
          actions: FormActions(
            primaryLabel: 'Guardar',
            onPrimary: save,
            expand: c.isCompact,
            secondary: [
              if (p != null) TextButton(onPressed: () => Navigator.pop(c, 'delete'), child: const Text('Borrar')),
            ],
          ),
          children: [
            SelectField<String>(
              label: 'Activo',
              value: asset,
              options: [for (final a in assets) SelectOption(a.id, a.name)],
              onChanged: (v) => setState(() => asset = v),
            ),
            FieldRow(minWidth: 140, children: [
              MoneyField(label: 'Importe', controller: amount),
              UnitsField(label: 'Día del mes', controller: day, integer: true),
            ]),
            ChoiceChipsField<int>(
              label: 'Frecuencia',
              options: [for (final e in _freq.entries) Segment(e.key, e.value)],
              value: every,
              onChanged: (v) => setState(() => every = v),
            ),
            if (gastosAcc != null)
              SwitchField(
                title: 'Sale de mi cuenta de gastos',
                subtitle: 'Crea un recurrente (transferencia) para que salga en tus ciclos.',
                value: fromGastos,
                onChanged: (v) => setState(() => fromGastos = v),
              ),
            if (p != null)
              SwitchField(
                title: 'Activa',
                subtitle: 'En pausa no crea órdenes nuevas.',
                value: active,
                onChanged: (v) => setState(() => active = v),
              ),
            if (error != null) ErrorText(error),
          ],
        );
      },
    ),
  );
  if (res == null) return;
  if (res == 'delete' && context.mounted) {
    final ok = await confirmDialog(context,
        title: '¿Borrar esta aportación periódica?',
        message: 'Deja de crear órdenes nuevas. Las operaciones que ya creó se quedan.');
    if (!ok) return;
  }
  final api = ref.read(apiProvider).getInversionesApi();
  try {
    if (res == 'delete') {
      await api.deletePlan(planId: p!.id);
    } else {
      final now = DateTime.now();
      final body = PlanIn(
        assetId: asset!,
        amount: apiAmount(parseEsDecimal(amount.text)!.abs()),
        everyMonths: every,
        dayOfMonth: int.parse(day.text),
        startDate: p?.startDate ?? DateTime.utc(now.year, now.month, now.day),
        active: active,
        fromAccountId: fromGastos ? gastosAcc?.id : null,
      );
      if (p == null) {
        await api.createPlan(planIn: body);
      } else {
        await api.updatePlan(planId: p.id, planIn: body);
      }
    }
    ref.invalidate(contributionPlansProvider);
    refreshInv(ref);
    gastos.refreshGastos(ref);
  } catch (e) {
    if (context.mounted) gastos.showSnack(context, apiErrorMessage(e));
  }
}
