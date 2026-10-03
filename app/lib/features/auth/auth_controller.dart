import 'package:faro_api/faro_api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../../core/api.dart';
import '../../core/notifications.dart';
import '../../core/offline.dart' show clearCycleCache;

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

/// Android: hay sesión guardada pero hay que desbloquear con huella/PIN del dispositivo.
class AuthLocked extends AuthState {
  const AuthLocked({this.message});
  final String? message;
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut({this.message});
  final String? message;
}

class AuthMfa extends AuthState {
  const AuthMfa({required this.mfaToken, required this.setup, this.secret, this.otpauthUri});
  final String mfaToken;
  final bool setup; // true = alta de 2FA (primer login)
  final String? secret;
  final String? otpauthUri;
}

/// Tras activar la 2FA se muestran los códigos de recuperación una única vez.
class AuthRecoveryCodes extends AuthState {
  const AuthRecoveryCodes({required this.codes, required this.user});
  final List<String> codes;
  final UserOut user;
}

class AuthAuthenticated extends AuthState {
  const AuthAuthenticated(this.user);
  final UserOut user;
}

/// Desbloqueo local (huella / credencial del dispositivo). Abstraído para tests.
abstract class DeviceUnlock {
  bool get required;
  Future<bool> unlock();
}

class LocalAuthUnlock implements DeviceUnlock {
  final _auth = LocalAuthentication();

  @override
  bool get required => !kIsWeb;

  @override
  Future<bool> unlock() async {
    try {
      if (!await _auth.isDeviceSupported()) return true; // sin bloqueo configurado: no se puede exigir
      return await _auth.authenticate(
        localizedReason: 'Desbloquea Fanal',
        persistAcrossBackgrounding: true,
      );
    } catch (_) {
      return false;
    }
  }
}

final deviceUnlockProvider = Provider<DeviceUnlock>((ref) => LocalAuthUnlock());

final authProvider = NotifierProvider<AuthController, AuthState>(AuthController.new);

/// Usuario con sesión (null si no hay o está bloqueada).
final sessionUserIdProvider = Provider<String?>((ref) => switch (ref.watch(authProvider)) {
      AuthAuthenticated(:final user) || AuthRecoveryCodes(:final user) => user.id,
      _ => null,
    });

/// Cliente de la API para los providers de datos: los hace depender del usuario con sesión, así
/// que al cerrar sesión o entrar con otro usuario se descartan (nunca se ven datos del anterior).
/// Sin usuario con sesión no se pide nada (un 401 a destiempo dispararía "sesión caducada").
FaroApi userApi(Ref ref) {
  if (ref.watch(sessionUserIdProvider) == null) throw const NotSignedIn();
  return ref.read(apiProvider);
}

/// Error de un provider de datos que se evaluó sin sesión (no es un fallo de red ni de la API).
class NotSignedIn implements Exception {
  const NotSignedIn();
  @override
  String toString() => 'Sin sesión';
}

class AuthController extends Notifier<AuthState> {
  DateTime? _backgroundSince;

  FaroApi get _api => ref.read(apiProvider);

  @override
  AuthState build() {
    final sub = ref.read(sessionExpiredProvider).stream.listen((_) => sessionExpired());
    ref.onDispose(sub.cancel);
    Future.microtask(restore);
    return const AuthUnknown();
  }

  /// Arranque: web intenta refrescar con la cookie; Android pide desbloqueo si hay sesión.
  Future<void> restore() async {
    final unlock = ref.read(deviceUnlockProvider);
    if (unlock.required) {
      final stored = await ref.read(tokenStoreProvider).readRefresh();
      state = stored == null ? const AuthLoggedOut() : const AuthLocked();
      return;
    }
    await _resumeSession();
  }

  Future<void> unlock() async {
    final ok = await ref.read(deviceUnlockProvider).unlock();
    if (!ok) {
      state = const AuthLocked(message: 'No se pudo verificar tu identidad');
      return;
    }
    await _resumeSession();
  }

  Future<void> _resumeSession() async {
    final interceptor = ref.read(dioProvider).interceptors.whereType<AuthInterceptor>().first;
    if (!await interceptor.refresh()) {
      state = const AuthLoggedOut();
      return;
    }
    await _loadMe();
  }

