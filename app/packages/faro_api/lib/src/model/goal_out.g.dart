// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoalOut _$GoalOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'GoalOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'kind',
        'name',
        'target_value',
        'target_date',
        'current',
        'progress',
        'on_track',
        'detail',
      ],
    );
    final val = GoalOut(
      id: $checkedConvert('id', (v) => v as String),
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$GoalOutKindEnumEnumMap, v),
      ),
      name: $checkedConvert('name', (v) => v as String),
      targetValue: $checkedConvert('target_value', (v) => v as String?),
      targetDate: $checkedConvert(
        'target_date',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      current: $checkedConvert('current', (v) => v as String?),
      progress: $checkedConvert('progress', (v) => v as String?),
      onTrack: $checkedConvert('on_track', (v) => v as bool?),
      detail: $checkedConvert('detail', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'targetValue': 'target_value',
    'targetDate': 'target_date',
    'onTrack': 'on_track',
  },
);

Map<String, dynamic> _$GoalOutToJson(GoalOut instance) => <String, dynamic>{
  'id': instance.id,
  'kind': _$GoalOutKindEnumEnumMap[instance.kind]!,
  'name': instance.name,
  'target_value': instance.targetValue,
  'target_date': instance.targetDate?.toIso8601String(),
  'current': instance.current,
  'progress': instance.progress,
  'on_track': instance.onTrack,
  'detail': instance.detail,
};

const _$GoalOutKindEnumEnumMap = {
  GoalOutKindEnum.edadFi: 'edad_fi',
  GoalOutKindEnum.fondoEmergencia: 'fondo_emergencia',
  GoalOutKindEnum.patrimonio: 'patrimonio',
  GoalOutKindEnum.carteraEnFecha: 'cartera_en_fecha',
  GoalOutKindEnum.fijosMax: 'fijos_max',
  GoalOutKindEnum.tasaAhorroMin: 'tasa_ahorro_min',
};
