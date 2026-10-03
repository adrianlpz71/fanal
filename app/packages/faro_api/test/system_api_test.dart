import 'package:test/test.dart';
import 'package:faro_api/faro_api.dart';


/// tests for SystemApi
void main() {
  final instance = FaroApi().getSystemApi();

  group(SystemApi, () {
    // Health
    //
    //Future<HealthOut> health() async
    test('test health', () async {
      // TODO
    });

    // Version
    //
    // Última versión publicada de la app (la escribe el deploy en latest.json).
    //
    //Future<VersionOut> version() async
    test('test version', () async {
      // TODO
    });

  });
}
