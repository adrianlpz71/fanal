// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginOut _$LoginOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'LoginOut',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['status']);
    final val = LoginOut(
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$LoginOutStatusEnumEnumMap, v),
      ),
      mfaToken: $checkedConvert('mfa_token', (v) => v as String?),
      accessToken: $checkedConvert('access_token', (v) => v as String?),
      expiresIn: $checkedConvert('expires_in', (v) => (v as num?)?.toInt()),
      refreshToken: $checkedConvert('refresh_token', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'mfaToken': 'mfa_token',
    'accessToken': 'access_token',
    'expiresIn': 'expires_in',
    'refreshToken': 'refresh_token',
  },
);

Map<String, dynamic> _$LoginOutToJson(LoginOut instance) => <String, dynamic>{
  'status': _$LoginOutStatusEnumEnumMap[instance.status]!,
  'mfa_token': ?instance.mfaToken,
  'access_token': ?instance.accessToken,
  'expires_in': ?instance.expiresIn,
  'refresh_token': ?instance.refreshToken,
};

const _$LoginOutStatusEnumEnumMap = {
  LoginOutStatusEnum.verify: 'verify',
  LoginOutStatusEnum.setup: 'setup',
  LoginOutStatusEnum.done: 'done',
};
