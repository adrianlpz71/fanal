import 'package:test/test.dart';
import 'package:faro_api/faro_api.dart';


/// tests for PlanesApi
void main() {
  final instance = FaroApi().getPlanesApi();

  group(PlanesApi, () {
    // Compound
    //
    //Future<CompoundOut> compound(CompoundIn compoundIn) async
    test('test compound', () async {
      // TODO
    });

    // Create Goal
    //
    //Future<GoalOut> createGoal(GoalIn goalIn) async
    test('test createGoal', () async {
      // TODO
    });

    // Delete Goal
    //
    //Future deleteGoal(String goalId) async
    test('test deleteGoal', () async {
      // TODO
    });

    // Get Fire
    //
    //Future<FirePlanOut> getFire() async
    test('test getFire', () async {
      // TODO
    });

    // Get Fire Settings
    //
    //Future<FireSettingsOut> getFireSettings() async
    test('test getFireSettings', () async {
      // TODO
    });

    // Get Review
    //
    //Future<QuarterReviewOut> getReview(String quarter) async
    test('test getReview', () async {
      // TODO
    });

    // List Goals
    //
    //Future<List<GoalOut>> listGoals() async
    test('test listGoals', () async {
      // TODO
    });

    // List Quarters
    //
    // Trimestres con datos, del más reciente al más antiguo.
    //
    //Future<List<QuarterItemOut>> listQuarters() async
    test('test listQuarters', () async {
      // TODO
    });

    // Montecarlo
    //
    // Probabilidad de éxito con rentabilidades aleatorias (2.000 simulaciones).
    //
    //Future<MonteCarloOut> montecarlo(FireSettingsIn fireSettingsIn) async
    test('test montecarlo', () async {
      // TODO
    });

    // Put Fire Settings
    //
    //Future<FireSettingsOut> putFireSettings(FireSettingsIn fireSettingsIn) async
    test('test putFireSettings', () async {
      // TODO
    });

    // Save Review
    //
    // Guarda las respuestas y una foto de las métricas de este momento.
    //
    //Future<QuarterReviewOut> saveReview(String quarter, QuarterReviewIn quarterReviewIn) async
    test('test saveReview', () async {
      // TODO
    });

    // Sell Preview
    //
    // ¿Y si vendo X € hoy? Ganancia FIFO de esa venta (de un activo o de toda la cartera en proporción a su peso, D8) y lo que añade a tu IRPF del año.
    //
    //Future<SellPreviewOut> sellPreview(SellPreviewIn sellPreviewIn) async
    test('test sellPreview', () async {
      // TODO
    });

    // Simulate Fire
    //
    // ¿Y si…? Calcula con otros valores sin guardarlos.
    //
    //Future<FirePlanOut> simulateFire(FireSettingsIn fireSettingsIn) async
    test('test simulateFire', () async {
      // TODO
    });

    // Simulate Tax
    //
    //Future<TaxOut> simulateTax(TaxIn taxIn) async
    test('test simulateTax', () async {
      // TODO
    });

    // Tax Prefill
    //
    // Datos para prellenar el simulador: nóminas del año (referencia), la base general que guardaste, y ganancias FIFO e ingresos del año (como en el Informe fiscal).
    //
    //Future<TaxPrefillOut> taxPrefill({ int year }) async
    test('test taxPrefill', () async {
      // TODO
    });

    // Update Goal
    //
    //Future<GoalOut> updateGoal(String goalId, GoalIn goalIn) async
    test('test updateGoal', () async {
      // TODO
    });

  });
}
