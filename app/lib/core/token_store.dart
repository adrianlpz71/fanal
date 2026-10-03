import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Dónde vive el refresh token.
/// - Android: Keystore vía flutter_secure_storage (y la app exige huella para usarlo).
/// - Web: en ningún sitio accesible a JS; va en una cookie HttpOnly que gestiona el navegador.
abstract class TokenStore {
  Future<String?> readRefresh();
  Future<void> writeRefresh(String? token);

  static TokenStore create() => kIsWeb ? _CookieTokenStore() : SecureTokenStore();
}

class SecureTokenStore implements TokenStore {
  static const _key = 'faro_refresh_token';
  final _storage = const FlutterSecureStorage();

  @override
  Future<String?> readRefresh() => _storage.read(key: _key);

  @override
  Future<void> writeRefresh(String? token) =>
      token == null ? _storage.delete(key: _key) : _storage.write(key: _key, value: token);
}

class _CookieTokenStore implements TokenStore {
  @override
  Future<String?> readRefresh() async => null; // el navegador envía la cookie solo

  @override
  Future<void> writeRefresh(String? token) async {}
}

/// Para tests.
class MemoryTokenStore implements TokenStore {
  String? value;
  @override
  Future<String?> readRefresh() async => value;
  @override
  Future<void> writeRefresh(String? token) async => value = token;
}
