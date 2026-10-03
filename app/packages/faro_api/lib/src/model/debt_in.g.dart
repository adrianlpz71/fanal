// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtIn _$DebtInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'DebtIn',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const ['name', 'opening_balance', 'opening_date'],
    );
    final val = DebtIn(
      name: $checkedConvert('name', (v) => v as String),
      personName: $checkedConvert('person_name', (v) => v as String?),
      direction: $checkedConvert(
        'direction',
        (v) => $enumDecodeNullable(_$DebtInDirectionEnumEnumMap, v),
      ),
      openingBalance: $checkedConvert('opening_balance', (v) => v as String),
      openingDate: $checkedConvert(
        'opening_date',
        (v) => DateTime.parse(v as String),
      ),
      interestRate: $checkedConvert('interest_rate', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'personName': 'person_name',
    'openingBalance': 'opening_balance',
    'openingDate': 'opening_date',
    'interestRate': 'interest_rate',
  },
);

Map<String, dynamic> _$DebtInToJson(DebtIn instance) => <String, dynamic>{
  'name': instance.name,
  'person_name': ?instance.personName,
  'direction': ?_$DebtInDirectionEnumEnumMap[instance.direction],
  'opening_balance': instance.openingBalance,
  'opening_date': instance.openingDate.toIso8601String(),
  'interest_rate': ?instance.interestRate,
  'notes': ?instance.notes,
};

const _$DebtInDirectionEnumEnumMap = {
  DebtInDirectionEnum.debo: 'debo',
  DebtInDirectionEnum.meDeben: 'me_deben',
};
