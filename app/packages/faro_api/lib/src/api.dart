//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

import 'package:dio/dio.dart';
import 'package:faro_api/src/auth/api_key_auth.dart';
import 'package:faro_api/src/auth/basic_auth.dart';
import 'package:faro_api/src/auth/bearer_auth.dart';
import 'package:faro_api/src/auth/oauth.dart';
import 'package:faro_api/src/api/analytics_api.dart';
import 'package:faro_api/src/api/auth_api.dart';
import 'package:faro_api/src/api/export_api.dart';
import 'package:faro_api/src/api/gastos_api.dart';
import 'package:faro_api/src/api/imports_api.dart';
import 'package:faro_api/src/api/inversiones_api.dart';
import 'package:faro_api/src/api/me_api.dart';
import 'package:faro_api/src/api/planes_api.dart';
import 'package:faro_api/src/api/system_api.dart';

class FaroApi {
  static const String basePath = r'http://localhost';

  final Dio dio;
  FaroApi({
    Dio? dio,
    String? basePathOverride,
    List<Interceptor>? interceptors,
  })  : 
        this.dio = dio ??
            Dio(BaseOptions(
              baseUrl: basePathOverride ?? basePath,
              connectTimeout: const Duration(milliseconds: 5000),
              receiveTimeout: const Duration(milliseconds: 3000),
            )) {
    if (interceptors == null) {
      this.dio.interceptors.addAll([
        OAuthInterceptor(),
        BasicAuthInterceptor(),
        BearerAuthInterceptor(),
        ApiKeyAuthInterceptor(),
      ]);
    } else {
      this.dio.interceptors.addAll(interceptors);
    }
  }

  void setOAuthToken(String name, String token) {
    if (this.dio.interceptors.any((i) => i is OAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is OAuthInterceptor) as OAuthInterceptor).tokens[name] = token;
    }
  }

  void setBearerAuth(String name, String token) {
    if (this.dio.interceptors.any((i) => i is BearerAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BearerAuthInterceptor) as BearerAuthInterceptor).tokens[name] = token;
    }
  }

  void setBasicAuth(String name, String username, String password) {
    if (this.dio.interceptors.any((i) => i is BasicAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((i) => i is BasicAuthInterceptor) as BasicAuthInterceptor).authInfo[name] = BasicAuthInfo(username, password);
    }
  }

  void setApiKey(String name, String apiKey) {
    if (this.dio.interceptors.any((i) => i is ApiKeyAuthInterceptor)) {
      (this.dio.interceptors.firstWhere((element) => element is ApiKeyAuthInterceptor) as ApiKeyAuthInterceptor).apiKeys[name] = apiKey;
    }
  }

  /// Get AnalyticsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AnalyticsApi getAnalyticsApi() {
    return AnalyticsApi(dio);
  }

  /// Get AuthApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  AuthApi getAuthApi() {
    return AuthApi(dio);
  }

  /// Get ExportApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ExportApi getExportApi() {
    return ExportApi(dio);
  }

  /// Get GastosApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  GastosApi getGastosApi() {
    return GastosApi(dio);
  }

  /// Get ImportsApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  ImportsApi getImportsApi() {
    return ImportsApi(dio);
  }

  /// Get InversionesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  InversionesApi getInversionesApi() {
    return InversionesApi(dio);
  }

  /// Get MeApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  MeApi getMeApi() {
    return MeApi(dio);
  }

  /// Get PlanesApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  PlanesApi getPlanesApi() {
    return PlanesApi(dio);
  }

  /// Get SystemApi instance, base route and serializer can be overridden by a given but be careful,
  /// by doing that all interceptors will not be executed
  SystemApi getSystemApi() {
    return SystemApi(dio);
  }
}
