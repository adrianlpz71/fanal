// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macro_target_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MacroTargetIn _$MacroTargetInFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MacroTargetIn',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['asset_class_id', 'target']);
        final val = MacroTargetIn(
          assetClassId: $checkedConvert('asset_class_id', (v) => v as String),
          target: $checkedConvert('target', (v) => v as String),
          min: $checkedConvert('min', (v) => v as String?),
          max: $checkedConvert('max', (v) => v as String?),
          tolerancePp: $checkedConvert('tolerance_pp', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'assetClassId': 'asset_class_id',
        'tolerancePp': 'tolerance_pp',
      },
    );

Map<String, dynamic> _$MacroTargetInToJson(MacroTargetIn instance) =>
    <String, dynamic>{
      'asset_class_id': instance.assetClassId,
      'target': instance.target,
      'min': ?instance.min,
      'max': ?instance.max,
      'tolerance_pp': ?instance.tolerancePp,
    };
