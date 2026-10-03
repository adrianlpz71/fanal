import 'package:faro_api/faro_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/auth_controller.dart' show userApi;

PlanesApi _api(Ref ref) => userApi(ref).getPlanesApi();

final fireSettingsProvider =
    FutureProvider<FireSettingsOut>((ref) async => (await _api(ref).getFireSettings()).data!);
final firePlanProvider = FutureProvider<FirePlanOut>((ref) async => (await _api(ref).getFire()).data!);
final goalsProvider = FutureProvider<List<GoalOut>>((ref) async => (await _api(ref).listGoals()).data!);

/// Impuestos: nóminas del año (referencia), la base que guardaste y ganancias e ingresos del año.
final taxPrefillProvider =
    FutureProvider<TaxPrefillOut>((ref) async => (await _api(ref).taxPrefill(year: DateTime.now().year)).data!);
final quartersProvider =
    FutureProvider<List<QuarterItemOut>>((ref) async => (await _api(ref).listQuarters()).data!);
final reviewProvider = FutureProvider.family<QuarterReviewOut, String>(
    (ref, quarter) async => (await _api(ref).getReview(quarter: quarter)).data!);

void refreshPlanes(WidgetRef ref) {
  ref.invalidate(fireSettingsProvider);
  ref.invalidate(firePlanProvider);
  ref.invalidate(goalsProvider);
  ref.invalidate(quartersProvider);
  ref.invalidate(reviewProvider);
  ref.invalidate(taxPrefillProvider);
}

/// "41,8" → "41 años y 10 meses".
String ageText(String? age) {
  if (age == null) return '—';
  final v = double.tryParse(age) ?? 0; // solo para mostrar años y meses, no es dinero
  final years = v.floor();
  final months = ((v - years) * 12).round();
  if (months == 0 || months == 12) return '${months == 12 ? years + 1 : years} años';
  return '$years años y $months ${months == 1 ? 'mes' : 'meses'}';
}
