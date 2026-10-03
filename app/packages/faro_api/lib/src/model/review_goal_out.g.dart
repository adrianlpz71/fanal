// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_goal_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReviewGoalOut _$ReviewGoalOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReviewGoalOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['name', 'progress', 'on_track']);
      final val = ReviewGoalOut(
        name: $checkedConvert('name', (v) => v as String),
        progress: $checkedConvert('progress', (v) => v as String?),
        onTrack: $checkedConvert('on_track', (v) => v as bool?),
      );
      return val;
    }, fieldKeyMap: const {'onTrack': 'on_track'});

Map<String, dynamic> _$ReviewGoalOutToJson(ReviewGoalOut instance) =>
    <String, dynamic>{
      'name': instance.name,
      'progress': instance.progress,
      'on_track': instance.onTrack,
    };
