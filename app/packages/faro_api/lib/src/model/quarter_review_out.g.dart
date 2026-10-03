// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quarter_review_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuarterReviewOut _$QuarterReviewOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'QuarterReviewOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'quarter',
            'label',
            'start',
            'end',
            'in_progress',
            'metrics',
            'previous',
            'previous_label',
            'rising',
            'changed',
            'next_steps',
            'saved_at',
          ],
        );
        final val = QuarterReviewOut(
          quarter: $checkedConvert('quarter', (v) => v as String),
          label: $checkedConvert('label', (v) => v as String),
          start: $checkedConvert('start', (v) => DateTime.parse(v as String)),
          end: $checkedConvert('end', (v) => DateTime.parse(v as String)),
          inProgress: $checkedConvert('in_progress', (v) => v as bool),
          metrics: $checkedConvert(
            'metrics',
            (v) => QuarterMetricsOut.fromJson(v as Map<String, dynamic>),
          ),
          previous: $checkedConvert(
            'previous',
            (v) => v == null
                ? null
                : QuarterMetricsOut.fromJson(v as Map<String, dynamic>),
          ),
          previousLabel: $checkedConvert('previous_label', (v) => v as String),
          rising: $checkedConvert(
            'rising',
            (v) => (v as List<dynamic>)
                .map((e) => CategoryRiseOut.fromJson(e as Map<String, dynamic>))
                .toList(),
          ),
          changed: $checkedConvert('changed', (v) => v as String),
          nextSteps: $checkedConvert('next_steps', (v) => v as String),
          savedAt: $checkedConvert(
            'saved_at',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'inProgress': 'in_progress',
        'previousLabel': 'previous_label',
        'nextSteps': 'next_steps',
        'savedAt': 'saved_at',
      },
    );

Map<String, dynamic> _$QuarterReviewOutToJson(QuarterReviewOut instance) =>
    <String, dynamic>{
      'quarter': instance.quarter,
      'label': instance.label,
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
      'in_progress': instance.inProgress,
      'metrics': instance.metrics.toJson(),
      'previous': instance.previous?.toJson(),
      'previous_label': instance.previousLabel,
      'rising': instance.rising.map((e) => e.toJson()).toList(),
      'changed': instance.changed,
      'next_steps': instance.nextSteps,
      'saved_at': instance.savedAt?.toIso8601String(),
    };
