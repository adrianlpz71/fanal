import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/api.dart';
import '../../core/dates.dart';
import '../../core/money.dart';
import '../../core/widgets.dart';
import '../auth/auth_controller.dart' show userApi;
import '../imports/import_wizard.dart' show TutorialLinks, ImportSource;
import 'data.dart';
import 'plans_page.dart' show contributionPlansProvider;
import 'tx_sheet.dart';

String _n(int n, String one, String many) => '$n ${n == 1 ? one : many}';

/// Inversiones → Gestionar: objetivos, activos, aportaciones periódicas, plataformas y ajustes
/// (antes, en el menú "⋮"), cada uno con un dato en vivo.
class InvManagePage extends ConsumerWidget {
  const InvManagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final targets = ref.watch(targetsProvider).value;
    final assets = ref.watch(assetsProvider).value;
    final plans = ref.watch(contributionPlansProvider).value;
    final platforms = ref.watch(platformsProvider).value;
    final settings = ref.watch(invSettingsProvider).value;

    String? targetsLive() {
      if (targets == null) return null;
      if (targets.macro.isEmpty) return 'Sin definir';
      final sum = targets.macro.fold(0.0, (s, m) => s + dec(m.target).toDouble());
      return '${_n(targets.macro.length, 'categoría', 'categorías')} · suman ${(sum * 100).round()} %';
    }

    String? assetsLive() {
      if (assets == null) return null;
      final live = assets.where((a) => !a.archived).toList();
      final watch = live.where((a) => a.watchlist).length;
      return '${_n(live.length - watch, 'en cartera', 'en cartera')} · ${_n(watch, 'en watchlist', 'en watchlist')}';
    }

    String? plansLive() {
      if (plans == null) return null;
      final active = plans.where((p) => p.active).toList();
      if (active.isEmpty) return 'Ninguna activa';
      final next = active.map((p) => p.nextDate).whereType<DateTime>().fold<DateTime?>(
            null,
            (a, b) => a == null || b.isBefore(a) ? b : a,
          );
      return '${_n(active.length, 'activa', 'activas')}${next == null ? '' : ' · próxima el ${dayMonth(next)}'}';
    }

    return Scaffold(
      appBar: const FaroAppBar(title: PageTitle('Gestionar inversiones')),
      body: ListView(padding: const EdgeInsets.all(Space.lg), children: [
        ManageGrid(children: [
          ManageCard(
            key: const Key('manage-objetivos'),
            icon: Icons.track_changes,
            title: 'Objetivos de la cartera',
            description: 'Peso de cada categoría y reparto dentro de cada una',
            live: targetsLive(),
            route: '/inversiones/objetivos',
          ),
          ManageCard(
            key: const Key('manage-activos'),
            icon: Icons.list_alt,
            title: 'Activos y watchlist',
            description: 'Fondos, ETF, acciones y cripto que tienes o sigues',
            live: assetsLive(),
            route: '/inversiones/activos',
          ),
          ManageCard(
            key: const Key('manage-periodicas'),
            icon: Icons.event_repeat,
            title: 'Aportaciones periódicas',
            description: 'Planes automáticos de tu broker',
            live: plansLive(),
            route: '/inversiones/periodicas',
          ),
          ManageCard(
            key: const Key('manage-plataformas'),
            icon: Icons.account_balance_outlined,
            title: 'Plataformas',
            description: 'Brokers y exchanges donde tienes tus inversiones',
            live: platforms == null ? null : _n(platforms.length, 'plataforma', 'plataformas'),
            route: '/inversiones/plataformas',
          ),
          ManageCard(
            key: const Key('manage-inv-ajustes'),
            icon: Icons.settings_outlined,
            title: 'Ajustes de inversiones',
            description: 'Aportación habitual, importe mínimo e inicio del seguimiento',
            live: settings == null
                ? null
                : settings.trackStart == null
                    ? 'Seguimiento desde la primera operación'
                    : 'Seguimiento desde el ${fullDate(settings.trackStart!)}',
            route: '/inversiones/ajustes',
          ),
        ]),
      ]),
    );
  }
}

/// Todas las operaciones (las 1.000 más recientes) para la pestaña Operaciones.
final allTxProvider = FutureProvider<List<TxOut>>(
  (ref) async => (await userApi(ref).getInversionesApi().listTransactions(limit: 1000)).data!,
);

/// Inversiones → Operaciones: el listado de todas tus operaciones, por mes, y la importación.
/// (Se rediseña del todo en la fase 3.)
class OperationsPage extends ConsumerWidget {
  const OperationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txs = ref.watch(allTxProvider);
    final assets = {for (final a in ref.watch(assetsProvider).value ?? const <AssetOut>[]) a.id: a.name};
    return Scaffold(
      appBar: FaroAppBar(title: const PageTitle('Operaciones'), actions: [
        BarAction(
          key: const Key('open-import'),
          icon: Icons.upload_file,
          label: 'Importar',
          onPressed: () => context.go('/inversiones/importar'),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('add-tx-ops'),
        icon: const Icon(Icons.add),
        label: const Text('Operación'),
        onPressed: () async {
          await showTxSheet(context, ref);
          ref.invalidate(allTxProvider);
        },
      ),
      body: txs.when(
        loading: () => const SkeletonPage(kpis: 0),
        error: (e, _) => Center(child: Text(apiErrorMessage(e))),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'Aún no hay operaciones',
              text: 'Añádelas a mano o impórtalas desde tu broker.',
              actionLabel: 'Importar operaciones',
              onAction: () => context.go('/inversiones/importar'),
              secondary: const TutorialLinks(
                sources: [ImportSource.myinvestor, ImportSource.neverless, ImportSource.other],
              ),
            );
          }
          final byMonth = <String, List<TxOut>>{};
          for (final t in list) {
            byMonth.putIfAbsent('${monthsShortEs[t.tradeDate.month - 1]} ${t.tradeDate.year}', () => []).add(t);
          }
          // Lista plana (cabecera de mes o operación) para construir solo lo que se ve: puede haber cientos
          final rows = <Object>[
            for (final e in byMonth.entries) ...[e, ...e.value],
          ];
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(allTxProvider),
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: rows.length,
              itemBuilder: (context, i) => switch (rows[i]) {
                MapEntry<String, List<TxOut>>(:final key, :final value) =>
                  SectionHeader(key, trailing: Text(_n(value.length, 'operación', 'operaciones'))),
                final TxOut t => ListRow(
                    key: Key('tx-${t.id}'),
                    lead: dayMonth(t.tradeDate),
                    title: assets[t.assetId] ?? 'Activo',
                    subtitle: [
                      txKindLabel(t.kind),
                      if (t.units != null) '${qty(t.units)}${nbsp}part.',
                      if (t.status == TxOutStatusEnum.pendienteVl) 'pendiente de VL',
                    ].join(' · '),
                    trailing: Text(eur(t.amountEur)),
                    onTap: () => context.go('/inversiones/activo/${t.assetId}'),
                  ),
                _ => const SizedBox.shrink(),
              },
            ),
          );
        },
      ),
    );
  }
}
