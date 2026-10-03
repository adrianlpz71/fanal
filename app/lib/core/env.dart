import 'package:flutter/foundation.dart';

/// Origen de la API (sin `/api`: las rutas del cliente generado ya lo incluyen).
///
/// - Web en producción: mismo origen que la página (Caddy enruta `/api`).
/// - Android: `https://fanal.example.com`.
/// - Desarrollo: `--dart-define=API_ORIGIN=http://localhost:8100`
///   (emulador Android: `http://10.0.2.2:8100`).
class Env {
  static const _override = String.fromEnvironment('API_ORIGIN');

  static String get apiOrigin {
    if (_override.isNotEmpty) return _override;
    if (kIsWeb) return Uri.base.origin;
    return 'https://fanal.example.com';
  }

  /// La web usa cookie HttpOnly para el refresh; Android lo guarda en secure storage.
  static String get clientKind => kIsWeb ? 'web' : 'android';
}
