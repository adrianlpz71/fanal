// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_setup_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaSetupOut _$MfaSetupOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MfaSetupOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['secret', 'otpauth_uri']);
      final val = MfaSetupOut(
        secret: $checkedConvert('secret', (v) => v as String),
        otpauthUri: $checkedConvert('otpauth_uri', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'otpauthUri': 'otpauth_uri'});

Map<String, dynamic> _$MfaSetupOutToJson(MfaSetupOut instance) =>
    <String, dynamic>{
      'secret': instance.secret,
      'otpauth_uri': instance.otpauthUri,
    };
