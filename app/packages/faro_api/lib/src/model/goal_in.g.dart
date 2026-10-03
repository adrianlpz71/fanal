// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalIn _$GoalInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'GoalIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['kind', 'name']);
    final val = GoalIn(
      id: $checkedConvert('id', (v) => v as String?),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$GoalInKindEnumEnumMap, v),
      ),
      name: $checkedConvert('name', (v) => v as String),
      targetValue: $checkedConvert('target_value', (v) => v as String?),
      targetDate: $checkedConvert(
        'target_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'targetValue': 'target_value',
    'targetDate': 'target_date',
  },
);

Map<String, dynamic> _$GoalInToJson(GoalIn instance) => <String, dynamic>{
  'id': ?instance.id,
  'kind': _$GoalInKindEnumEnumMap[instance.kind]!,
  'name': instance.name,
  'target_value': ?instance.targetValue,
  'target_date': ?instance.targetDate?.toIso8601String(),
};

const _$GoalInKindEnumEnumMap = {
  GoalInKindEnum.edadFi: 'edad_fi',
  GoalInKindEnum.fondoEmergencia: 'fondo_emergencia',
  GoalInKindEnum.patrimonio: 'patrimonio',
  GoalInKindEnum.carteraEnFecha: 'cartera_en_fecha',
  GoalInKindEnum.fijosMax: 'fijos_max',
  GoalInKindEnum.tasaAhorroMin: 'tasa_ahorro_min',
};
