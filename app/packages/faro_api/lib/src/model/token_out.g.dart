// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TokenOut _$TokenOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TokenOut',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['access_token', 'expires_in']);
    final val = TokenOut(
      accessToken: $checkedConvert('access_token', (v) => v as String),
      expiresIn: $checkedConvert('expires_in', (v) => (v as num).toInt()),
      refreshToken: $checkedConvert('refresh_token', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'accessToken': 'access_token',
    'expiresIn': 'expires_in',
    'refreshToken': 'refresh_token',
  },
);

Map<String, dynamic> _$TokenOutToJson(TokenOut instance) => <String, dynamic>{
  'access_token': instance.accessToken,
  'expires_in': instance.expiresIn,
  'refresh_token': ?instance.refreshToken,
};
