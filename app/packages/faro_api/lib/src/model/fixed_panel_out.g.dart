// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_panel_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixedPanelOut _$FixedPanelOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'FixedPanelOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'items',
        'monthly_total',
        'yearly_total',
        'payroll',
        'share_of_payroll',
        'trend',
        'goal_max',
        'goal_name',
        'saved_year',
        'to_review_saving',
        'suggestions',
        'review_due',
        'last_review',
      ],
    );
    final val = FixedPanelOut(
      items: $checkedConvert(
        'items',
        (v) => (v as List<dynamic>)
            .map((e) => FixedItemOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      monthlyTotal: $checkedConvert('monthly_total', (v) => v as String),
      yearlyTotal: $checkedConvert('yearly_total', (v) => v as String),
      payroll: $checkedConvert('payroll', (v) => v as String?),
      shareOfPayroll: $checkedConvert('share_of_payroll', (v) => v as String?),
      trend: $checkedConvert(
        'trend',
        (v) => (v as List<dynamic>)
            .map((e) => FixedTrendOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      goalMax: $checkedConvert('goal_max', (v) => v as String?),
      goalName: $checkedConvert('goal_name', (v) => v as String?),
      savedYear: $checkedConvert('saved_year', (v) => v as String),
      toReviewSaving: $checkedConvert('to_review_saving', (v) => v as String),
      suggestions: $checkedConvert(
        'suggestions',
        (v) => (v as List<dynamic>)
            .map((e) => FixedSuggestionOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      reviewDue: $checkedConvert('review_due', (v) => v as bool),
      lastReview: $checkedConvert(
        'last_review',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'monthlyTotal': 'monthly_total',
    'yearlyTotal': 'yearly_total',
    'shareOfPayroll': 'share_of_payroll',
    'goalMax': 'goal_max',
    'goalName': 'goal_name',
    'savedYear': 'saved_year',
    'toReviewSaving': 'to_review_saving',
    'reviewDue': 'review_due',
    'lastReview': 'last_review',
  },
);

Map<String, dynamic> _$FixedPanelOutToJson(FixedPanelOut instance) =>
    <String, dynamic>{
      'items': instance.items.map((e) => e.toJson()).toList(),
      'monthly_total': instance.monthlyTotal,
      'yearly_total': instance.yearlyTotal,
      'payroll': instance.payroll,
      'share_of_payroll': instance.shareOfPayroll,
      'trend': instance.trend.map((e) => e.toJson()).toList(),
      'goal_max': instance.goalMax,
      'goal_name': instance.goalName,
      'saved_year': instance.savedYear,
      'to_review_saving': instance.toReviewSaving,
      'suggestions': instance.suggestions.map((e) => e.toJson()).toList(),
      'review_due': instance.reviewDue,
      'last_review': instance.lastReview?.toIso8601String(),
    };
