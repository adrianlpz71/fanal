// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountOut _$AccountOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AccountOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'id',
          'kind',
          'name',
          'bank',
          'balance',
          'balance_with_planned',
          'archived',
        ],
      );
      final val = AccountOut(
        id: $checkedConvert('id', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$AccountOutKindEnumEnumMap, v),
        ),
        name: $checkedConvert('name', (v) => v as String),
        bank: $checkedConvert('bank', (v) => v as String),
        balance: $checkedConvert('balance', (v) => v as String),
        balanceWithPlanned: $checkedConvert(
          'balance_with_planned',
          (v) => v as String,
        ),
        archived: $checkedConvert('archived', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'balanceWithPlanned': 'balance_with_planned'});

Map<String, dynamic> _$AccountOutToJson(AccountOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$AccountOutKindEnumEnumMap[instance.kind]!,
      'name': instance.name,
      'bank': instance.bank,
      'balance': instance.balance,
      'balance_with_planned': instance.balanceWithPlanned,
      'archived': instance.archived,
    };

const _$AccountOutKindEnumEnumMap = {
  AccountOutKindEnum.gastos: 'gastos',
  AccountOutKindEnum.refugio: 'refugio',
  AccountOutKindEnum.ahorro: 'ahorro',
  AccountOutKindEnum.inversion: 'inversion',
  AccountOutKindEnum.efectivo: 'efectivo',
  AccountOutKindEnum.otra: 'otra',
};
