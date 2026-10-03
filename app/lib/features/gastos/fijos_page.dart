import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../auth/auth_controller.dart' show userApi;
import '../../core/money.dart';
import 'data.dart';

final fixedPanelProvider =
    FutureProvider<FixedPanelOut>((ref) async => (await userApi(ref).getGastosApi().fixedPanel()).data!);

/// Panel para ir reduciendo gastos fijos: recurrentes + cuotas, cuánto suponen de la nómina,
/// qué revisar o cancelar y el ahorro conseguido.
class FixedCostsPage extends ConsumerWidget {
  const FixedCostsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = ref.watch(fixedPanelProvider);
    final idx = CategoryIndex(ref.watch(categoriesProvider).value ?? const []);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Gastos fijos')),
      body: p.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (f) {
          final tt = Theme.of(context).textTheme;
          final goal = f.goalMax == null ? null : dec(f.goalMax);
          final monthly = dec(f.monthlyTotal);
          final over = goal != null && monthly > goal;
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(fixedPanelProvider),
            child: ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, Space.xxl), children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(Space.lg),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.xs, children: [
                    Text('Fijos al mes', style: tt.labelLarge),
                    Text(eur(f.monthlyTotal), key: const Key('fixed-monthly'),
                        style: tt.displaySmall?.copyWith(fontWeight: FontWeight.w600)),
                    Text('${eur(f.yearlyTotal)} al año'
                        '${f.shareOfPayroll != null ? ' · ${(dec(f.shareOfPayroll) * dec('100')).toStringAsFixed(1).replaceAll('.', ',')} % de la nómina' : ''}'),
                    if (goal != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: Space.sm),
                        child: Text('Objetivo "${f.goalName}": como mucho ${eur(f.goalMax)}/mes', style: tt.bodyMedium),
                      ),
                      // Lo que gastas en fijos frente al máximo del objetivo (la marca); la zona
                      // verde llega hasta ese máximo
                      BulletBar(
                        value: monthly.toDouble(),
                        min: 0,
                        max: goal.toDouble(),
                        target: goal.toDouble(),
                        scaleMax: [monthly.toDouble(), goal.toDouble(), 1.0].reduce((a, b) => a > b ? a : b) * 1.15,
                        semanticLabel: 'Fijos ${eur(f.monthlyTotal)} al mes; objetivo, como mucho ${eur(f.goalMax)}',
                      ),
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: StatusPill(
                          over
                              ? '${formatEur(monthly - goal)}/mes por encima'
                              : '${formatEur(goal - monthly)}/mes por debajo',
                          key: const Key('fixed-goal-status'),
                          tone: over ? PillTone.warning : PillTone.ok,
                        ),
                      ),
                    ],
                    Padding(
                      padding: const EdgeInsets.only(top: Space.sm),
                      child: Wrap(spacing: Space.sm, runSpacing: Space.xs, children: [
                        StatusPill('Ahorrado con recortes: ${eur(f.savedYear)}/año',
                            tone: dec(f.savedYear).sign > 0 ? PillTone.ok : PillTone.neutral),
                        if (dec(f.toReviewSaving).sign > 0)
                          StatusPill('Por revisar: ${eur(f.toReviewSaving)}/año', tone: PillTone.info),
                      ]),
                    ),
                  ]),
                ),
              ),
              if (f.reviewDue)
                Card(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  child: ListTile(
                    leading: const Icon(Icons.event_repeat),
                    title: const Text('Toca revisar tus suscripciones'),
                    subtitle: Text(f.lastReview == null
                        ? 'Repasa la lista y marca lo que quieras cancelar.'
                        : 'La última vez fue el ${shortDate(f.lastReview)}. Se recuerda cada 3 meses.'),
                    trailing: TextButton(
                      onPressed: () async {
                        await ref.read(apiProvider).getGastosApi().fixedReviewed();
                        ref.invalidate(fixedPanelProvider);
                      },
                      child: const Text('Hecho'),
                    ),
                  ),
                ),
              if (f.suggestions.isNotEmpty) ...[
                const SectionHeader('¿Suscripciones nuevas?'),
                const _Hint('Se repiten en ciclos seguidos con un importe parecido y no son un recurrente.'),
                for (final s in f.suggestions)
                  ListTile(
                    leading: Icon(idx.icon(s.categoryId), color: idx.color(s.categoryId)),
                    title: Text(s.concept),
                    subtitle: Text('${eur(s.amount)} · en ${s.cycles} ciclos · día ${s.dayOfMonth}'),
                    trailing: TextButton(
                      child: const Text('Es recurrente'),
                      onPressed: () async {
                        final now = DateTime.now();
                        await ref.read(apiProvider).getGastosApi().createRecurring(recurringIn: RecurringIn(
                          concept: s.concept,
                          amount: s.amount,
                          categoryId: s.categoryId,
                          dayOfMonth: s.dayOfMonth,
                          startDate: DateTime.utc(now.year, now.month, now.day),
                        ));
                        ref.invalidate(fixedPanelProvider);
                        refreshGastos(ref);
                      },
                    ),
                  ),
              ],
              const SectionHeader('Todos los fijos'),
              const _Hint('Toca uno para marcarlo.'),
              for (final i in f.items) _FixedTile(i: i, idx: idx),
              if (f.trend.length >= 2) ...[
                const SectionHeader('Fijos + cuotas por ciclo'),
                for (final t in f.trend.reversed)
                  ListTile(dense: true, title: Text(t.label), trailing: Text(eur(t.fixed))),
              ],
            ]),
          );
        },
      ),
    );
  }
}

