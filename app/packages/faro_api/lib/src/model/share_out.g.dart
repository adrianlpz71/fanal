// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShareOut _$ShareOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ShareOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'movement_id',
        'person_id',
        'person_name',
        'amount',
        'direction',
        'status',
        'settled_by_movement_id',
      ],
    );
    final val = ShareOut(
      id: $checkedConvert('id', (v) => v as String),
      movementId: $checkedConvert('movement_id', (v) => v as String),
      personId: $checkedConvert('person_id', (v) => v as String),
      personName: $checkedConvert('person_name', (v) => v as String),
      amount: $checkedConvert('amount', (v) => v as String),
      direction: $checkedConvert(
        'direction',
        (v) => $enumDecode(_$ShareOutDirectionEnumEnumMap, v),
      ),
      status: $checkedConvert(
        'status',
        (v) => $enumDecode(_$ShareOutStatusEnumEnumMap, v),
      ),
      settledByMovementId: $checkedConvert(
        'settled_by_movement_id',
        (v) => v as String?,
      ),
      movementConcept: $checkedConvert('movement_concept', (v) => v as String?),
      movementDate: $checkedConvert(
        'movement_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'movementId': 'movement_id',
    'personId': 'person_id',
    'personName': 'person_name',
    'settledByMovementId': 'settled_by_movement_id',
    'movementConcept': 'movement_concept',
    'movementDate': 'movement_date',
  },
);

Map<String, dynamic> _$ShareOutToJson(ShareOut instance) => <String, dynamic>{
  'id': instance.id,
  'movement_id': instance.movementId,
  'person_id': instance.personId,
  'person_name': instance.personName,
  'amount': instance.amount,
  'direction': _$ShareOutDirectionEnumEnumMap[instance.direction]!,
  'status': _$ShareOutStatusEnumEnumMap[instance.status]!,
  'settled_by_movement_id': instance.settledByMovementId,
  'movement_concept': ?instance.movementConcept,
  'movement_date': ?instance.movementDate?.toIso8601String(),
};

const _$ShareOutDirectionEnumEnumMap = {
  ShareOutDirectionEnum.meDeben: 'me_deben',
  ShareOutDirectionEnum.debo: 'debo',
};

const _$ShareOutStatusEnumEnumMap = {
  ShareOutStatusEnum.pendiente: 'pendiente',
  ShareOutStatusEnum.saldada: 'saldada',
};
