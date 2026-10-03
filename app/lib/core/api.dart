import 'dart:async';

import 'package:dio/dio.dart';
import 'package:faro_api/faro_api.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'env.dart';
import 'token_store.dart';

/// Sesión en memoria: el access token NUNCA se persiste.
class Session {
  String? accessToken;
}

final tokenStoreProvider = Provider<TokenStore>((ref) => TokenStore.create());
final sessionProvider = Provider<Session>((ref) => Session());

/// Se dispara cuando el refresh falla (sesión caducada/revocada) → el router manda a login.
final sessionExpiredProvider = Provider<StreamController<void>>((ref) {
  final c = StreamController<void>.broadcast();
  ref.onDispose(c.close);
  return c;
});

final dioProvider = Provider<Dio>((ref) {
  BaseOptions opts() => BaseOptions(
        baseUrl: Env.apiOrigin,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'X-Faro-Client': Env.clientKind},
        extra: {'withCredentials': true},
      );
  final dio = Dio(opts());
  dio.interceptors.add(AuthInterceptor(
    dio: dio,
    refreshDio: Dio(opts()), // sin interceptores: evita bloqueos de la cola
    session: ref.read(sessionProvider),
    store: ref.read(tokenStoreProvider),
    onExpired: () => ref.read(sessionExpiredProvider).add(null),
  ));
  return dio;
});

// interceptors: [] → sin los interceptores de auth del generador (usamos AuthInterceptor).
final apiProvider =
    Provider<FaroApi>((ref) => FaroApi(dio: ref.watch(dioProvider), interceptors: const []));

/// Añade el Bearer y, ante un 401, intenta UN refresh (compartido entre peticiones
/// concurrentes) y reintenta. En web activa `withCredentials` para la cookie de refresh.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required this.dio,
    required this.refreshDio,
    required this.session,
    required this.store,
    required this.onExpired,
  });

  final Dio dio;
  final Dio refreshDio;
  final Session session;
  final TokenStore store;
  final void Function() onExpired;

  static bool _isAuthPath(String path) => path.startsWith('/api/auth/');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra['withCredentials'] = true;
    final token = session.accessToken;
    if (token != null && !_isAuthPath(options.path)) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    final retried = req.extra['retried'] == true;
    if (err.response?.statusCode != 401 || _isAuthPath(req.path) || retried) {
      return handler.next(err);
    }
    final ok = await refresh();
    if (!ok) {
      onExpired();
      return handler.next(err);
    }
    req.headers['Authorization'] = 'Bearer ${session.accessToken}';
    req.extra['retried'] = true;
    try {
      handler.resolve(await dio.fetch(req));
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  /// Rota el refresh token. Devuelve false si la sesión ya no es válida.
  Future<bool> refresh() async {
    final stored = await store.readRefresh();
    try {
      final r = await refreshDio.post<Map<String, dynamic>>(
        '/api/auth/refresh',
        data: {'refresh_token': stored},
      );
      final data = r.data!;
      session.accessToken = data['access_token'] as String;
      final newRefresh = data['refresh_token'] as String?;
      if (newRefresh != null) await store.writeRefresh(newRefresh);
      return true;
    } on DioException {
      session.accessToken = null;
      await store.writeRefresh(null);
      return false;
    }
  }
}

/// Mensaje legible para el usuario a partir de un error de la API.
String apiErrorMessage(Object e) {
  if (e is DioException) {
    final data = e.response?.data;
    if (data is Map && data['detail'] is String) return data['detail'] as String;
    if (e.response?.statusCode == 422) return 'Revisa los datos introducidos';
    return switch (e.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        'No hay conexión con el servidor',
      _ => 'Error inesperado (${e.response?.statusCode ?? '—'})',
    };
  }
  return 'Error inesperado';
}
