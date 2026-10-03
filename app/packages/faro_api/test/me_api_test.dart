import 'package:test/test.dart';
import 'package:faro_api/faro_api.dart';


/// tests for MeApi
void main() {
  final instance = FaroApi().getMeApi();

  group(MeApi, () {
    // Me
    //
    //Future<UserOut> me() async
    test('test me', () async {
      // TODO
    });

    // Update Profile
    //
    // Perfil básico del onboarding. Cada módulo añadirá sus preguntas en su fase.
    //
    //Future<UserOut> updateProfile(ProfileIn profileIn) async
    test('test updateProfile', () async {
      // TODO
    });

  });
}
