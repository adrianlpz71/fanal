import 'package:test/test.dart';
import 'package:faro_api/faro_api.dart';


/// tests for AuthApi
void main() {
  final instance = FaroApi().getAuthApi();

  group(AuthApi, () {
    // Login
    //
    //Future<LoginOut> login(LoginIn loginIn) async
    test('test login', () async {
      // TODO
    });

    // Logout
    //
    //Future logout(RefreshIn refreshIn) async
    test('test logout', () async {
      // TODO
    });

    // Mfa Enable
    //
    //Future<MfaEnabledOut> mfaEnable(MfaCodeIn mfaCodeIn) async
    test('test mfaEnable', () async {
      // TODO
    });

    // Mfa Setup
    //
    //Future<MfaSetupOut> mfaSetup(MfaTokenIn mfaTokenIn) async
    test('test mfaSetup', () async {
      // TODO
    });

    // Mfa Verify
    //
    //Future<TokenOut> mfaVerify(MfaCodeIn mfaCodeIn) async
    test('test mfaVerify', () async {
      // TODO
    });

    // Refresh
    //
    //Future<TokenOut> refresh(RefreshIn refreshIn) async
    test('test refresh', () async {
      // TODO
    });

  });
}
