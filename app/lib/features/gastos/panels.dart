import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/money.dart';
import '../../core/widgets.dart';
import 'data.dart';
import 'fijos_page.dart' show fixedPanelProvider;

String _n(int n, String one, String many) => '$n ${n == 1 ? one : many}';

/// Gastos → Compromisos: lo que ya está comprometido o pendiente con otros, con un dato en vivo
/// de cada cosa (antes, seis entradas del menú "⋮").
class GastosCommitmentsPage extends ConsumerWidget {
  const GastosCommitmentsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(plansProvider(false)).value;
    final rec = ref.watch(recurringProvider).value;
    final fixed = ref.watch(fixedPanelProvider).value;
    final debts = ref.watch(debtsProvider).value;
    final people = ref.watch(peopleProvider).value;
    final trackers = ref.watch(trackersProvider).value;

    String? installmentsLive() {
      if (plans == null) return null;
      final active = plans.where((p) => p.status == 'activa').toList();
      final left = active.fold(Decimal.zero, (s, p) => s + dec(p.remainingAmount));
      return active.isEmpty ? 'Ninguna activa' : '${_n(active.length, 'activa', 'activas')} · ${formatEur(left)} pendientes';
    }

    String? recurringLive() {
      if (rec == null) return null;
      final active = rec.where((r) => r.active).toList();
      final monthly = active.fold(Decimal.zero, (s, r) => s + dec(r.monthlyCost));
      return '${_n(active.length, 'activo', 'activos')} · ${formatEur(monthly.abs())}/mes';
    }

    String? fixedLive() {
      if (fixed == null) return null;
      final review = fixed.items.where((i) => i.review == 'revisar').length;
      return [
        '${formatEur(dec(fixed.monthlyTotal))}/mes',
        if (review > 0) '$review por revisar',
        if (fixed.suggestions.isNotEmpty) _n(fixed.suggestions.length, 'suscripción nueva', 'suscripciones nuevas'),
        if (fixed.reviewDue) 'toca revisarlos',
      ].join(' · ');
    }

    String? debtsLive() {
      if (debts == null) return null;
      final open = debts.where((d) => d.status.value != 'saldada').toList();
      if (open.isEmpty) return 'Ninguna pendiente';
      final owe = open
          .where((d) => d.direction.value == 'debo')
          .fold(Decimal.zero, (s, d) => s + dec(d.remaining));
      final owed = open
          .where((d) => d.direction.value != 'debo')
          .fold(Decimal.zero, (s, d) => s + dec(d.remaining));
      return [
        if (owe > Decimal.zero) 'Debes ${formatEur(owe)}',
        if (owed > Decimal.zero) 'Te deben ${formatEur(owed)}',
        _n(open.length, 'activa', 'activas'),
      ].join(' · ');
    }

    String? peopleLive() {
      if (people == null) return null;
      final owed = people.fold(Decimal.zero, (s, p) => s + dec(p.owedToMe));
      final owe = people.fold(Decimal.zero, (s, p) => s + dec(p.iOwe));
      if (people.isEmpty) return 'Sin gastos compartidos';
      return [
        'Te deben ${formatEur(owed)}',
        if (owe > Decimal.zero) 'debes ${formatEur(owe)}',
        _n(people.length, 'persona', 'personas'),
      ].join(' · ');
    }

    String? trackersLive() {
      if (trackers == null) return null;
      final active = trackers.where((t) => !t.archived).length;
      return active == 0 ? 'Ninguno' : _n(active, 'activo', 'activos');
    }

    return Scaffold(
      appBar: const FaroAppBar(title: PageTitle('Compromisos')),
      body: ListView(padding: const EdgeInsets.all(Space.lg), children: [
        ManageGrid(children: [
          ManageCard(
            key: const Key('manage-fraccionadas'),
            icon: Icons.credit_card,
            title: 'Fraccionadas',
            description: 'Compras a plazos y sus cuotas',
            live: installmentsLive(),
            route: '/gastos/fraccionadas',
          ),
          ManageCard(
            key: const Key('manage-recurrentes'),
            icon: Icons.event_repeat,
            title: 'Recurrentes',
            description: 'Cargos que se repiten cada mes o cada año',
            live: recurringLive(),
            route: '/gastos/recurrentes',
          ),
          ManageCard(
            key: const Key('manage-fijos'),
            icon: Icons.content_cut,
            title: 'Reducir fijos',
            description: 'Suscripciones y gastos fijos, y cuánto ahorras',
            live: fixedLive(),
            route: '/gastos/fijos',
          ),
          ManageCard(
            key: const Key('manage-deudas'),
            icon: Icons.account_balance_outlined,
            title: 'Deudas',
            description: 'Préstamos reales: lo que debes o te deben',
            live: debtsLive(),
            route: '/gastos/deudas',
          ),
          ManageCard(
            key: const Key('manage-personas'),
            icon: Icons.group_outlined,
            title: 'Personas',
            description: 'Gastos compartidos: quién te debe y a quién debes',
            live: peopleLive(),
            route: '/gastos/personas',
          ),
          ManageCard(
            key: const Key('manage-seguimientos'),
            icon: Icons.timeline,
            title: 'Seguimientos',
            description: 'Botes con nombre que se alimentan de categorías o palabras',
            live: trackersLive(),
            route: '/gastos/seguimientos',
          ),
        ]),
      ]),
    );
  }
}

/// Gastos → Gestionar: configuración del apartado.
class GastosManagePage extends ConsumerWidget {
  const GastosManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cats = ref.watch(categoriesProvider).value;
    final rules = ref.watch(rulesProvider).value;
    final s = ref.watch(gastosSettingsProvider).value;
    return Scaffold(
      appBar: const FaroAppBar(title: PageTitle('Gestionar gastos')),
      body: ListView(padding: const EdgeInsets.all(Space.lg), children: [
        ManageGrid(children: [
          ManageCard(
            key: const Key('manage-categorias'),
            icon: Icons.category_outlined,
            title: 'Categorías y reglas',
            description: 'Tus categorías y las reglas que Fanal aprende al categorizar',
            live: cats == null || rules == null
                ? null
                : '${_n(cats.where((c) => !c.archived).length, 'categoría', 'categorías')} · '
                    '${_n(rules.length, 'regla', 'reglas')}',
            route: '/gastos/categorias',
          ),
          ManageCard(
            key: const Key('manage-ajustes'),
            icon: Icons.settings_outlined,
            title: 'Ajustes de gastos',
            description: 'Día de cobro, nómina, meses vista y fondo de emergencia',
            live: s == null
                ? null
                : [
                    'Cobro el día ${s.paydayDay}',
                    if (s.usualPayroll != null) 'nómina ${eur(s.usualPayroll)}',
                  ].join(' · '),
            route: '/gastos/ajustes',
          ),
        ]),
      ]),
    );
  }
}
