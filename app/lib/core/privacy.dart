import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'money.dart' as money;

/// Modo privacidad: oculta los importes en toda la app (p. ej. al enseñarla). Se recuerda en
/// el dispositivo.
class PrivacyController extends Notifier<bool> {
  static const _key = 'faro.privacy';
  final _storage = const FlutterSecureStorage();

  @override
  bool build() {
    _load();
    return money.privacyMode;
  }

  Future<void> _load() async {
    try {
      final v = await _storage.read(key: _key) == '1';
      if (v != state) {
        money.privacyMode = v;
        state = v;
      }
    } catch (_) {
      // sin almacenamiento seguro (tests): queda desactivado
    }
  }

  Future<void> set(bool on) async {
    money.privacyMode = on;
    state = on;
    try {
      await _storage.write(key: _key, value: on ? '1' : '0');
    } catch (_) {}
  }
}

final privacyProvider = NotifierProvider<PrivacyController, bool>(PrivacyController.new);