  Future<void> _loadMe() async {
    try {
      final me = (await _api.getMeApi().me()).data!;
      state = AuthAuthenticated(me);
    } catch (e) {
      state = AuthLoggedOut(message: apiErrorMessage(e));
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final r = await _api.getAuthApi().login(
            loginIn: LoginIn(email: email.trim(), password: password),
          );
      final out = r.data!;
      if (out.status == LoginOutStatusEnum.done) {
        // Solo en desarrollo (FARO_MFA_DISABLED): el servidor ya devuelve la sesión.
        await _storeTokens(out.accessToken!, out.refreshToken);
        await _loadMe();
        return null;
      }
      final setup = out.status == LoginOutStatusEnum.setup;
      state = AuthMfa(mfaToken: out.mfaToken!, setup: setup);
      if (setup) await _startSetup(out.mfaToken!);
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  Future<void> _startSetup(String mfaToken) async {
    final r = await _api.getAuthApi().mfaSetup(mfaTokenIn: MfaTokenIn(mfaToken: mfaToken));
    state = AuthMfa(
      mfaToken: mfaToken,
      setup: true,
      secret: r.data!.secret,
      otpauthUri: r.data!.otpauthUri,
    );
  }

  Future<String?> submitCode(String code) async {
    final s = state;
    if (s is! AuthMfa) return 'Sesión de verificación no válida';
    try {
      final body = MfaCodeIn(mfaToken: s.mfaToken, code: code.trim());
      if (s.setup) {
        final r = (await _api.getAuthApi().mfaEnable(mfaCodeIn: body)).data!;
        await _storeTokens(r.accessToken, r.refreshToken);
        final me = (await _api.getMeApi().me()).data!;
        state = AuthRecoveryCodes(codes: r.recoveryCodes, user: me);
      } else {
        final r = (await _api.getAuthApi().mfaVerify(mfaCodeIn: body)).data!;
        await _storeTokens(r.accessToken, r.refreshToken);
        await _loadMe();
      }
      return null;
    } catch (e) {
      return apiErrorMessage(e);
    }
  }

  void acknowledgeRecoveryCodes() {
    final s = state;
    if (s is AuthRecoveryCodes) state = AuthAuthenticated(s.user);
  }

  void cancelMfa() => state = const AuthLoggedOut();

  /// El refresh falló tras un 401. Solo echa si había sesión: durante el login o el código 2FA
  /// (o al arrancar) un 401 suelto no puede devolver a nadie a la pantalla de entrada.
  void sessionExpired() {
    if (state is AuthAuthenticated || state is AuthRecoveryCodes) {
      state = const AuthLoggedOut(message: 'La sesión ha caducado. Vuelve a entrar.');
    }
  }

  Future<void> _storeTokens(String access, String? refresh) async {
    ref.read(sessionProvider).accessToken = access;
    if (refresh != null) await ref.read(tokenStoreProvider).writeRefresh(refresh);
  }

  void updateUser(UserOut user) => state = AuthAuthenticated(user);

  Future<void> logout() async {
    final store = ref.read(tokenStoreProvider);
    // Lo que queda en el dispositivo de este usuario: el ciclo en caché y sus avisos programados
    final user = ref.read(sessionUserIdProvider);
    if (user != null) await clearCycleCache(user);
    await Notifications.instance.cancelAll();
    try {
      await _api.getAuthApi().logout(refreshIn: RefreshIn(refreshToken: await store.readRefresh()));
    } catch (_) {
      // aunque falle la red, se cierra localmente
    }
    ref.read(sessionProvider).accessToken = null;
    await store.writeRefresh(null);
    state = const AuthLoggedOut();
  }

  /// Android: al volver de segundo plano tras más de 5 min, se vuelve a pedir la huella.
  void onPaused() => _backgroundSince = DateTime.now();

  void onResumed() {
    final since = _backgroundSince;
    _backgroundSince = null;
    if (!ref.read(deviceUnlockProvider).required || since == null) return;
    if (state is AuthAuthenticated && DateTime.now().difference(since).inMinutes >= 5) {
      ref.read(sessionProvider).accessToken = null;
      state = const AuthLocked();
    }
  }
}
