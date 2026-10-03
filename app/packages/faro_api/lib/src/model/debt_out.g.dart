// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtOut _$DebtOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'DebtOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'name',
        'person_name',
        'direction',
        'opening_balance',
        'opening_date',
        'remaining',
        'paid',
        'status',
        'interest_rate',
        'notes',
        'movements',
      ],
    );
    final val = DebtOut(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      personName: $checkedConvert('person_name', (v) => v as String?),
      direction: $checkedConvert(
        'direction',
        (v) => $enumDecode(_$DebtOutDirectionEnumEnumMap, v),
      ),
      openingBalance: $checkedConvert('opening_balance', (v) => v as String),
      openingDate: $checkedConvert(
        'opening_date',
        (v) => DateTime.parse(v as String),
      ),
      remaining: $checkedConvert('remaining', (v) => v as String),
      paid: $checkedConvert('paid', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$DebtOutStatusEnumEnumMap, v),
      ),
      interestRate: $checkedConvert('interest_rate', (v) => v as String?),
      notes: $checkedConvert('notes', (v) => v as String?),
      movements: $checkedConvert(
        'movements',
        (v) => (v as List<dynamic>)
            .map((e) => DebtMovementOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
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

Map<String, dynamic> _$DebtOutToJson(DebtOut instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'person_name': instance.personName,
  'direction': _$DebtOutDirectionEnumEnumMap[instance.direction]!,
  'opening_balance': instance.openingBalance,
  'opening_date': instance.openingDate.toIso8601String(),
  'remaining': instance.remaining,
  'paid': instance.paid,
  'status': _$DebtOutStatusEnumEnumMap[instance.status]!,
  'interest_rate': instance.interestRate,
  'notes': instance.notes,
  'movements': instance.movements.map((e) => e.toJson()).toList(),
};

const _$DebtOutDirectionEnumEnumMap = {
  DebtOutDirectionEnum.debo: 'debo',
  DebtOutDirectionEnum.meDeben: 'me_deben',
};

const _$DebtOutStatusEnumEnumMap = {
  DebtOutStatusEnum.viva: 'viva',
  DebtOutStatusEnum.saldada: 'saldada',
};
