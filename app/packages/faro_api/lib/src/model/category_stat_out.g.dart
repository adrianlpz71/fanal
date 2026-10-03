// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_stat_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryStatOut _$CategoryStatOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'CategoryStatOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'category_id',
            'name',
            'current',
            'average',
            'budget',
            'budget_used',
            'trend',
          ],
        );
        final val = CategoryStatOut(
          categoryId: $checkedConvert('category_id', (v) => v as String?),
          name: $checkedConvert('name', (v) => v as String),
          current: $checkedConvert('current', (v) => v as String),
          average: $checkedConvert('average', (v) => v as String),
          budget: $checkedConvert('budget', (v) => v as String?),
          budgetUsed: $checkedConvert('budget_used', (v) => v as String?),
          trend: $checkedConvert(
            'trend',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'categoryId': 'category_id',
        'budgetUsed': 'budget_used',
      },
    );

Map<String, dynamic> _$CategoryStatOutToJson(CategoryStatOut instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'name': instance.name,
      'current': instance.current,
      'average': instance.average,
      'budget': instance.budget,
      'budget_used': instance.budgetUsed,
      'trend': instance.trend,
    };
