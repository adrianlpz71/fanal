// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_code_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaCodeIn _$MfaCodeInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MfaCodeIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['mfa_token', 'code']);
      final val = MfaCodeIn(
        mfaToken: $checkedConvert('mfa_token', (v) => v as String),
        code: $checkedConvert('code', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'mfaToken': 'mfa_token'});

Map<String, dynamic> _$MfaCodeInToJson(MfaCodeIn instance) => <String, dynamic>{
  'mfa_token': instance.mfaToken,
  'code': instance.code,
};
