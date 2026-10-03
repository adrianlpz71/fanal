import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/dates.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../gastos/data.dart' show showSnack;
import '../inversiones/data.dart' show pct, fractionFromPct;
import 'data.dart';

/// Tipo de objetivo → (nombre, unidad).
const goalKinds = {
  GoalInKindEnum.edadFi: ('Edad de independencia', 'años'),
  GoalInKindEnum.fondoEmergencia: ('Fondo de emergencia completo', '€'),
  GoalInKindEnum.patrimonio: ('Patrimonio neto', '€'),
  GoalInKindEnum.carteraEnFecha: ('Cartera en una fecha', '€'),
  GoalInKindEnum.fijosMax: ('Gastos fijos como máximo', '€/mes'),
  GoalInKindEnum.tasaAhorroMin: ('Tasa de ahorro mínima', '%'),
};

/// Planes → Objetivos: en camino o fuera de plan, con su progreso; se crean, editan y borran.
class GoalsTab extends ConsumerWidget {
  const GoalsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goals = ref.watch(goalsProvider);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-goal'),
        icon: const Icon(Icons.add),
        label: const Text('Objetivo'),
        onPressed: () => showGoalForm(context),
      ),
      body: goals.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) => items.isEmpty
            ? EmptyState(
                icon: Icons.flag_outlined,
                title: 'Sin objetivos',
                text: 'Por ejemplo: libre a los 42, 10.000 € de patrimonio o fijos de 600 €/mes como máximo.',
                actionLabel: 'Nuevo objetivo',
                onAction: () => showGoalForm(context),
              )
            : ListView(padding: const EdgeInsets.fromLTRB(Space.md, Space.sm, Space.md, 96), children: [
                for (final g in items) _GoalCard(g: g),
              ]),
      ),
    );
  }
}

String _value(GoalOut g, String? v) {
  if (v == null) return '—';
  return switch (g.kind.value) {
    'edad_fi' => ageText(v),
    'tasa_ahorro_min' => pct(v, decimals: 1),
    _ => eur(v),
  };
}

String _target(GoalOut g) => switch (g.kind.value) {
      'tasa_ahorro_min' => pct(g.targetValue, decimals: 0),
      'edad_fi' => '${g.targetValue} años',
      _ => eur(g.targetValue),
    };

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.g});
  final GoalOut g;

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final ok = await confirmDialog(context, title: '¿Borrar «${g.name}»?', message: 'No se puede deshacer.');
    if (!ok) return;
    try {
      await ref.read(apiProvider).getPlanesApi().deleteGoal(goalId: g.id);
      ref.invalidate(goalsProvider);
    } catch (e) {
      if (context.mounted) showSnack(context, apiErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final caption = FaroText.caption(context);
    return Card(
      key: Key('goal-${g.id}'),
      child: Padding(
        padding: const EdgeInsets.all(Space.lg),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, spacing: Space.sm, children: [
          Wrap(spacing: Space.sm, runSpacing: Space.xs, crossAxisAlignment: WrapCrossAlignment.center, children: [
            Text(g.name, style: Theme.of(context).textTheme.titleMedium),
            if (g.onTrack != null)
              StatusPill(g.onTrack! ? 'En camino' : 'Fuera de plan', tone: g.onTrack! ? PillTone.ok : PillTone.warning),
          ]),
          Text('${g.detail}: ${_value(g, g.current)}${g.targetValue == null || dec(g.targetValue).sign == 0 ? '' : ' · objetivo ${_target(g)}'}'
              '${g.targetDate == null ? '' : ' el ${fullDate(g.targetDate!)}'}'),
          if (g.progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(Radii.sm),
              child: LinearProgressIndicator(value: dec(g.progress).toDouble().clamp(0, 1), minHeight: 8),
            ),
          if (g.progress != null) Text('${pct(g.progress, decimals: 0)} del objetivo', style: caption),
          Wrap(spacing: Space.sm, children: [
            OutlinedButton.icon(
              key: Key('goal-edit-${g.id}'),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar'),
              onPressed: () => showGoalForm(context, existing: g),
            ),
            TextButton.icon(
              key: Key('goal-delete-${g.id}'),
              icon: Icon(Icons.delete_outline, size: 18, color: Theme.of(context).colorScheme.error),
              label: Text('Borrar', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onPressed: () => _delete(context, ref),
            ),
          ]),
        ]),
      ),
    );
  }
}

