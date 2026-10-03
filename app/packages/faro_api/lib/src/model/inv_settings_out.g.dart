// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inv_settings_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvSettingsOut _$InvSettingsOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'InvSettingsOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'configured',
            'min_operation',
            'monthly_contribution',
            'track_start',
          ],
        );
        final val = InvSettingsOut(
          configured: $checkedConvert('configured', (v) => v as bool),
          minOperation: $checkedConvert('min_operation', (v) => v as String),
          monthlyContribution: $checkedConvert(
            'monthly_contribution',
            (v) => v as String?,
          ),
          trackStart: $checkedConvert(
            'track_start',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'minOperation': 'min_operation',
        'monthlyContribution': 'monthly_contribution',
        'trackStart': 'track_start',
      },
    );

Map<String, dynamic> _$InvSettingsOutToJson(InvSettingsOut instance) =>
    <String, dynamic>{
      'configured': instance.configured,
      'min_operation': instance.minOperation,
      'monthly_contribution': instance.monthlyContribution,
      'track_start': instance.trackStart?.toIso8601String(),
    };
