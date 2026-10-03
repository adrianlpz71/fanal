// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_balance_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountBalanceOut _$AccountBalanceOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AccountBalanceOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'name', 'kind', 'balance']);
      final val = AccountBalanceOut(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert('kind', (v) => v as String),
        balance: $checkedConvert('balance', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AccountBalanceOutToJson(AccountBalanceOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'kind': instance.kind,
      'balance': instance.balance,
    };
