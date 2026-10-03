// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginIn _$LoginInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('LoginIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['email', 'password']);
      final val = LoginIn(
        email: $checkedConvert('email', (v) => v as String),
        password: $checkedConvert('password', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$LoginInToJson(LoginIn instance) => <String, dynamic>{
  'email': instance.email,
  'password': instance.password,
};
