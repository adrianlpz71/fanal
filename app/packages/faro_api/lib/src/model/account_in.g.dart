// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AccountIn _$AccountInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'AccountIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['kind', 'name']);
    final val = AccountIn(
      id: $checkedConvert('id', (v) => v as String?),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$AccountInKindEnumEnumMap, v),
      ),
      name: $checkedConvert('name', (v) => v as String),
      bank: $checkedConvert('bank', (v) => v as String? ?? ''),
      openingBalance: $checkedConvert(
        'opening_balance',
        (v) => v as String? ?? '0',
      ),
      openingDate: $checkedConvert(
        'opening_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      apy: $checkedConvert('apy', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'openingBalance': 'opening_balance',
    'openingDate': 'opening_date',
  },
);

Map<String, dynamic> _$AccountInToJson(AccountIn instance) => <String, dynamic>{
  'id': ?instance.id,
  'kind': _$AccountInKindEnumEnumMap[instance.kind]!,
  'name': instance.name,
  'bank': ?instance.bank,
  'opening_balance': ?instance.openingBalance,
  'opening_date': ?instance.openingDate?.toIso8601String(),
  'apy': ?instance.apy,
};

const _$AccountInKindEnumEnumMap = {
  AccountInKindEnum.gastos: 'gastos',
  AccountInKindEnum.refugio: 'refugio',
  AccountInKindEnum.ahorro: 'ahorro',
  AccountInKindEnum.inversion: 'inversion',
  AccountInKindEnum.efectivo: 'efectivo',
  AccountInKindEnum.otra: 'otra',
};
