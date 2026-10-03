import 'package:faro_api/faro_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart' show userApi;

AnalyticsApi _api(Ref ref) => userApi(ref).getAnalyticsApi();

final networthProvider = FutureProvider<NetWorthOut>((ref) async => (await _api(ref).getNetworth()).data!);

final networthHistoryProvider =
    FutureProvider<List<NetWorthPointOut>>((ref) async => (await _api(ref).getNetworthHistory()).data!);

/// Evolución por componente (cada cuenta y cada activo), con deudas, fraccionadas y el neto.
final evolutionProvider =
    FutureProvider<NetWorthEvolutionOut>((ref) async => (await _api(ref).getNetworthEvolution()).data!);

final milestonesProvider = FutureProvider<MilestonesOut>((ref) async => (await _api(ref).getMilestones()).data!);

/// Ámbito de la rentabilidad: toda la cartera, una categoría o un activo.
typedef PerfScope = ({String? assetId, String? classId});

final performanceProvider = FutureProvider.family<PerformanceOut, PerfScope>(
  (ref, s) async => (await _api(ref).getPerformance(assetId: s.assetId, classId: s.classId)).data!,
);

final exposureProvider = FutureProvider<ExposureOut>((ref) async => (await _api(ref).getExposure()).data!);

void refreshAnalytics(WidgetRef ref) {
  ref.invalidate(networthProvider);
  ref.invalidate(networthHistoryProvider);
  ref.invalidate(evolutionProvider);
  ref.invalidate(milestonesProvider);
  ref.invalidate(performanceProvider);
  ref.invalidate(exposureProvider);
}

const accountKindLabels = {'gastos': 'Cuenta de gastos', 'ahorro': 'Ahorro', 'refugio': 'Fondo de emergencia'};

/// Nombre del grupo de un componente: tipo de cuenta o de activo.
String groupLabel(NetWorthComponentOut c) {
  if (c.kind == NetWorthComponentOutKindEnum.cuenta) return accountKindLabels[c.group] ?? c.group;
  const assets = {'fondo': 'Fondos', 'etf': 'ETF', 'accion': 'Acciones', 'cripto': 'Cripto', 'cuenta': 'Cuentas remuneradas'};
  return assets[c.group] ?? 'Otros';
}

const monthNames = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'sep', 'oct', 'nov', 'dic'];

/// Días → "2 años", "1 año y 3 meses", "5 meses", "1 mes" (meses medios de 30,44 días).
String spanText(int days) {
  final total = days * 100 ~/ 3044;
  final years = total ~/ 12, months = total % 12;
  String y(int n) => '$n ${n == 1 ? 'año' : 'años'}';
  String m(int n) => '$n ${n == 1 ? 'mes' : 'meses'}';
  if (years == 0) return m(months);
  return months == 0 ? y(years) : '${y(years)} y ${m(months)}';
}
