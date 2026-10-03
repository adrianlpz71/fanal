// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fixed_item_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FixedItemOut _$FixedItemOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'FixedItemOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'kind',
        'id',
        'name',
        'monthly',
        'yearly',
        'review',
        'est_saving_year',
        'price_changes',
        'ends',
        'category_id',
      ],
    );
    final val = FixedItemOut(
      kind: $checkedConvert(
        'kind',
        (v) => $enumDecode(_$FixedItemOutKindEnumEnumMap, v),
      ),
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      monthly: $checkedConvert('monthly', (v) => v as String),
      yearly: $checkedConvert('yearly', (v) => v as String),
      review: $checkedConvert('review', (v) => v as String?),
      estSavingYear: $checkedConvert('est_saving_year', (v) => v as String?),
      priceChanges: $checkedConvert('price_changes', (v) => (v as num).toInt()),
      ends: $checkedConvert(
        'ends',
        (v) => v == null ? null : DateTime.parse(v as String),
      ),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'estSavingYear': 'est_saving_year',
    'priceChanges': 'price_changes',
    'categoryId': 'category_id',
  },
);

Map<String, dynamic> _$FixedItemOutToJson(FixedItemOut instance) =>
    <String, dynamic>{
      'kind': _$FixedItemOutKindEnumEnumMap[instance.kind]!,
      'id': instance.id,
      'name': instance.name,
      'monthly': instance.monthly,
      'yearly': instance.yearly,
      'review': instance.review,
      'est_saving_year': instance.estSavingYear,
      'price_changes': instance.priceChanges,
      'ends': instance.ends?.toIso8601String(),
      'category_id': instance.categoryId,
    };

const _$FixedItemOutKindEnumEnumMap = {
  FixedItemOutKindEnum.recurrente: 'recurrente',
  FixedItemOutKindEnum.cuota: 'cuota',
};
