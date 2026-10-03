import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import '../../core/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/forms/forms.dart';
import '../../core/money.dart';
import '../imports/import_wizard.dart' show ImportSource, TutorialLinks;
import 'cycle_page.dart';
import 'data.dart';

/// Meses vista: nómina prevista, recurrentes, cuotas, otros previstos y dinero libre.
class ForecastPage extends ConsumerWidget {
  const ForecastPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fc = ref.watch(forecastProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Resumen de meses')),
      body: fc.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (f) => ListView(
          padding: const EdgeInsets.all(Space.md),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_balance_wallet_outlined),
                title: const Text('Deuda fraccionada viva'),
                trailing: Text(eur(f.liveInstallmentDebt)),
                onTap: () => context.go('/gastos/fraccionadas'),
              ),
            ),
            const SizedBox(height: Space.sm),
            // En pantallas anchas, en rejilla: una tarjeta de 1.000 px deja el concepto y el importe
            // demasiado lejos
            if (context.isWide)
              ManageGrid(minWidth: 320, children: [
                for (final m in f.months)
                  MonthSummaryCard(m: m, onTap: () => context.go('/gastos/meses?m=${m.ym}')),
              ])
            else
              for (final m in f.months) MonthSummaryCard(m: m, onTap: () => context.go('/gastos/meses?m=${m.ym}')),
            Padding(
              padding: const EdgeInsets.all(Space.sm),
              child: Text(
                '“Libre” = nómina prevista + recurrentes + cuotas + otros previstos de ese ciclo. '
                '“Acumulado” parte del previsto de fin del ciclo actual.',
                style: FaroText.caption(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Resumen de un ciclo futuro: nómina prevista, compromisos y dinero libre.
class MonthSummaryCard extends StatelessWidget {
  const MonthSummaryCard({super.key, required this.m, this.onTap});
  final ForecastMonthOut m;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    Widget row(String k, String v, {bool bold = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(child: Text(k)),
          Text(eur(v, plus: true), style: bold ? tt.titleMedium?.copyWith(fontWeight: FontWeight.w700) : null),
        ],
      ),
    );
    final free = dec(m.free);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Space.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(m.label, style: tt.titleMedium)),
                  Text('${shortDate(m.start)} – ${shortDate(m.end)}', style: tt.bodySmall),
                  if (onTap != null) const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 6),
              row('Nómina prevista', m.payroll),
              row('Recurrentes', m.recurring),
              row('Cuotas', m.installments),
              if (dec(m.other).sign != 0) row('Otros previstos', m.other),
              const Divider(),
              Row(
                children: [
                  const Expanded(child: Text('Libre')),
                  Text(
                    eur(m.free, plus: true),
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: free.sign < 0 ? context.faro.loss : context.faro.gain,
                    ),
                  ),
                ],
              ),
              row('Acumulado', m.cumulative),
            ],
          ),
        ),
      ),
    );
  }
}

/// Cuentas, saldos y cuadre con el banco.
class AccountsPage extends ConsumerWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accs = ref.watch(accountsProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Cuentas')),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-account'),
        icon: const Icon(Icons.add),
        label: const Text('Cuenta'),
        onPressed: () => _accountDialog(context, ref, null),
      ),
      body: accs.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) => ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            const SectionHeader('Tus cuentas'),
            // ListRow: en el móvil con texto grande el saldo pasa bajo el nombre (al lado, el nombre
            // quedaba en una columna estrecha de 4-5 líneas)
            for (final a in items.where((a) => !a.archived))
              ListRow(
                onTap: () => _accountDialog(context, ref, a),
                leading: Icon(_kindIcon(a.kind.value)),
                title: a.name,
                subtitle: _accountSubtitle(a),
                trailing: MoneyText.api(a.balance),
                // Hueco fijo de la acción principal: los saldos de todas las cuentas, en la misma columna
                reserveAction: true,
                actions: [
                  RowAction(
                    key: Key('reconcile-${a.id}'),
                    icon: Icons.rule,
                    label: 'Cuadrar con el banco',
                    primary: true,
                    onPressed: () => _reconcile(context, ref, a),
                  ),
                  // En el móvil, también en la hoja de la cuenta (al tocar la fila)
                  if (_hasHistory(a))
                    RowAction(
                      key: Key('history-${a.id}'),
                      icon: Icons.bar_chart,
                      label: 'Ver historial de aportaciones',
                      onPressed: () => context.go(_historyRoute(a)),
                    ),
                ],
              ),
            const SizedBox(height: Space.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Space.lg),
              child: ManageGrid(children: [
                ManageCard(
                  key: const Key('manage-importar'),
                  icon: Icons.upload_file,
                  title: 'Importar extracto',
                  description: 'Movimientos del banco (Excel, CSV o TXT) o el PDF de Trade Republic, sin duplicar',
                  live: ref.watch(importBatchesProvider).value == null
                      ? null
                      : _lastImport(ref.watch(importBatchesProvider).value!),
                  route: '/gastos/importar',
                ),
                ManageCard(
                  key: const Key('manage-ciclos'),
                  icon: Icons.history,
                  title: 'Ciclos anteriores',
                  description: 'Cada ciclo de nómina, con su saldo final real',
                  live: ref.watch(cyclesProvider).value == null
                      ? null
                      : '${ref.watch(cyclesProvider).value!.length} ciclos',
                  route: '/gastos/ciclos',
                ),
              ]),
            ),
            const TutorialLinks(sources: [ImportSource.bank, ImportSource.tradeRepublic]),
          ],
        ),
      ),
    );
  }
}

