import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import 'data.dart';

const _freq = {1: 'Mensual', 2: 'Bimestral', 3: 'Trimestral', 6: 'Semestral', 12: 'Anual'};

class RecurringPage extends ConsumerWidget {
  const RecurringPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(recurringProvider);
    final idx = CategoryIndex(ref.watch(categoriesProvider).value ?? const []);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Recurrentes')),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Nuevo recurrente',
        onPressed: () => _edit(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Recurrente'),
      ),
      body: list.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) {
          final active = items.where((r) => r.active);
          // Los traspasos (al ahorro, a la cartera) no son coste: van aparte, como en Gastos fijos
          bool isTransfer(RecurringOut r) => r.kind == RecurringOutKindEnum.transferencia;
          final monthly = active.where((r) => !isTransfer(r)).fold(dec('0'), (a, r) => a + dec(r.monthlyCost));
          final saving = active.where(isTransfer).fold(dec('0'), (a, r) => a + dec(r.monthlyCost));
          return ListView(padding: const EdgeInsets.only(bottom: 96), children: [
            ListTile(
              title: const Text('Coste de los recurrentes activos'),
              subtitle: Text([
                '${formatEur(monthly)}/mes · ${formatEur(monthly * dec('12'))}/año',
                if (saving != dec('0')) 'Y traspasos programados (ahorro): ${formatEur(saving)}/mes',
              ].join('\n')),
            ),
            const Divider(),
            for (final r in items)
              ListTile(
                leading: Icon(idx.icon(r.categoryId), color: idx.color(r.categoryId)),
                title: Text(r.concept,
                    style: r.active ? null : const TextStyle(decoration: TextDecoration.lineThrough)),
                subtitle: Text([
                  _freq[r.everyMonths] ?? 'Cada ${r.everyMonths} meses',
                  'día ${r.dayOfMonth}',
                  if (r.amountIsEstimate) 'importe estimado',
                  if (r.review != 'ok') 'marcado: ${r.review}',
                  if (r.priceChanges.isNotEmpty)
                    'precio ${eur(r.priceChanges.first.oldAmount)} → ${eur(r.priceChanges.first.newAmount)}',
                ].join(' · ')),
                trailing: Text(eur(r.amount), style: const TextStyle(fontWeight: FontWeight.w600)),
                onTap: () => _edit(context, ref, existing: r),
              ),
          ]);
        },
      ),
    );
  }
}

Future<void> _edit(BuildContext context, WidgetRef ref, {RecurringOut? existing}) async {
  final concept = TextEditingController(text: existing?.concept ?? '');
  final amount = TextEditingController(
      text: existing == null ? '' : (-dec(existing.amount)).toStringAsFixed(2).replaceAll('.', ','));
  final day = TextEditingController(text: '${existing?.dayOfMonth ?? 1}');
  int every = existing?.everyMonths ?? 1;
  bool estimate = existing?.amountIsEstimate ?? false;
  bool active = existing?.active ?? true;
  String review = existing?.review ?? 'ok';

  final ok = await showFormPanel<bool>(
    context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => FormPanel(
        title: existing == null ? 'Nuevo recurrente' : existing.concept,
        onSubmit: () => Navigator.pop(c, true),
        actions: FormActions(
          primaryLabel: 'Guardar',
          onPrimary: () => Navigator.pop(c, true),
          expand: c.isCompact,
          secondary: [
            if (existing != null)
              TextButton(
                onPressed: () async {
                  final yes = await confirmDialog(c,
                      title: '¿Eliminar ${existing.concept}?',
                      message: 'Se borran también sus cargos previstos. Los ya cargados se quedan.');
                  if (!yes) return;
                  await ref.read(apiProvider).getGastosApi().deleteRecurring(templateId: existing.id);
                  // false: ya está borrado, no hay nada que guardar (antes se intentaba guardar igual)
                  if (c.mounted) Navigator.pop(c, false);
                },
                child: const Text('Eliminar'),
              ),
          ],
        ),
        children: [
          FaroTextField(label: 'Concepto', controller: concept),
          MoneyField(label: 'Importe del cargo', controller: amount),
          FieldRow(minWidth: 140, flex: const [2, 1], children: [
            SelectField<int>(
              label: 'Periodicidad',
              value: every,
              options: [for (final e in _freq.entries) SelectOption(e.key, e.value)],
              onChanged: (v) => setState(() => every = v),
            ),
            UnitsField(label: 'Día del mes', controller: day, integer: true),
          ]),
          SwitchField(
            title: 'Importe variable',
            subtitle: 'Avisa solo si cambia más de un 10 %',
            value: estimate,
            onChanged: (v) => setState(() => estimate = v),
          ),
          if (existing != null) ...[
            SwitchField(title: 'Activo', value: active, onChanged: (v) => setState(() => active = v)),
            SegmentedField<String>(
              label: 'Revisión',
              segments: const [Segment('ok', 'OK'), Segment('revisar', 'Revisar'), Segment('cancelar', 'Cancelar')],
              value: review,
              onChanged: (v) => setState(() => review = v),
            ),
          ],
        ],
      ),
    ),
  );
  if (ok != true) {
    refreshGastos(ref);
    return;
  }
  final v = parseEsDecimal(amount.text);
  final d = int.tryParse(day.text) ?? 1;
  if (v == null || concept.text.trim().isEmpty) return;
  final api = ref.read(apiProvider).getGastosApi();
  final amt = apiAmount(-v.abs());
  try {
    if (existing == null) {
      final now = DateTime.now();
      await api.createRecurring(
        recurringIn: RecurringIn(
          concept: concept.text.trim(),
          amount: amt,
          amountIsEstimate: estimate,
          everyMonths: every,
          dayOfMonth: d,
          startDate: DateTime.utc(now.year, now.month, 1),
        ),
      );
    } else {
      await api.patchRecurring(
        templateId: existing.id,
        recurringPatch: RecurringPatch(
          concept: concept.text.trim(),
          amount: amt,
          amountIsEstimate: estimate,
          everyMonths: every,
          dayOfMonth: d,
          active: active,
          review: RecurringPatchReviewEnum.values.firstWhere((e) => e.value == review),
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }
  refreshGastos(ref);
}
