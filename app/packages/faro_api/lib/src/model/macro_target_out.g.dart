// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'macro_target_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MacroTargetOut _$MacroTargetOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MacroTargetOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'asset_class_id',
            'target',
            'min',
            'max',
            'tolerance_pp',
            'valid_from',
          ],
        );
        final val = MacroTargetOut(
          assetClassId: $checkedConvert('asset_class_id', (v) => v as String),
          target: $checkedConvert('target', (v) => v as String),
          min: $checkedConvert('min', (v) => v as String?),
          max: $checkedConvert('max', (v) => v as String?),
          tolerancePp: $checkedConvert('tolerance_pp', (v) => v as String?),
          validFrom: $checkedConvert(
            'valid_from',
            (v) => DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'assetClassId': 'asset_class_id',
        'tolerancePp': 'tolerance_pp',
        'validFrom': 'valid_from',
      },
    );

Map<String, dynamic> _$MacroTargetOutToJson(MacroTargetOut instance) =>
    <String, dynamic>{
      'asset_class_id': instance.assetClassId,
      'target': instance.target,
      'min': instance.min,
      'max': instance.max,
      'tolerance_pp': instance.tolerancePp,
      'valid_from': instance.validFrom.toIso8601String(),
    };
