import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../inversiones/data.dart' show pct, fractionFromPct, NoAdviceNote;
import 'data.dart';

/// "¿Y si…?": calcula otro supuesto sin guardarlo (`/fire/simulate` y `/fire/montecarlo` con
/// los cambios) y lo pone al lado de tu plan actual. Se puede guardar como plan si convence.
class ComparePage extends ConsumerStatefulWidget {
  const ComparePage({super.key, required this.plan});
  final FirePlanOut plan;

  @override
  ConsumerState<ComparePage> createState() => _ComparePageState();
}

String _pctField(String fraction) => (dec(fraction) * dec('100')).toString().replaceAll('.', ',');
String _eurField(String amount) {
  final d = dec(amount);
  return (d == d.truncate() ? d.toStringAsFixed(0) : d.toStringAsFixed(2)).replaceAll('.', ',');
}

class _ComparePageState extends ConsumerState<ComparePage> {
  late final s = widget.plan.settings;
  late final _spend = TextEditingController(text: _eurField(s.monthlySpend));
  late final _age = TextEditingController(text: '${s.targetAge}');
  late final _contrib = TextEditingController(text: _eurField(widget.plan.monthlyContribution));
  late final _swr = TextEditingController(text: _pctField(s.swr));
  late final _ret = TextEditingController(text: _pctField(s.nominalReturn));
  FirePlanOut? _alt;
  MonteCarloOut? _mcNow;
  MonteCarloOut? _mcAlt;
  bool _busy = false;
  String? _error;

  /// Solo se mandan los valores que cambian; el resto sale de tu plan guardado.
  FireSettingsIn _changes() {
    final spend = parseEsDecimal(_spend.text);
    final contrib = parseEsDecimal(_contrib.text);
    final age = int.tryParse(_age.text);
    final swr = fractionFromPct(_swr.text);
    final ret = fractionFromPct(_ret.text);
    return FireSettingsIn(
      monthlySpend: spend != null && spend != dec(s.monthlySpend) ? apiAmount(spend) : null,
      targetAge: age != null && age != s.targetAge ? age : null,
      contributionOverride:
          contrib != null && contrib != dec(widget.plan.monthlyContribution) ? apiAmount(contrib) : null,
      swr: swr != null && dec(swr) != dec(s.swr) ? swr : null,
      nominalReturn: ret != null && dec(ret) != dec(s.nominalReturn) ? ret : null,
    );
  }

  Future<void> _compare() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = ref.read(apiProvider).getPlanesApi();
      final changes = _changes();
      final r = await Future.wait([
        api.simulateFire(fireSettingsIn: changes),
        api.montecarlo(fireSettingsIn: FireSettingsIn()),
        api.montecarlo(fireSettingsIn: changes),
      ]);
      setState(() {
        _alt = r[0].data as FirePlanOut;
        _mcNow = r[1].data as MonteCarloOut;
        _mcAlt = r[2].data as MonteCarloOut;
      });
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _adopt() async {
    final c = _changes();
    try {
      await ref.read(apiProvider).getPlanesApi().putFireSettings(fireSettingsIn: FireSettingsIn(
            monthlySpend: c.monthlySpend,
            targetAge: c.targetAge,
            contributionOverride: c.contributionOverride,
            swr: c.swr,
            nominalReturn: c.nominalReturn,
          ));
      refreshPlanes(ref);
      if (mounted) context.go('/planes/independencia');
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Comparar')),
      body: FormListView(children: [
        Text('Cambia lo que quieras probar. No se guarda nada hasta que lo elijas.', style: tt.bodyMedium),
        ChoiceChipsField<int>(
          label: 'Prueba un gasto',
          options: [for (final v in const [2500, 3000, 3500]) Segment(v, eur('$v'))],
          value: int.tryParse(_spend.text) ?? 0,
          onChanged: (v) => setState(() => _spend.text = '$v'),
        ),
        FieldRow(children: [
          MoneyField(key: const Key('cmp-spend'), label: 'Gasto mensual (neto, euros de hoy)', controller: _spend,
              suffix: '€/mes', onChanged: (_) => setState(() {})),
          UnitsField(label: 'Edad objetivo', controller: _age, integer: true, suffix: 'años'),
        ]),
        MoneyField(label: 'Aportación mensual', controller: _contrib, suffix: '€/mes'),
        FieldRow(children: [
          PercentField(label: 'Tasa de retiro', controller: _swr),
          PercentField(label: 'Rentabilidad anual (nominal)', controller: _ret),
        ]),
        FilledButton.icon(
          key: const Key('run-compare'),
          icon: _busy
              ? const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.compare_arrows),
          label: const Text('Comparar'),
          onPressed: _busy ? null : _compare,
        ),
        if (_error != null) ErrorText(_error),
        if (_alt != null) ...[
          CompareTable(now: widget.plan, alt: _alt!, mcNow: _mcNow, mcAlt: _mcAlt),
          OutlinedButton.icon(
            icon: const Icon(Icons.check),
            label: const Text('Quedarme con la alternativa'),
            onPressed: _adopt,
          ),
        ],
        const NoAdviceNote(),
      ]),
    );
  }
}

/// Tabla "Ahora" / "Alternativa". Pública para poder probarla sin API.
class CompareTable extends StatelessWidget {
  const CompareTable({super.key, required this.now, required this.alt, this.mcNow, this.mcAlt});
  final FirePlanOut now;
  final FirePlanOut alt;
  final MonteCarloOut? mcNow;
  final MonteCarloOut? mcAlt;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    String reach(FirePlanOut p) => p.base_.fiAge == null ? 'no antes de 100' : ageText(p.base_.fiAge);
    final rows = <(String, String, String)>[
      ('Gasto mensual', eur(now.settings.monthlySpend), eur(alt.settings.monthlySpend)),
      ('Edad objetivo', '${now.settings.targetAge}', '${alt.settings.targetAge}'),
      ('Necesitas (€ de hoy)', eur(now.base_.needed), eur(alt.base_.needed)),
      ('Para llegar a la edad objetivo', '${eur(now.base_.requiredMonthly)}/mes', '${eur(alt.base_.requiredMonthly)}/mes'),
      ('Aportando', '${eur(now.monthlyContribution)}/mes', '${eur(alt.monthlyContribution)}/mes'),
      ('…llegas con', reach(now), reach(alt)),
      ('Impuestos al retirar', '${eur(now.taxAnnual)}/año', '${eur(alt.taxAnnual)}/año'),
      if (mcNow != null && mcAlt != null)
        ('Monte Carlo (éxito)', pct(mcNow!.success, decimals: 0), pct(mcAlt!.success, decimals: 0)),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Table(
          columnWidths: const {0: FlexColumnWidth(1.3), 1: FlexColumnWidth(), 2: FlexColumnWidth()},
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          children: [
            TableRow(children: [
              const SizedBox(),
              Text('Ahora', style: tt.labelLarge),
              Text('Alternativa', style: tt.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary)),
            ]),
            for (final (label, a, b) in rows)
              TableRow(children: [
                Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(label, style: tt.bodySmall)),
                Text(a),
                Text(b, style: TextStyle(fontWeight: a == b ? null : FontWeight.w600)),
              ]),
          ],
        ),
      ),
    );
  }
}