/// Explicación corta bajo una cabecera de sección.
class _Hint extends StatelessWidget {
  const _Hint(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: Space.lg),
        child: Text(text, style: FaroText.caption(context)),
      );
}

class _FixedTile extends ConsumerWidget {
  const _FixedTile({required this.i, required this.idx});
  final FixedItemOut i;
  final CategoryIndex idx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cuota = i.kind == FixedItemOutKindEnum.cuota;
    final (label, color) = switch (i.review) {
      'revisar' => ('Revisar', context.faro.warning),
      'cancelar' => ('Cancelar', context.faro.loss),
      _ => (null, null),
    };
    return ListTile(
      leading: Icon(cuota ? Icons.credit_card : idx.icon(i.categoryId), color: cuota ? null : idx.color(i.categoryId)),
      title: Text(i.name),
      subtitle: Text([
        cuota ? 'cuota hasta ${shortDate(i.ends)} ${i.ends?.year ?? ''}' : '${eur(i.yearly)}/año',
        if (i.priceChanges > 0) 'subió de precio',
        ?label,
      ].join(' · ')),
      trailing: Text('${eur(i.monthly)}/mes', style: FaroText.amount(context).copyWith(color: color)),
      onTap: cuota ? () => context.go('/gastos/fraccionadas') : () => _review(context, ref),
    );
  }

  Future<void> _review(BuildContext context, WidgetRef ref) async {
    final saving = TextEditingController(text: dec(i.estSavingYear ?? i.yearly).toStringAsFixed(2).replaceAll('.', ','));
    final choice = await showFormPanel<String>(
      context,
      builder: (c) => FormPanel(
        title: i.name,
        actions: FormActions(
          primaryLabel: 'Marcar para cancelar',
          onPrimary: () => Navigator.pop(c, 'cancelar'),
          expand: c.isCompact,
          secondary: [
            TextButton(onPressed: () => Navigator.pop(c, 'ok'), child: const Text('Está bien')),
            TextButton(onPressed: () => Navigator.pop(c, 'revisar'), child: const Text('Revisar')),
          ],
        ),
        children: [
          Text('${eur(i.monthly)}/mes · ${eur(i.yearly)}/año'),
          MoneyField(
            label: 'Ahorro anual',
            controller: saving,
            helper: 'Si lo quitas o lo cambias. Cuando le pongas fecha de fin en Recurrentes, cuenta como ahorro '
                'conseguido.',
          ),
        ],
      ),
    );
    if (choice == null) return;
    await ref.read(apiProvider).getGastosApi().patchRecurring(
          templateId: i.id,
          recurringPatch: RecurringPatch(
            review: RecurringPatchReviewEnum.values.firstWhere((r) => r.value == choice),
            estSavingYear: choice == 'ok' ? null : apiAmount(parseEsDecimal(saving.text) ?? dec(i.yearly)),
          ),
        );
    ref.invalidate(fixedPanelProvider);
    ref.invalidate(recurringProvider);
  }
}
