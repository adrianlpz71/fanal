import 'package:test/test.dart';
import 'package:faro_api/faro_api.dart';


/// tests for ExportApi
void main() {
  final instance = FaroApi().getExportApi();

  group(ExportApi, () {
    // Export All
    //
    // Todos tus datos (sin nada de seguridad). JSON para copias o Excel para mirarlos.
    //
    //Future exportAll({ String format }) async
    test('test exportAll', () async {
      // TODO
    });

  });
}
