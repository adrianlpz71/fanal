// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggestion_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestionOut _$SuggestionOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SuggestionOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['concept', 'category_id', 'amount'],
      );
      final val = SuggestionOut(
        concept: $checkedConvert('concept', (v) => v as String),
        categoryId: $checkedConvert('category_id', (v) => v as String?),
        amount: $checkedConvert('amount', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'categoryId': 'category_id'});

Map<String, dynamic> _$SuggestionOutToJson(SuggestionOut instance) =>
    <String, dynamic>{
      'concept': instance.concept,
      'category_id': instance.categoryId,
      'amount': instance.amount,
    };
