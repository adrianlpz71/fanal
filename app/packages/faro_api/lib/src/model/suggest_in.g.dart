// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'suggest_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SuggestIn _$SuggestInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SuggestIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['amount']);
      final val = SuggestIn(
        amount: $checkedConvert('amount', (v) => v as String),
        roundTo: $checkedConvert('round_to', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'roundTo': 'round_to'});

Map<String, dynamic> _$SuggestInToJson(SuggestIn instance) => <String, dynamic>{
  'amount': instance.amount,
  'round_to': ?instance.roundTo,
};
