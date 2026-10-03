// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rule_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RuleOut _$RuleOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('RuleOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['id', 'pattern', 'category_id', 'source', 'hits'],
      );
      final val = RuleOut(
        id: $checkedConvert('id', (v) => v as String),
        pattern: $checkedConvert('pattern', (v) => v as String),
        categoryId: $checkedConvert('category_id', (v) => v as String),
        source_: $checkedConvert('source', (v) => v as String),
        hits: $checkedConvert('hits', (v) => (v as num).toInt()),
      );
      return val;
    }, fieldKeyMap: const {'categoryId': 'category_id', 'source_': 'source'});

Map<String, dynamic> _$RuleOutToJson(RuleOut instance) => <String, dynamic>{
  'id': instance.id,
  'pattern': instance.pattern,
  'category_id': instance.categoryId,
  'source': instance.source_,
  'hits': instance.hits,
};
