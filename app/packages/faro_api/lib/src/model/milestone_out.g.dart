// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestone_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MilestoneOut _$MilestoneOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MilestoneOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['amount', 'reached_on', 'before_start'],
        );
        final val = MilestoneOut(
          amount: $checkedConvert('amount', (v) => v as String),
          reachedOn: $checkedConvert(
            'reached_on',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          beforeStart: $checkedConvert('before_start', (v) => v as bool),
        );
        return val;
      },
      fieldKeyMap: const {
        'reachedOn': 'reached_on',
        'beforeStart': 'before_start',
      },
    );

Map<String, dynamic> _$MilestoneOutToJson(MilestoneOut instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'reached_on': instance.reachedOn?.toIso8601String(),
      'before_start': instance.beforeStart,
    };
