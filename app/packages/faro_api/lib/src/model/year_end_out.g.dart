// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'year_end_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

YearEndOut _$YearEndOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('YearEndOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['name', 'kind', 'value', 'foreign_hint'],
      );
      final val = YearEndOut(
        name: $checkedConvert('name', (v) => v as String),
        kind: $checkedConvert(
          'kind',
          (v) => $enumDecode(_$YearEndOutKindEnumEnumMap, v),
        ),
        value: $checkedConvert('value', (v) => v as String),
        foreignHint: $checkedConvert('foreign_hint', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'foreignHint': 'foreign_hint'});

Map<String, dynamic> _$YearEndOutToJson(YearEndOut instance) =>
    <String, dynamic>{
      'name': instance.name,
      'kind': _$YearEndOutKindEnumEnumMap[instance.kind]!,
      'value': instance.value,
      'foreign_hint': instance.foreignHint,
    };

const _$YearEndOutKindEnumEnumMap = {
  YearEndOutKindEnum.cuenta: 'cuenta',
  YearEndOutKindEnum.activo: 'activo',
};
