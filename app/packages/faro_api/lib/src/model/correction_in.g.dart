// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'correction_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CorrectionIn _$CorrectionInFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CorrectionIn',
      json,
      ($checkedConvert) {
        $checkKeys(json, requiredKeys: const ['units', 'avg_cost', 'reason']);
        final val = CorrectionIn(
          units: $checkedConvert('units', (v) => v as String),
          avgCost: $checkedConvert('avg_cost', (v) => v as String),
          reason: $checkedConvert('reason', (v) => v as String),
          effectiveDate: $checkedConvert(
            'effective_date',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'avgCost': 'avg_cost',
        'effectiveDate': 'effective_date',
      },
    );

Map<String, dynamic> _$CorrectionInToJson(CorrectionIn instance) =>
    <String, dynamic>{
      'units': instance.units,
      'avg_cost': instance.avgCost,
      'reason': instance.reason,
      'effective_date': ?instance.effectiveDate?.toIso8601String(),
    };
