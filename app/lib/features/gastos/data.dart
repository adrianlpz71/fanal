import 'dart:async';
import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart' show sessionUserIdProvider, userApi;
import '../../core/offline.dart';
import '../../core/tokens.dart';

GastosApi _api(Ref ref) => userApi(ref).getGastosApi();

final gastosSettingsProvider = FutureProvider<GastosSettingsOut>(
  (ref) async => (await _api(ref).getSettings()).data!,
);

/// ¿Se puede deshacer el último "He cobrado"? (solo mientras su ciclo siga abierto)
final paydayUndoProvider = FutureProvider<PaydayUndoOut>(
  (ref) async => (await _api(ref).paydayUndoStatus()).data!,
);

/// Ciclo abierto. `null` si el módulo está configurado pero no hay ciclo abierto.
/// Sin conexión se enseña el último ciclo guardado (y `offlineSinceProvider` dice de cuándo es).
final currentCycleProvider = FutureProvider<CycleDetailOut?>((ref) async {
  final user = ref.watch(sessionUserIdProvider);
  try {
    final c = (await _api(ref).currentCycle()).data;
    ref.read(offlineSinceProvider.notifier).set(null);
    if (c != null && user != null) unawaited(saveCycleCache(user, c));
    // Con red otra vez: se envía lo que quedó en cola
    unawaited(ref.read(pendingMovementsProvider.notifier).flush());
    return c;
  } on DioException catch (e) {
    if (e.response?.statusCode == 404 || e.response?.statusCode == 409) return null;
    if (isNetworkError(e) && user != null) {
      final cached = await loadCycleCache(user);
      if (cached != null) {
        ref.read(offlineSinceProvider.notifier).set(cached.savedAt);
        return cached.cycle;
      }
    }
    rethrow;
  }
});

final categoriesProvider = FutureProvider<List<CategoryOut>>(
  (ref) async => (await _api(ref).listCategories()).data!,
);

final accountsProvider = FutureProvider<List<AccountOut>>(
  (ref) async => (await _api(ref).listAccounts()).data!,
);

final recurringProvider = FutureProvider<List<RecurringOut>>(
  (ref) async => (await _api(ref).listRecurring()).data!,
);

final plansProvider = FutureProvider.family<List<InstallmentPlanOut>, bool>(
  (ref, includeClosed) async =>
      (await _api(ref).listPlans(includeClosed: includeClosed)).data!,
);

final forecastProvider = FutureProvider<ForecastOut>(
  (ref) async => (await _api(ref).getForecast()).data!,
);

final cyclesProvider = FutureProvider<List<CycleOut>>(
  (ref) async => (await _api(ref).listCycles()).data!,
);

final cycleDetailProvider = FutureProvider.family<CycleDetailOut, String>(
  (ref, id) async => (await _api(ref).getCycle(cycleId: id)).data!,
);

/// Ciclos futuros para navegar mes a mes (12 por delante).
final monthsAheadProvider = FutureProvider<ForecastOut>(
  (ref) async => (await _api(ref).getForecast(months: 12)).data!,
);

/// Un ciclo futuro con sus previstos (clave AAAA-MM).
final monthProvider = FutureProvider.family<MonthOut, String>(
  (ref, ym) async => (await _api(ref).getMonth(ym: ym)).data!,
);

/// Tras cualquier cambio en movimientos/ciclos, refresca todo lo que depende de ellos.
void refreshGastos(WidgetRef ref) {
  ref.invalidate(currentCycleProvider);
  ref.invalidate(accountsProvider);
  ref.invalidate(forecastProvider);
  ref.invalidate(plansProvider);
  ref.invalidate(recurringProvider);
  ref.invalidate(cyclesProvider);
  ref.invalidate(cycleDetailProvider);
  ref.invalidate(monthsAheadProvider);
  ref.invalidate(monthProvider);
  ref.invalidate(paydayUndoProvider);
}

/// Índice de categorías por id, con la ruta "Padre › Hija" para mostrar.
class CategoryIndex {
  CategoryIndex(List<CategoryOut> cats) {
    for (final c in cats) {
      byId[c.id] = c;
    }
  }
  final Map<String, CategoryOut> byId = {};

  CategoryOut? operator [](String? id) => id == null ? null : byId[id];

  String label(String? id) {
    final c = this[id];
    if (c == null) return 'Sin categoría';
    final p = this[c.parentId];
    return p == null ? c.name : '${p.name} › ${c.name}';
  }

  Color color(String? id) => _parseColor((this[id] ?? this[this[id]?.parentId])?.color);
  IconData icon(String? id) => categoryIcon(this[id]?.icon);

