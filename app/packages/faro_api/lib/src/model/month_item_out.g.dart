// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'month_item_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MonthItemOut _$MonthItemOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'MonthItemOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'kind',
            'date',
            'concept',
            'amount',
            'category_id',
            'source',
            'movement',
            'template_id',
          ],
        );
        final val = MonthItemOut(
          kind: $checkedConvert(
            'kind',
            (v) => $enumDecode(_$MonthItemOutKindEnumEnumMap, v),
          ),
          date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
          concept: $checkedConvert('concept', (v) => v as String),
          amount: $checkedConvert('amount', (v) => v as String),
          categoryId: $checkedConvert('category_id', (v) => v as String?),
          source_: $checkedConvert('source', (v) => v as String),
          movement: $checkedConvert(
            'movement',
            (v) => v == null
                ? null
                : MovementOut.fromJson(v as Map<String, dynamic>),
          ),
          templateId: $checkedConvert('template_id', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'categoryId': 'category_id',
        'source_': 'source',
        'templateId': 'template_id',
      },
    );

Map<String, dynamic> _$MonthItemOutToJson(MonthItemOut instance) =>
    <String, dynamic>{
      'kind': _$MonthItemOutKindEnumEnumMap[instance.kind]!,
      'date': instance.date.toIso8601String(),
      'concept': instance.concept,
      'amount': instance.amount,
      'category_id': instance.categoryId,
      'source': instance.source_,
      'movement': instance.movement?.toJson(),
      'template_id': instance.templateId,
    };

const _$MonthItemOutKindEnumEnumMap = {
  MonthItemOutKindEnum.movimiento: 'movimiento',
  MonthItemOutKindEnum.recurrente: 'recurrente',
};
