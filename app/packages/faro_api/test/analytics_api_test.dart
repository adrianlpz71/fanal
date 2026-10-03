import 'package:test/test.dart';
import 'package:faro_api/faro_api.dart';


/// tests for AnalyticsApi
void main() {
  final instance = FaroApi().getAnalyticsApi();

  group(AnalyticsApi, () {
    // Backfill
    //
    // Histórico de precios desde la primera operación (para los gráficos y la rentabilidad).
    //
    //Future<JobResultOut> backfill() async
    test('test backfill', () async {
      // TODO
    });

    // Get Asset Exposure
    //
    //Future<List<AssetExposureOut>> getAssetExposure(String assetId) async
    test('test getAssetExposure', () async {
      // TODO
    });

    // Get Contributions
    //
    // Historial de aportaciones a inversiones y ahorro, con ritmo mensual y racha.
    //
    //Future<ContributionsOut> getContributions() async
    test('test getContributions', () async {
      // TODO
    });

    // Get Exposure
    //
    //Future<ExposureOut> getExposure() async
    test('test getExposure', () async {
      // TODO
    });

    // Get Milestones
    //
    // Hitos del patrimonio neto: cuándo se cruzó cada umbral y una estimación del siguiente con la aportación media (sin rentabilidad: no es una previsión).
    //
    //Future<MilestonesOut> getMilestones() async
    test('test getMilestones', () async {
      // TODO
    });

    // Get Networth
    //
    //Future<NetWorthOut> getNetworth() async
    test('test getNetworth', () async {
      // TODO
    });

    // Get Networth Evolution
    //
    // Evolución del patrimonio por componente (cada cuenta y cada activo), con deudas, fraccionadas y el neto. Las cuentas se reconstruyen desde el saldo de hoy (D9).
    //
    //Future<NetWorthEvolutionOut> getNetworthEvolution() async
    test('test getNetworthEvolution', () async {
      // TODO
    });

    // Get Networth History
    //
    //Future<List<NetWorthPointOut>> getNetworthHistory() async
    test('test getNetworthHistory', () async {
      // TODO
    });

    // Get Performance
    //
    // Rentabilidad de toda la cartera, de una categoría o de un activo.
    //
    //Future<PerformanceOut> getPerformance({ String assetId, String classId }) async
    test('test getPerformance', () async {
      // TODO
    });

    // Put Asset Exposure
    //
    // Composición manual de un activo (sustituye a la manual anterior; la automática se queda pero deja de usarse en las dimensiones que tengan manual).
    //
    //Future<List<AssetExposureOut>> putAssetExposure(String assetId, List<AssetExposureIn> assetExposureIn) async
    test('test putAssetExposure', () async {
      // TODO
    });

    // Put Milestones
    //
    //Future<MilestonesOut> putMilestones(MilestonesIn milestonesIn) async
    test('test putMilestones', () async {
      // TODO
    });

    // Refresh Exposure
    //
    //Future<JobResultOut> refreshExposure() async
    test('test refreshExposure', () async {
      // TODO
    });

    // Tax Report
    //
    // Resumen anual para la Renta: ventas (FIFO), traspasos, rendimientos y saldos a 31/12.
    //
    //Future<TaxReportOut> taxReport({ int year }) async
    test('test taxReport', () async {
      // TODO
    });

  });
}
