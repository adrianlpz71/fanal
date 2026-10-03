// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformIn _$PlatformInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PlatformIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['name']);
    final val = PlatformIn(
      id: $checkedConvert('id', (v) => v as String?),
      name: $checkedConvert('name', (v) => v as String),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecodeNullable(_$PlatformInKindEnumEnumMap, v),
      ),
      unitsDecimals: $checkedConvert(
        'units_decimals',
        (v) => (v as num?)?.toInt() ?? 4,
      ),
      defaultFee: $checkedConvert('default_fee', (v) => v as String? ?? '0'),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'unitsDecimals': 'units_decimals',
    'defaultFee': 'default_fee',
  },
);

Map<String, dynamic> _$PlatformInToJson(PlatformIn instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'name': instance.name,
      'kind': ?_$PlatformInKindEnumEnumMap[instance.kind],
      'units_decimals': ?instance.unitsDecimals,
      'default_fee': ?instance.defaultFee,
      'notes': ?instance.notes,
    };

const _$PlatformInKindEnumEnumMap = {
  PlatformInKindEnum.broker: 'broker',
  PlatformInKindEnum.exchange: 'exchange',
  PlatformInKindEnum.banco: 'banco',
  PlatformInKindEnum.otro: 'otro',
};