bool _hasHistory(AccountOut a) => a.kind.value == 'ahorro' || a.kind.value == 'refugio';

String _historyRoute(AccountOut a) => '/inversiones/aportaciones?destino=c:${a.id}';

/// "Tipo · Banco" una sola vez (sin el tipo si el nombre ya lo dice) y el saldo con previstos si
/// es distinto.
String _accountSubtitle(AccountOut a) {
  final kind = _kindLabels[a.kind.value] ?? a.kind.value;
  final planned = dec(a.balanceWithPlanned);
  return [
    if (kind.toLowerCase() != a.name.trim().toLowerCase()) kind,
    if (a.bank.isNotEmpty) a.bank,
    if (planned != dec(a.balance)) 'con previstos ${formatEur(planned)}',
  ].join(' · ');
}

String _lastImport(List<BatchOut> batches) {
  final bank = batches.where((b) => b.kind != 'platform').toList();
  if (bank.isEmpty) return 'Ninguna todavía';
  bank.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return 'Última: ${shortDate(bank.first.createdAt)} · ${bank.first.filename}';
}

const _kindLabels = {
  'gastos': 'Cuenta de gastos',
  'refugio': 'Fondo de emergencia',
  'ahorro': 'Ahorro',
  'inversion': 'Efectivo de inversión',
  'efectivo': 'Efectivo',
  'otra': 'Otra',
};

IconData _kindIcon(String kind) => switch (kind) {
      'gastos' => Icons.account_balance_outlined,
      'refugio' => Icons.shield_outlined,
      'ahorro' => Icons.savings_outlined,
      'inversion' => Icons.show_chart,
      'efectivo' => Icons.payments_outlined,
      _ => Icons.wallet_outlined,
    };

/// Alta (con su saldo de hoy) o edición de una cuenta. El saldo se actualiza después con
/// "Cuadrar con el banco" o importando su extracto.
Future<void> _accountDialog(BuildContext context, WidgetRef ref, AccountOut? a) async {
  final name = TextEditingController(text: a?.name);
  final bank = TextEditingController(text: a?.bank);
  final balance = TextEditingController();
  var kind = AccountInKindEnum.ahorro;
  final res = await showFormPanel<String>(
    context,
    builder: (c) => StatefulBuilder(
      builder: (c, setState) => FormPanel(
        title: a == null ? 'Nueva cuenta' : 'Editar cuenta',
        onSubmit: () => Navigator.pop(c, 'save'),
        actions: FormActions(
          primaryLabel: 'Guardar',
          onPrimary: () => Navigator.pop(c, 'save'),
          expand: c.isCompact,
          secondary: [
            // En el móvil, el historial solo se alcanza desde aquí (en la fila sale al pasar el ratón)
            if (a != null && _hasHistory(a))
              TextButton.icon(
                key: Key('account-history-${a.id}'),
                icon: const Icon(Icons.bar_chart, size: 18),
                label: const Text('Ver aportaciones'),
                onPressed: () => Navigator.pop(c, 'history'),
              ),
            if (a != null && a.kind.value != 'gastos')
              TextButton(onPressed: () => Navigator.pop(c, 'archive'), child: const Text('Archivar')),
          ],
        ),
        children: [
          FaroTextField(key: const Key('account-name'), label: 'Nombre', hint: 'P. ej. Ahorros', controller: name,
              autofocus: a == null),
          FaroTextField(label: 'Banco', controller: bank),
          if (a == null) ...[
            SelectField<AccountInKindEnum>(
              label: 'Tipo',
              value: kind,
              options: [
                for (final k in AccountInKindEnum.values.where((k) => k != AccountInKindEnum.gastos))
                  SelectOption(k, _kindLabels[k.value] ?? k.value, icon: _kindIcon(k.value)),
              ],
              onChanged: (v) => setState(() => kind = v),
            ),
            MoneyField(key: const Key('account-balance'), label: 'Saldo de hoy', controller: balance, allowNegative: true),
          ],
        ],
      ),
    ),
  );
  if (res == 'history' && a != null) {
    if (context.mounted) context.go(_historyRoute(a));
    return;
  }
  if (res == null || (res == 'save' && name.text.trim().isEmpty)) return;
  final api = ref.read(apiProvider).getGastosApi();
  try {
    if (a == null) {
      final now = DateTime.now();
      await api.createAccount(accountIn: AccountIn(
        kind: kind,
        name: name.text.trim(),
        bank: bank.text.trim(),
        openingBalance: apiAmount(parseEsDecimal(balance.text) ?? dec('0')),
        openingDate: DateTime.utc(now.year, now.month, now.day),
      ));
    } else if (res == 'archive') {
      await api.patchAccount(accountId: a.id, accountPatch: AccountPatch(archived: true));
    } else {
      await api.patchAccount(accountId: a.id, accountPatch: AccountPatch(name: name.text.trim(), bank: bank.text.trim()));
    }
    refreshGastos(ref);
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }
}

