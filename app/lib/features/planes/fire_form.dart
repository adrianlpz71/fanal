import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../auth/auth_controller.dart';
import '../inversiones/data.dart' show fractionFromPct, NoAdviceNote;
import 'data.dart';

String pctText(String? fraction) =>
    fraction == null ? '' : (dec(fraction) * dec('100')).toString().replaceAll('.', ',');

String _eurText(String? amount) => amount == null ? '' : dec(amount).toStringAsFixed(0);

/// Independencia → Supuestos: todos los campos del cálculo (la primera vez, las preguntas clave).
class FireForm extends ConsumerStatefulWidget {
  const FireForm({super.key, required this.settings, this.plan, this.firstTime = false});
  final FireSettingsOut settings;
  final FirePlanOut? plan; // para enseñar lo automático (capital y aportación)
  final bool firstTime;

  @override
  ConsumerState<FireForm> createState() => _FireFormState();
}

class _FireFormState extends ConsumerState<FireForm> {
  late final s = widget.settings;
  late final _age = TextEditingController(text: '${s.targetAge}');
  late final _spend = TextEditingController(text: _eurText(s.monthlySpend));
  late final _swr = TextEditingController(text: pctText(s.swr));
  late final _ret = TextEditingController(text: pctText(s.nominalReturn));
  late final _inf = TextEditingController(text: pctText(s.inflation));
  late final _costs = TextEditingController(text: pctText(s.costs));
  late final _pension = TextEditingController(text: _eurText(s.pensionMonthly));
  late final _pensionAge = TextEditingController(text: '${s.pensionAge}');
  late final _home = TextEditingController(text: _eurText(s.homeValue));
  late final _vol = TextEditingController(text: pctText(s.volatility));
  late final _horizon = TextEditingController(text: '${s.horizonAge}');
  late final _capital = TextEditingController(text: _eurText(s.capitalOverride));
  late final _contrib = TextEditingController(text: _eurText(s.contributionOverride));
  late bool _taxes = s.includeTaxes;
  DateTime? _savedBirth;
  DateTime? _birth;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final auth = ref.read(authProvider);
    _savedBirth = auth is AuthAuthenticated ? auth.user.birthDate : null;
    _birth = _savedBirth;
  }

  @override
  void dispose() {
    for (final c in [_age, _spend, _swr, _ret, _inf, _costs, _pension, _pensionAge, _home, _vol, _horizon, _capital, _contrib]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final api = ref.read(apiProvider);
      final birth = _birth;
      if (birth != null && birth != _savedBirth) {
        final me = await api.getMeApi().updateProfile(
            profileIn: ProfileIn(birthDate: DateTime.utc(birth.year, birth.month, birth.day)));
        if (me.data != null) ref.read(authProvider.notifier).updateUser(me.data!);
      }
      final capital = parseEsDecimal(_capital.text);
      final contrib = parseEsDecimal(_contrib.text);
      await api.getPlanesApi().putFireSettings(fireSettingsIn: FireSettingsIn(
        targetAge: int.tryParse(_age.text),
        monthlySpend: apiAmount(parseEsDecimal(_spend.text) ?? dec('0')),
        swr: fractionFromPct(_swr.text),
        nominalReturn: fractionFromPct(_ret.text),
        inflation: fractionFromPct(_inf.text),
        costs: fractionFromPct(_costs.text),
        pensionMonthly: apiAmount(parseEsDecimal(_pension.text) ?? dec('0')),
        pensionAge: int.tryParse(_pensionAge.text),
        homeValue: apiAmount(parseEsDecimal(_home.text) ?? dec('0')),
        volatility: fractionFromPct(_vol.text),
        horizonAge: int.tryParse(_horizon.text),
        includeTaxes: _taxes,
        // Vacío = automático (lo que dice Faro)
        capitalOverride: capital == null ? null : apiAmount(capital),
        clearCapitalOverride: capital == null,
        contributionOverride: contrib == null ? null : apiAmount(contrib),
        clearContributionOverride: contrib == null,
      ));
      refreshPlanes(ref);
      if (!widget.firstTime && mounted) context.go('/planes/independencia');
    } catch (e) {
      setState(() => _error = e is String ? e : apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final p = widget.plan;
    return FormSubmitScope(
      onSubmit: _busy ? null : _save,
      child: FormListView(children: [
        if (widget.firstTime) ...[
          Text('¿Cuándo quieres ser libre financieramente?', style: tt.headlineSmall),
          const Text('Unas pocas preguntas. El capital y lo que ahorras salen solos de Fanal (puedes cambiarlos después).'),
        ],
        FormSection(title: 'Tu objetivo', children: [
          DateField(
            key: const Key('fire-birth'),
            label: 'Tu fecha de nacimiento',
            value: _birth,
            first: DateTime(1920),
            last: DateTime.now(),
            yearFirst: true,
            pickerHelp: 'Nacimiento',
            onChanged: (d) => setState(() => _birth = d),
          ),
          FieldRow(children: [
            UnitsField(
              key: const Key('fire-age'),
              label: 'Edad objetivo',
              controller: _age,
              integer: true,
              suffix: 'años',
              helper: 'Cuándo quieres dejar de depender del sueldo',
            ),
            MoneyField(
              key: const Key('fire-spend'),
              label: 'Gasto mensual deseado',
              controller: _spend,
              suffix: '€/mes',
              helper: 'Neto y en euros de hoy. Con alquiler si no tienes vivienda',
            ),
          ]),
        ]),
        FormSection(title: 'Supuestos', children: [
          FieldRow(children: [
            PercentField(
              label: 'Tasa de retiro',
              controller: _swr,
              helper: '4 % es la referencia clásica; 3,5 % o menos, más prudente',
            ),
            PercentField(label: 'Rentabilidad anual (nominal)', controller: _ret),
          ]),
          FieldRow(children: [
            PercentField(label: 'Inflación', controller: _inf),
            PercentField(label: 'Costes anuales (TER y comisiones)', controller: _costs),
          ]),
        ]),
        FormSection(
          title: 'Capital y aportación',
          subtitle: 'Vacío = automático: lo que sale de tus datos en Fanal',
          children: [
            FieldRow(children: [
              MoneyField(
                label: 'Capital de partida',
                controller: _capital,
                helper: p == null ? 'Automático: tu patrimonio invertible' : 'Automático: ${eur(p.capitalAuto)}',
              ),
              MoneyField(
                label: 'Aportación mensual',
                controller: _contrib,
                suffix: '€/mes',
                helper: p == null
                    ? 'Automático: la media de tus ciclos'
                    : 'Automático: ${eur(p.contributionAuto)}/mes (media de ${p.cyclesUsed} ciclos)',
              ),
            ]),
          ],
        ),
        FormSection(title: 'Pensión y vivienda', children: [
          FieldRow(children: [
            MoneyField(
              label: 'Pensión pública estimada',
              controller: _pension,
              suffix: '€/mes',
              helper: 'Neta y en euros de hoy; 0 si no cuentas con ella',
            ),
            UnitsField(label: 'Edad de la pensión', controller: _pensionAge, integer: true, suffix: 'años'),
          ]),
          MoneyField(
            label: 'Valor de tu vivienda habitual',
            controller: _home,
            helper: 'Si es tuya. Solo para el Impuesto sobre el Patrimonio',
          ),
        ]),
        FormSection(title: 'Monte Carlo', children: [
          FieldRow(children: [
            PercentField(
              label: 'Volatilidad anual',
              controller: _vol,
              helper: '15 % ≈ bolsa mundial; menos con renta fija',
            ),
            UnitsField(
              label: 'Hasta qué edad tiene que durar',
              controller: _horizon,
              integer: true,
              suffix: 'años',
            ),
          ]),
        ]),
        SwitchField(
          title: 'Tener en cuenta los impuestos al retirar',
          subtitle: 'Calcula lo que hay que retirar en bruto para que te quede el gasto deseado',
          value: _taxes,
          onChanged: (v) => setState(() => _taxes = v),
        ),
        if (_error != null) ErrorText(_error),
        FormActions(
          primaryKey: const Key('save-fire'),
          primaryLabel: widget.firstTime ? 'Calcular' : 'Guardar',
          busy: _busy,
          onPrimary: _save,
          expand: context.isCompact,
        ),
        const NoAdviceNote(),
      ]),
    );
  }
}
