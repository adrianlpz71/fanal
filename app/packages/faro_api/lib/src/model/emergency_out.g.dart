// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emergency_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EmergencyOut _$EmergencyOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('EmergencyOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'target',
          'current',
          'coverage',
          'missing',
          'suggested_monthly',
        ],
      );
      final val = EmergencyOut(
        target: $checkedConvert('target', (v) => v as String),
        current: $checkedConvert('current', (v) => v as String),
        coverage: $checkedConvert('coverage', (v) => v as String),
        missing: $checkedConvert('missing', (v) => v as String),
        suggestedMonthly: $checkedConvert(
          'suggested_monthly',
          (v) => v as String,
        ),
      );
      return val;
    }, fieldKeyMap: const {'suggestedMonthly': 'suggested_monthly'});

Map<String, dynamic> _$EmergencyOutToJson(EmergencyOut instance) =>
    <String, dynamic>{
      'target': instance.target,
      'current': instance.current,
      'coverage': instance.coverage,
      'missing': instance.missing,
      'suggested_monthly': instance.suggestedMonthly,
    };
