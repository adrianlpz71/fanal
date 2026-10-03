// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inv_settings_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvSettingsIn _$InvSettingsInFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'InvSettingsIn',
      json,
      ($checkedConvert) {
        final val = InvSettingsIn(
          minOperation: $checkedConvert('min_operation', (v) => v as String?),
          monthlyContribution: $checkedConvert(
            'monthly_contribution',
            (v) => v as String?,
          ),
          trackStart: $checkedConvert(
            'track_start',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          clearTrackStart: $checkedConvert(
            'clear_track_start',
            (v) => v as bool? ?? false,
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'minOperation': 'min_operation',
        'monthlyContribution': 'monthly_contribution',
        'trackStart': 'track_start',
        'clearTrackStart': 'clear_track_start',
      },
    );

Map<String, dynamic> _$InvSettingsInToJson(InvSettingsIn instance) =>
    <String, dynamic>{
      'min_operation': ?instance.minOperation,
      'monthly_contribution': ?instance.monthlyContribution,
      'track_start': ?instance.trackStart?.toIso8601String(),
      'clear_track_start': ?instance.clearTrackStart,
    };
