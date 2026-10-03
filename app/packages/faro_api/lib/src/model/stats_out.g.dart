// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'stats_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StatsOut _$StatsOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'StatsOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'cycles',
        'categories',
        'top_concepts',
        'avg_spend',
        'avg_savings_rate',
      ],
    );
    final val = StatsOut(
      cycles: $checkedConvert(
        'cycles',
        (v) => (v as List<dynamic>)
            .map((e) => CycleStatsOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      categories: $checkedConvert(
        'categories',
        (v) => (v as List<dynamic>)
            .map((e) => CategoryStatOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      topConcepts: $checkedConvert(
        'top_concepts',
        (v) => (v as List<dynamic>)
            .map((e) => TopConceptOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      avgSpend: $checkedConvert('avg_spend', (v) => v as String),
      avgSavingsRate: $checkedConvert('avg_savings_rate', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'topConcepts': 'top_concepts',
    'avgSpend': 'avg_spend',
    'avgSavingsRate': 'avg_savings_rate',
  },
);

Map<String, dynamic> _$StatsOutToJson(StatsOut instance) => <String, dynamic>{
  'cycles': instance.cycles.map((e) => e.toJson()).toList(),
  'categories': instance.categories.map((e) => e.toJson()).toList(),
  'top_concepts': instance.topConcepts.map((e) => e.toJson()).toList(),
  'avg_spend': instance.avgSpend,
  'avg_savings_rate': instance.avgSavingsRate,
};