Future<void> _reconcile(BuildContext context, WidgetRef ref, AccountOut a) async {
  final ctrl = TextEditingController();
  final ok = await showFormPanel<bool>(
    context,
    builder: (c) => FormPanel(
      title: 'Cuadrar ${a.name}',
      onSubmit: () => Navigator.pop(c, true),
      actions: FormActions(primaryLabel: 'Cuadrar', onPrimary: () => Navigator.pop(c, true), expand: c.isCompact),
      children: [
        Text('Saldo calculado: ${eur(a.balance)}'),
        MoneyField(
          label: 'Saldo que dice el banco',
          controller: ctrl,
          autofocus: true,
          allowNegative: true,
          helper: 'Si hay diferencia, se crea un movimiento “Ajuste de cuadre”.',
        ),
      ],
    ),
  );
  final v = parseEsDecimal(ctrl.text);
  if (ok != true || v == null) return;
  try {
    final r = await ref
        .read(apiProvider)
        .getGastosApi()
        .reconcile(
          accountId: a.id,
          reconcileIn: ReconcileIn(realBalance: apiAmount(v)),
        );
    refreshGastos(ref);
    if (context.mounted) {
      final d = dec(r.data!.difference);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(d.sign == 0 ? 'Cuadra al céntimo ✓' : 'Ajuste creado: ${formatEur(d, showPlus: true)}')),
      );
    }
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(apiErrorMessage(e))));
    }
  }
}

/// Historial de ciclos.
class CyclesHistoryPage extends ConsumerWidget {
  const CyclesHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycles = ref.watch(cyclesProvider);
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Ciclos')),
      body: cycles.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (items) => ListView(
          children: [
            for (final c in items)
              ListTile(
                title: Text('${c.label}${c.status == CycleOutStatusEnum.open ? ' (actual)' : ''}'),
                subtitle: Text(
                  'Inicial ${eur(c.summary.opening)} · '
                  '${c.status == CycleOutStatusEnum.open ? 'previsto' : 'final'} ${eur(c.summary.expectedEnd)}'
                  '${c.discrepancy != null && dec(c.discrepancy).sign != 0 ? ' · descuadre ${eur(c.discrepancy, plus: true)}' : ''}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.go('/gastos/ciclos/${c.id}'),
              ),
          ],
        ),
      ),
    );
  }
}

class CycleDetailPage extends ConsumerWidget {
  const CycleDetailPage({super.key, required this.id});
  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.watch(cycleDetailProvider(id));
    final idx = CategoryIndex(ref.watch(categoriesProvider).value ?? const []);
    return Scaffold(
      appBar: FaroAppBar(title: PageTitle(c.value?.label ?? 'Ciclo')),
      body: c.when(
        loading: () => const SkeletonPage(),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (cy) => ListView(
          children: [
            ListTile(
              title: Text('Inicial ${eur(cy.summary.opening)} → final ${eur(cy.summary.expectedEnd)}'),
              subtitle: Text(
                'Fijos ${eur(cy.summary.fixedSpend)} · variables ${eur(cy.summary.variableSpend)}'
                ' · cuotas ${eur(cy.summary.installments)} · ahorro ${eur(cy.summary.savings)}',
              ),
            ),
            const Divider(),
            for (final m in cy.movements.where((m) => m.status != MovementOutStatusEnum.cancelled))
              MovementTile(m: m, idx: idx, readOnly: cy.status != CycleDetailOutStatusEnum.open),
          ],
        ),
      ),
    );
  }
}
