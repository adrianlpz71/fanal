
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import 'data.dart';

// --- Categorías y reglas ---------------------------------------------------------------------
class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesProvider).value ?? const [];
    final rules = ref.watch(rulesProvider).value ?? const [];
    final idx = CategoryIndex(cats);
    final roots = cats.where((c) => c.parentId == null && !c.archived).toList();
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Categorías')),
      floatingActionButton: FloatingActionButton.extended(
        tooltip: 'Nueva categoría',
        onPressed: () => _editCategory(context, ref, roots: roots),
        icon: const Icon(Icons.add),
        label: const Text('Categoría'),
      ),
      body: ListView(padding: const EdgeInsets.only(bottom: 96), children: [
        // Agrupadas por tipo (el nombre del grupo dice el tipo: no hace falta repetirlo en cada fila)
        for (final g in _kindGroups)
          if (roots.any((r) => _kindGroup(r) == g.$1)) ...[
            SectionHeader(g.$2),
            for (final r in roots.where((r) => _kindGroup(r) == g.$1)) ...[
              ListTile(
                leading: Icon(idx.icon(r.id), color: idx.color(r.id)),
                title: Text(r.name),
                onTap: () => _editCategory(context, ref, existing: r, roots: roots),
              ),
              for (final s in cats.where((c) => c.parentId == r.id && !c.archived))
                // Altura normal (≥ 48 px para tocar), sangrada bajo su categoría
                ListTile(
                  contentPadding: const EdgeInsets.only(left: 72, right: Space.lg),
                  title: Text(s.name),
                  onTap: () => _editCategory(context, ref, existing: s, roots: roots),
                ),
            ],
          ],
        const Divider(height: 32),
        const SectionHeader('Reglas aprendidas', padding: EdgeInsets.fromLTRB(Space.lg, 0, Space.lg, Space.xs)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.lg),
          child: Text(
              rules.isEmpty
                  ? 'Aún no hay reglas: se crean al elegir la categoría de un concepto.'
                  : 'Se crean solas cuando eliges o corriges la categoría de un concepto.',
              style: FaroText.caption(context)),
        ),
        for (final r in rules)
          ListTile(
            title: Text('«${r.pattern}»'),
            subtitle: Text('→ ${idx.label(r.categoryId)} · ${r.hits} usos'),
            trailing: IconButton(
              tooltip: 'Borrar la regla',
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await confirmDialog(context,
                    title: '¿Borrar la regla «${r.pattern}»?',
                    message: 'Los movimientos ya categorizados no cambian. Si vuelves a elegir la categoría, se aprende otra vez.');
                if (!ok) return;
                await ref.read(apiProvider).getGastosApi().deleteRule(ruleId: r.id);
                ref.invalidate(rulesProvider);
              },
            ),
          ),
      ]),
    );
  }
}

/// Tipos de categoría con su nombre legible, en el orden en que se muestran.
const _kindGroups = [
  ('fijo', 'Gastos fijos'),
  ('gasto', 'Gastos variables'),
  ('ingreso', 'Ingresos'),
  ('transferencia', 'Traspasos'),
  ('otra', 'Otras'),
];

/// Grupo de una categoría: los gastos se separan en fijos y variables.
String _kindGroup(CategoryOut c) => switch (c.kind) {
      'gasto' => c.fixed ? 'fijo' : 'gasto',
      'ingreso' || 'transferencia' => c.kind,
      _ => 'otra',
    };

