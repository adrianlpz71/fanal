// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_enabled_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaEnabledOut _$MfaEnabledOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MfaEnabledOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['access_token', 'expires_in', 'recovery_codes'],
        );
        final val = MfaEnabledOut(
          accessToken: $checkedConvert('access_token', (v) => v as String),
          expiresIn: $checkedConvert('expires_in', (v) => (v as num).toInt()),
          refreshToken: $checkedConvert('refresh_token', (v) => v as String?),
          recoveryCodes: $checkedConvert(
            'recovery_codes',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'accessToken': 'access_token',
        'expiresIn': 'expires_in',
        'refreshToken': 'refresh_token',
        'recoveryCodes': 'recovery_codes',
      },
    );

Map<String, dynamic> _$MfaEnabledOutToJson(MfaEnabledOut instance) =>
    <String, dynamic>{
      'access_token': instance.accessToken,
      'expires_in': instance.expiresIn,
      'refresh_token': ?instance.refreshToken,
      'recovery_codes': instance.recoveryCodes,
    };
