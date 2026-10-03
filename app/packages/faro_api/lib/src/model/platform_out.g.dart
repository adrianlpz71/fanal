// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformOut _$PlatformOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'PlatformOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'name',
        'kind',
        'units_decimals',
        'default_fee',
        'notes',
      ],
    );
    final val = PlatformOut(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$PlatformOutKindEnumEnumMap, v),
      ),
      unitsDecimals: $checkedConvert(
        'units_decimals',
        (v) => (v as num).toInt(),
      ),
      defaultFee: $checkedConvert('default_fee', (v) => v as String),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'unitsDecimals': 'units_decimals',
    'defaultFee': 'default_fee',
  },
);

Map<String, dynamic> _$PlatformOutToJson(PlatformOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'kind': _$PlatformOutKindEnumEnumMap[instance.kind]!,
      'units_decimals': instance.unitsDecimals,
      'default_fee': instance.defaultFee,
      'notes': instance.notes,
    };

const _$PlatformOutKindEnumEnumMap = {
  PlatformOutKindEnum.broker: 'broker',
  PlatformOutKindEnum.exchange: 'exchange',
  PlatformOutKindEnum.banco: 'banco',
  PlatformOutKindEnum.otro: 'otro',
};
