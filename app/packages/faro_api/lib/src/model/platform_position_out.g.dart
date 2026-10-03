// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_position_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlatformPositionOut _$PlatformPositionOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PlatformPositionOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'key',
            'name',
            'units_now',
            'units_after',
            'avg_cost_after',
            'replaced_initial',
          ],
        );
        final val = PlatformPositionOut(
          key: $checkedConvert('key', (v) => v as String),
          name: $checkedConvert('name', (v) => v as String),
          unitsNow: $checkedConvert('units_now', (v) => v as String),
          unitsAfter: $checkedConvert('units_after', (v) => v as String),
          avgCostAfter: $checkedConvert('avg_cost_after', (v) => v as String),
          replacedInitial: $checkedConvert(
            'replaced_initial',
            (v) => v as bool,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'unitsNow': 'units_now',
        'unitsAfter': 'units_after',
        'avgCostAfter': 'avg_cost_after',
        'replacedInitial': 'replaced_initial',
      },
    );

Map<String, dynamic> _$PlatformPositionOutToJson(
  PlatformPositionOut instance,
) => <String, dynamic>{
  'key': instance.key,
  'name': instance.name,
  'units_now': instance.unitsNow,
  'units_after': instance.unitsAfter,
  'avg_cost_after': instance.avgCostAfter,
  'replaced_initial': instance.replacedInitial,
};
