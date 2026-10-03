import 'package:test/test.dart';
import 'package:faro_api/faro_api.dart';


/// tests for ImportsApi
void main() {
  final instance = FaroApi().getImportsApi();

  group(ImportsApi, () {
    // Bank Commit
    //
    //Future<BatchOut> bankCommit(String file, { String accountId, String mapping, String profileId, String saveProfileAs }) async
    test('test bankCommit', () async {
      // TODO
    });

    // Bank Preview
    //
    //Future<BankPreviewOut> bankPreview(String file, { String accountId, String mapping, String profileId }) async
    test('test bankPreview', () async {
      // TODO
    });

    // Create Profile
    //
    //Future<BankProfileOut> createProfile(BankProfileIn bankProfileIn) async
    test('test createProfile', () async {
      // TODO
    });

    // Delete Profile
    //
    //Future deleteProfile(String profileId) async
    test('test deleteProfile', () async {
      // TODO
    });

    // Inspect Table
    //
    // Para el editor de columnas: las primeras filas y, si se reconoce, el mapeo sugerido.
    //
    //Future<TableInspectOut> inspectTable(String file, { String kind }) async
    test('test inspectTable', () async {
      // TODO
    });

    // List Batches
    //
    //Future<List<BatchOut>> listBatches() async
    test('test listBatches', () async {
      // TODO
    });

    // List Profiles
    //
    // Formatos guardados: `bank` (extractos) o `broker` (operaciones de inversión).
    //
    //Future<List<BankProfileOut>> listProfiles({ String kind }) async
    test('test listProfiles', () async {
      // TODO
    });

    // Undo Batch
    //
    //Future<BatchOut> undoBatch(String batchId) async
    test('test undoBatch', () async {
      // TODO
    });

  });
}
