import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Diseño coherente (docs/06-rediseno-ui.md §5.6): los campos, las hojas, los menús y los estilos
/// salen de `lib/core/`. Fuera de `core/` no puede aparecer ninguno de estos patrones (desde la
/// fase 7 del rediseño, todas las pantallas están migradas).
const _patterns = [
  r'(^|[^A-Za-z])TextField\(',
  r'TextFormField\(',
  r'DropdownButtonFormField[<(]',
  r'DropdownButton[<(]',
  r'showModalBottomSheet[<(]',
  r'PopupMenuButton[<(]',
  r'Color\(0x',
  r'TextStyle\(fontSize',
  r'ActionChip\(',
];

/// Excepciones permanentes (fichero → patrón).
const _allowed = {
  'shell/home_shell.dart': r'PopupMenuButton[<(]', // menú de usuario (no es navegación a secciones)
};

void main() {
  test('nada de campos, hojas, menús ni estilos sueltos fuera de core/', () {
    final files = Directory('lib/features').listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
    final found = <String>[];
    for (final f in files) {
      final rel = f.path.replaceAll('\\', '/').split('lib/features/').last;
      final src = f.readAsStringSync();
      for (final p in _patterns) {
        if (_allowed[rel] == p) continue;
        if (RegExp(p, multiLine: true).hasMatch(src)) found.add('$rel: $p');
      }
    }
    expect(found, isEmpty, reason: 'Usa los componentes de lib/core/forms, lib/core/components o lib/core/charts.');
  });
}
