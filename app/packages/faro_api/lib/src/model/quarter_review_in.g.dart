// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quarter_review_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuarterReviewIn _$QuarterReviewInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('QuarterReviewIn', json, ($checkedConvert) {
      final val = QuarterReviewIn(
        changed: $checkedConvert('changed', (v) => v as String? ?? ''),
        nextSteps: $checkedConvert('next_steps', (v) => v as String? ?? ''),
      );
      return val;
    }, fieldKeyMap: const {'nextSteps': 'next_steps'});

Map<String, dynamic> _$QuarterReviewInToJson(QuarterReviewIn instance) =>
    <String, dynamic>{
      'changed': ?instance.changed,
      'next_steps': ?instance.nextSteps,
    };
