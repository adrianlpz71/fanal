import 'package:test/test.dart';
import 'package:faro_api/faro_api.dart';


/// tests for InversionesApi
void main() {
  final instance = FaroApi().getInversionesApi();

  group(InversionesApi, () {
    // Asset Detail
    //
    //Future<AssetDetailOut> assetDetail(String assetId) async
    test('test assetDetail', () async {
      // TODO
    });

    // Correct
    //
    //Future<PositionOut> correct(String assetId, CorrectionIn correctionIn) async
    test('test correct', () async {
      // TODO
    });

    // Create Asset
    //
    //Future<AssetOut> createAsset(AssetIn assetIn) async
    test('test createAsset', () async {
      // TODO
    });

    // Create Class
    //
    //Future<AssetClassOut> createClass(AssetClassIn assetClassIn) async
    test('test createClass', () async {
      // TODO
    });

    // Create Orders
    //
    //Future<List<TxOut>> createOrders(OrdersIn ordersIn) async
    test('test createOrders', () async {
      // TODO
    });

    // Create Plan
    //
    //Future<PlanOut> createPlan(PlanIn planIn) async
    test('test createPlan', () async {
      // TODO
    });

    // Create Platform
    //
    //Future<PlatformOut> createPlatform(PlatformIn platformIn) async
    test('test createPlatform', () async {
      // TODO
    });

    // Create Transaction
    //
    //Future<TxOut> createTransaction(TxIn txIn) async
    test('test createTransaction', () async {
      // TODO
    });

    // Create Transfer
    //
    //Future<List<TxOut>> createTransfer(TransferIn transferIn) async
    test('test createTransfer', () async {
      // TODO
    });

    // Delete Asset
    //
    // Solo se borra un activo sin operaciones; si las tiene, se archiva.
    //
    //Future deleteAsset(String assetId) async
    test('test deleteAsset', () async {
      // TODO
    });

    // Delete Plan
    //
    //Future deletePlan(String planId) async
    test('test deletePlan', () async {
      // TODO
    });

    // Delete Transaction
    //
    //Future deleteTransaction(String txId) async
    test('test deleteTransaction', () async {
      // TODO
    });

    // Get History
    //
    //Future<List<SnapshotOut>> getHistory({ int days }) async
    test('test getHistory', () async {
      // TODO
    });

    // Get Portfolio
    //
    //Future<PortfolioOut> getPortfolio() async
    test('test getPortfolio', () async {
      // TODO
    });

    // Get Settings
    //
    //Future<InvSettingsOut> getSettings() async
    test('test getSettings', () async {
      // TODO
    });

    // Get Targets
    //
    //Future<TargetsOut> getTargets() async
    test('test getTargets', () async {
      // TODO
    });

    // List Assets
    //
    //Future<List<AssetOut>> listAssets({ bool includeArchived }) async
    test('test listAssets', () async {
      // TODO
    });

    // List Classes
    //
    //Future<List<AssetClassOut>> listClasses() async
    test('test listClasses', () async {
      // TODO
    });

    // List Plans
    //
    //Future<List<PlanOut>> listPlans() async
    test('test listPlans', () async {
      // TODO
    });

    // List Platforms
    //
    //Future<List<PlatformOut>> listPlatforms() async
    test('test listPlatforms', () async {
      // TODO
    });

    // List Prices
    //
    //Future<List<PriceOut>> listPrices(String assetId, { int limit }) async
    test('test listPrices', () async {
      // TODO
    });

    // List Transactions
    //
    //Future<List<TxOut>> listTransactions({ bool pendingOnly, int limit }) async
    test('test listTransactions', () async {
      // TODO
    });

    // Patch Asset
    //
    //Future<AssetOut> patchAsset(String assetId, AssetPatch assetPatch) async
    test('test patchAsset', () async {
      // TODO
    });

    // Platform Commit
    //
    //Future<PlatformBatchOut> platformCommit(String file, { bool replaceInitial, String mapping, String profileId, String saveProfileAs }) async
    test('test platformCommit', () async {
      // TODO
    });

    // Platform Preview
    //
    //Future<PlatformPreviewOut> platformPreview(String file, { bool replaceInitial, String mapping, String profileId }) async
    test('test platformPreview', () async {
      // TODO
    });

    // Put History
    //
    // Punto manual del historial (anterior a Faro). No pisa un snapshot automático.
    //
    //Future<SnapshotOut> putHistory(SnapshotIn snapshotIn) async
    test('test putHistory', () async {
      // TODO
    });

    // Put Price
    //
    //Future<PriceOut> putPrice(String assetId, PriceIn priceIn) async
    test('test putPrice', () async {
      // TODO
    });

    // Put Settings
    //
    //Future<InvSettingsOut> putSettings(InvSettingsIn invSettingsIn) async
    test('test putSettings', () async {
      // TODO
    });

    // Put Targets
    //
    //Future<TargetsOut> putTargets(TargetsIn targetsIn) async
    test('test putTargets', () async {
      // TODO
    });

    // Refresh Prices
    //
    // Consulta ahora las fuentes de precios de mis activos (lo mismo que hace el worker).
    //
    //Future<List<PriceRefreshOut>> refreshPrices() async
    test('test refreshPrices', () async {
      // TODO
    });

    // Settle Transaction
    //
    //Future<TxOut> settleTransaction(String txId, TxSettleIn txSettleIn) async
    test('test settleTransaction', () async {
      // TODO
    });

    // Suggest
    //
    //Future<ContributionOut> suggest(SuggestIn suggestIn) async
    test('test suggest', () async {
      // TODO
    });

    // Update Plan
    //
    //Future<PlanOut> updatePlan(String planId, PlanIn planIn) async
    test('test updatePlan', () async {
      // TODO
    });

    // Update Platform
    //
    //Future<PlatformOut> updatePlatform(String platformId, PlatformIn platformIn) async
    test('test updatePlatform', () async {
      // TODO
    });

  });
}
