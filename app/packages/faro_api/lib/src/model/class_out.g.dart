// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassOut _$ClassOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'ClassOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'asset_class',
        'value',
        'pending',
        'weight',
        'target',
        'min',
        'max',
        'tolerance_pp',
        'status',
        'positions',
      ],
    );
    final val = ClassOut(
      assetClass: $checkedConvert(
        'asset_class',
        (v) => AssetClassOut.fromJson(v as Map<String, dynamic>),
      ),
      value: $checkedConvert('value', (v) => v as String),
      pending: $checkedConvert('pending', (v) => v as String),
      weight: $checkedConvert('weight', (v) => v as String),
      target: $checkedConvert('target', (v) => v as String?),
      min: $checkedConvert('min', (v) => v as String?),
      max: $checkedConvert('max', (v) => v as String?),
      tolerancePp: $checkedConvert('tolerance_pp', (v) => v as String),
      status: $checkedConvert(
        'status',
        (v) => $enumDecodeNullable(_$ClassOutStatusEnumEnumMap, v),
      ),
      positions: $checkedConvert(
        'positions',
        (v) => (v as List<dynamic>)
            .map((e) => PositionOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'assetClass': 'asset_class',
    'tolerancePp': 'tolerance_pp',
  },
);

Map<String, dynamic> _$ClassOutToJson(ClassOut instance) => <String, dynamic>{
  'asset_class': instance.assetClass.toJson(),
  'value': instance.value,
  'pending': instance.pending,
  'weight': instance.weight,
  'target': instance.target,
  'min': instance.min,
  'max': instance.max,
  'tolerance_pp': instance.tolerancePp,
  'status': _$ClassOutStatusEnumEnumMap[instance.status],
  'positions': instance.positions.map((e) => e.toJson()).toList(),
};

const _$ClassOutStatusEnumEnumMap = {
  ClassOutStatusEnum.bajo: 'bajo',
  ClassOutStatusEnum.alto: 'alto',
  ClassOutStatusEnum.ok: 'ok',
};