Future<void> _editCategory(BuildContext context, WidgetRef ref,
    {CategoryOut? existing, required List<CategoryOut> roots}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  bool fixed = existing?.fixed ?? false;
  String? parent = existing?.parentId;
  final ok = await showFormPanel<String>(
    context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => FormPanel(
        title: existing == null ? 'Nueva categoría' : 'Editar categoría',
        onSubmit: () => Navigator.pop(c, 'save'),
        actions: FormActions(
          primaryLabel: 'Guardar',
          onPrimary: () => Navigator.pop(c, 'save'),
          expand: c.isCompact,
          secondary: [
            if (existing != null) TextButton(onPressed: () => Navigator.pop(c, 'archive'), child: const Text('Archivar')),
          ],
        ),
        children: [
          FaroTextField(label: 'Nombre', controller: name),
          if (existing == null)
            SelectField<String?>(
              label: 'Dentro de',
              value: parent,
              options: [
                const SelectOption(null, '— (categoría principal)'),
                for (final r in roots) SelectOption(r.id, r.name),
              ],
              onChanged: (v) => setState(() => parent = v),
            ),
          SwitchField(title: 'Gasto fijo', value: fixed, onChanged: (v) => setState(() => fixed = v)),
        ],
      ),
    ),
  );
  if (ok == null) return;
  final api = ref.read(apiProvider).getGastosApi();
  try {
    if (existing == null && ok == 'save' && name.text.trim().isNotEmpty) {
      await api.createCategory(categoryIn: CategoryIn(name: name.text.trim(), parentId: parent, fixed: fixed));
    } else if (existing != null) {
      await api.patchCategory(
        categoryId: existing.id,
        categoryPatch: ok == 'archive'
            ? CategoryPatch(archived: true)
            : CategoryPatch(name: name.text.trim(), fixed: fixed),
      );
    }
    ref.invalidate(categoriesProvider);
  } catch (e) {
    if (context.mounted) showSnack(context, apiErrorMessage(e));
  }
}

// --- Ajustes del módulo de gastos -------------------------------------------------------------
class GastosSettingsPage extends ConsumerStatefulWidget {
  const GastosSettingsPage({super.key});

  @override
  ConsumerState<GastosSettingsPage> createState() => _GastosSettingsPageState();
}

class _GastosSettingsPageState extends ConsumerState<GastosSettingsPage> {
  final _payday = TextEditingController();
  final _payroll = TextEditingController();
  final _months = TextEditingController();
  final _target = TextEditingController();
  final _monthly = TextEditingController();
  bool _loaded = false;

  String _fmt(String? s) => s == null ? '' : dec(s).toStringAsFixed(2).replaceAll('.', ',');

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(gastosSettingsProvider).value;
    if (s != null && !_loaded) {
      _loaded = true;
      _payday.text = '${s.paydayDay}';
      _payroll.text = _fmt(s.usualPayroll);
      _months.text = '${s.forecastMonths}';
      _target.text = _fmt(s.emergencyTarget);
      _monthly.text = _fmt(s.monthlyRefugio);
    }
    String? amt(TextEditingController c) => parseEsDecimal(c.text) == null ? null : apiAmount(parseEsDecimal(c.text)!);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Ajustes de gastos')),
      body: FormListView(children: [
        UnitsField(label: 'Día de cobro habitual', controller: _payday, integer: true, helper: 'Si cae en fin de semana, el lunes'),
        MoneyField(label: 'Nómina habitual', controller: _payroll),
        UnitsField(label: 'Meses vista a mostrar', controller: _months, integer: true),
        MoneyField(label: 'Objetivo del fondo de emergencia', controller: _target),
        MoneyField(label: 'Aportación mensual al fondo', controller: _monthly),
        FormActions(
          primaryLabel: 'Guardar',
          onPrimary: () async {
            try {
              await ref.read(apiProvider).getGastosApi().patchSettings(
                    gastosSettingsIn: GastosSettingsIn(
                      paydayDay: int.tryParse(_payday.text),
                      usualPayroll: amt(_payroll),
                      forecastMonths: int.tryParse(_months.text),
                      emergencyTarget: amt(_target),
                      monthlyRefugio: amt(_monthly),
                    ),
                  );
              ref.invalidate(gastosSettingsProvider);
              refreshGastos(ref);
              if (context.mounted) showSnack(context, 'Ajustes guardados');
            } catch (e) {
              if (context.mounted) showSnack(context, apiErrorMessage(e));
            }
          },
        ),
      ]),
    );
  }
}