Future<void> showGoalForm(BuildContext context, {GoalOut? existing}) =>
    showFormPanel<void>(context, builder: (_) => _GoalForm(existing: existing));

class _GoalForm extends ConsumerStatefulWidget {
  const _GoalForm({this.existing});
  final GoalOut? existing;

  @override
  ConsumerState<_GoalForm> createState() => _GoalFormState();
}

class _GoalFormState extends ConsumerState<_GoalForm> {
  late GoalInKindEnum _kind = widget.existing == null
      ? GoalInKindEnum.patrimonio
      : GoalInKindEnum.values.firstWhere((k) => k.value == widget.existing!.kind.value);
  late final _name = TextEditingController(text: widget.existing?.name ?? '');
  late final _value = TextEditingController(text: _initialValue());
  late DateTime? _date = widget.existing?.targetDate;
  bool _busy = false;
  String? _error;

  String _initialValue() {
    final g = widget.existing;
    if (g?.targetValue == null) return '';
    final v = dec(g!.targetValue);
    return g.kind.value == 'tasa_ahorro_min'
        ? (v * dec('100')).toString().replaceAll('.', ',')
        : v.toString().replaceAll('.', ',');
  }

  @override
  void dispose() {
    _name.dispose();
    _value.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final v = _kind == GoalInKindEnum.tasaAhorroMin ? fractionFromPct(_value.text) : parseEsDecimal(_value.text)?.toString();
    if (v == null) {
      setState(() => _error = 'Escribe el objetivo');
      return;
    }
    if (_kind == GoalInKindEnum.carteraEnFecha && _date == null) {
      setState(() => _error = 'Elige la fecha');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final body = GoalIn(
      kind: _kind,
      name: _name.text.trim().isEmpty ? goalKinds[_kind]!.$1 : _name.text.trim(),
      targetValue: v,
      targetDate: _kind == GoalInKindEnum.carteraEnFecha && _date != null
          ? DateTime.utc(_date!.year, _date!.month, _date!.day)
          : null,
    );
    try {
      final api = ref.read(apiProvider).getPlanesApi();
      if (widget.existing == null) {
        await api.createGoal(goalIn: body);
      } else {
        await api.updateGoal(goalId: widget.existing!.id, goalIn: body);
      }
      ref.invalidate(goalsProvider);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _error = apiErrorMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = goalKinds[_kind]!.$2;
    final Widget valueField = switch (_kind) {
      GoalInKindEnum.edadFi => UnitsField(key: const Key('goal-value'), label: 'Edad', controller: _value, integer: true, suffix: unit),
      GoalInKindEnum.tasaAhorroMin => PercentField(key: const Key('goal-value'), label: 'Tasa de ahorro', controller: _value),
      _ => MoneyField(key: const Key('goal-value'), label: 'Objetivo', controller: _value, suffix: unit),
    };
    return FormPanel(
      title: widget.existing == null ? 'Nuevo objetivo' : 'Editar objetivo',
      onSubmit: _busy ? null : _save,
      actions: FormActions(
        primaryKey: const Key('goal-save'),
        primaryLabel: widget.existing == null ? 'Crear' : 'Guardar',
        busy: _busy,
        onPrimary: _save,
        expand: context.isCompact,
      ),
      children: [
        SelectField<GoalInKindEnum>(
          label: 'Tipo',
          value: _kind,
          options: [for (final e in goalKinds.entries) SelectOption(e.key, e.value.$1)],
          onChanged: widget.existing == null ? (v) => setState(() => _kind = v) : null,
          helper: widget.existing == null ? null : 'El tipo no se cambia: crea otro objetivo',
        ),
        FaroTextField(label: 'Nombre', controller: _name, hint: goalKinds[_kind]!.$1),
        valueField,
        if (_kind == GoalInKindEnum.carteraEnFecha)
          DateField(
            key: const Key('goal-date'),
            label: 'Fecha',
            value: _date,
            first: DateTime.now(),
            last: DateTime(2100),
            onChanged: (d) => setState(() => _date = d),
          ),
        if (_error != null) ErrorText(_error),
      ],
    );
  }
}
