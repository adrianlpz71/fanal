// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_suggestion_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixedSuggestionOut _$FixedSuggestionOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'FixedSuggestionOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'concept',
            'amount',
            'cycles',
            'day_of_month',
            'category_id',
          ],
        );
        final val = FixedSuggestionOut(
          concept: $checkedConvert('concept', (v) => v as String),
          amount: $checkedConvert('amount', (v) => v as String),
          cycles: $checkedConvert('cycles', (v) => (v as num).toInt()),
          dayOfMonth: $checkedConvert(
            'day_of_month',
            (v) => (v as num).toInt(),
          ),
          categoryId: $checkedConvert('category_id', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'dayOfMonth': 'day_of_month',
        'categoryId': 'category_id',
      },
    );

Map<String, dynamic> _$FixedSuggestionOutToJson(FixedSuggestionOut instance) =>
    <String, dynamic>{
      'concept': instance.concept,
      'amount': instance.amount,
      'cycles': instance.cycles,
      'day_of_month': instance.dayOfMonth,
      'category_id': instance.categoryId,
    };