  /// Círculo con el icono de la categoría, legible en los dos temas. Los colores casi grises
  /// (Transferencias, Finanzas, Sin categoría) van con los tonos neutros del tema, y el resto se
  /// aclara u oscurece hasta tener contraste 3:1 con su círculo (los amarillos sobre fondo claro,
  /// los oscuros sobre fondo oscuro).
  Widget avatar(BuildContext context, String? id, {double radius = 18, double size = 18}) {
    final cs = Theme.of(context).colorScheme;
    final c = color(id);
    if (HSLColor.fromColor(c).saturation < 0.25) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: cs.surfaceContainerHighest,
        child: Icon(icon(id), color: cs.onSurfaceVariant, size: size),
      );
    }
    final bg = c.withValues(alpha: 0.18);
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: Icon(icon(id), color: _readable(c, Color.alphaBlend(bg, cs.surface), cs.onSurface), size: size),
    );
  }
}

/// [fg] acercado poco a poco a [toward] hasta tener contraste 3:1 (WCAG para iconos) con [bg].
Color _readable(Color fg, Color bg, Color toward) {
  final lb = bg.computeLuminance();
  double ratio(Color a) {
    final la = a.computeLuminance();
    return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
  }

  var out = fg;
  for (var t = 0.1; ratio(out) < 3 && t <= 1.0; t += 0.1) {
    out = Color.lerp(fg, toward, t)!;
  }
  return out;
}

Color _parseColor(String? hex) {
  if (hex == null || !hex.startsWith('#') || hex.length < 7) return FaroColors.neutral;
  return Color(int.parse('FF${hex.substring(1, 7)}', radix: 16));
}

const _icons = <String, IconData>{
  'home': Icons.home_outlined,
  'phone_android': Icons.phone_android,
  'subscriptions': Icons.subscriptions_outlined,
  'terminal': Icons.terminal,
  'style': Icons.style_outlined,
  'casino': Icons.casino_outlined,
  'restaurant': Icons.restaurant,
  'directions_bus': Icons.directions_bus_outlined,
  'flight': Icons.flight,
  'fitness_center': Icons.fitness_center,
  'face': Icons.face,
  'checkroom': Icons.checkroom,
  'sports_esports': Icons.sports_esports_outlined,
  'shopping_bag': Icons.shopping_bag_outlined,
  'celebration': Icons.celebration_outlined,
  'menu_book': Icons.menu_book_outlined,
  'account_balance': Icons.account_balance_outlined,
  'help_outline': Icons.help_outline,
  'payments': Icons.payments_outlined,
  'swap_horiz': Icons.swap_horiz,
};

IconData categoryIcon(String? name) => _icons[name] ?? Icons.label_outline;

const monthsShort = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];
String shortDate(DateTime? d) => d == null ? '' : '${d.day} ${monthsShort[d.month - 1]}';

// --- Fase 2b -----------------------------------------------------------------------------
final peopleProvider = FutureProvider<List<PersonOut>>(
  (ref) async => (await _api(ref).listPeople()).data!,
);

final personSharesProvider = FutureProvider.family<List<ShareOut>, String>(
  (ref, id) async => (await _api(ref).personShares(personId: id)).data!,
);

final debtsProvider = FutureProvider<List<DebtOut>>(
  (ref) async => (await _api(ref).listDebts()).data!,
);

final trackersProvider = FutureProvider<List<TrackerOut>>(
  (ref) async => (await _api(ref).listTrackers()).data!,
);

final statsProvider = FutureProvider.family<StatsOut, int>(
  (ref, cycles) async => (await _api(ref).stats(cycles: cycles)).data!,
);

final rulesProvider = FutureProvider<List<RuleOut>>(
  (ref) async => (await _api(ref).listRules()).data!,
);

final importBatchesProvider = FutureProvider<List<BatchOut>>(
  (ref) async => (await userApi(ref).getImportsApi().listBatches()).data!,
);

/// Refresco ampliado (2b): también personas, deudas, seguimientos y estadísticas.
void refreshAll(WidgetRef ref) {
  refreshGastos(ref);
  ref.invalidate(peopleProvider);
  ref.invalidate(personSharesProvider);
  ref.invalidate(debtsProvider);
  ref.invalidate(trackersProvider);
  ref.invalidate(statsProvider);
  ref.invalidate(importBatchesProvider);
  ref.invalidate(categoriesProvider);
  ref.invalidate(rulesProvider);
}

void showSnack(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

/// Mes anterior de una clave AAAA-MM.
String prevYm(String ym) {
  final p = ym.split('-');
  var y = int.parse(p[0]);
  var m = int.parse(p[1]) - 1;
  if (m == 0) {
    m = 12;
    y -= 1;
  }
  return '$y-${m.toString().padLeft(2, '0')}';
}
