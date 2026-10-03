import 'package:faro/core/token_store.dart';
import 'package:faro/core/api.dart';
import 'package:dio/dio.dart';
import 'package:faro/features/auth/auth_controller.dart';
import 'package:faro/main.dart' show retryPolicy;
import 'package:faro_api/faro_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Controlador falso que permite cambiar de usuario sin red.
class SwitchableAuth extends AuthController {
  @override
  AuthState build() => const AuthLoggedOut();
  void become(AuthState s) => state = s;
}

UserOut user(String id) => UserOut(
      id: id, email: '$id@example.com', displayName: id, birthDate: null, locale: 'es-ES',
      currency: 'EUR', timezone: 'Atlantic/Canary', taxRegion: 'ES-CN', onboardingCompleted: true,
    );

void main() {
  test('los datos de un usuario se descartan al cerrar sesión o entrar con otro', () async {
    var loads = 0;
    // Un provider de datos cualquiera: depende del usuario a través de userApi
    final probe = FutureProvider<int>((ref) async {
      userApi(ref);
      return ++loads;
    });
    final c = ProviderContainer(overrides: [
      authProvider.overrideWith(SwitchableAuth.new),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
    ]);
    addTearDown(c.dispose);
    final auth = c.read(authProvider.notifier) as SwitchableAuth;
    auth.become(AuthAuthenticated(user('ana')));
    final sub = c.listen(probe, (_, _) {});
    addTearDown(sub.close);

    final first = await c.read(probe.future);
    expect(await c.read(probe.future), first); // mismo usuario: se reutiliza

    auth.become(AuthAuthenticated(user('ana'))); // refrescar el perfil no recarga los datos
    expect(await c.read(probe.future), first);

    auth.become(const AuthLoggedOut());
    auth.become(AuthAuthenticated(user('luis')));
    expect(await c.read(probe.future), greaterThan(first)); // otro usuario: datos nuevos
    expect(c.read(sessionUserIdProvider), 'luis');
  });

  test('sin sesión los providers de datos no llaman a la API', () async {
    final probe = FutureProvider<int>((ref) async {
      userApi(ref);
      return 1;
    });
    final c = ProviderContainer(overrides: [
      authProvider.overrideWith(SwitchableAuth.new),
      tokenStoreProvider.overrideWithValue(MemoryTokenStore()),
    ], retry: retryPolicy);
    addTearDown(c.dispose);
    final sub = c.listen(probe, (_, _) {});
    addTearDown(sub.close);
    await expectLater(c.read(probe.future), throwsA(isA<NotSignedIn>()));
  });

  test('un 401 suelto durante el código 2FA no devuelve al login', () {
    final c = ProviderContainer(overrides: [authProvider.overrideWith(SwitchableAuth.new)]);
    addTearDown(c.dispose);
    final auth = c.read(authProvider.notifier) as SwitchableAuth;
    auth.become(const AuthMfa(mfaToken: 't', setup: false));
    auth.sessionExpired();
    expect(c.read(authProvider), isA<AuthMfa>());
    auth.become(AuthAuthenticated(user('ana')));
    auth.sessionExpired();
    expect(c.read(authProvider), isA<AuthLoggedOut>());
  });

  test('no se reintenta lo que no se arregla solo', () {
    DioException http(int code) => DioException(
        requestOptions: RequestOptions(), response: Response(requestOptions: RequestOptions(), statusCode: code));
    expect(retryPolicy(0, const NotSignedIn()), isNull);
    expect(retryPolicy(0, http(401)), isNull);
    expect(retryPolicy(0, http(404)), isNull);
    expect(retryPolicy(0, http(503)), isNotNull);
    expect(retryPolicy(0, DioException(requestOptions: RequestOptions())), isNotNull); // sin red
    expect(retryPolicy(5, http(503)), isNull);
  });
}
