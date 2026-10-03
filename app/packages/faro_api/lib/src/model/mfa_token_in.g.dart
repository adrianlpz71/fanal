// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mfa_token_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MfaTokenIn _$MfaTokenInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MfaTokenIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['mfa_token']);
      final val = MfaTokenIn(
        mfaToken: $checkedConvert('mfa_token', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'mfaToken': 'mfa_token'});

Map<String, dynamic> _$MfaTokenInToJson(MfaTokenIn instance) =>
    <String, dynamic>{'mfa_token': instance.mfaToken};
