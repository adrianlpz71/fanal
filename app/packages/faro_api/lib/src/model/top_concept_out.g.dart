// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'top_concept_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TopConceptOut _$TopConceptOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TopConceptOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['concept', 'total', 'count']);
      final val = TopConceptOut(
        concept: $checkedConvert('concept', (v) => v as String),
        total: $checkedConvert('total', (v) => v as String),
        count: $checkedConvert('count', (v) => (v as num).toInt()),
      );
      return val;
    });

Map<String, dynamic> _$TopConceptOutToJson(TopConceptOut instance) =>
    <String, dynamic>{
      'concept': instance.concept,
      'total': instance.total,
      'count': instance.count,
    };
