// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackerIn _$TrackerInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TrackerIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['name', 'opening_date']);
    final val = TrackerIn(
      name: $checkedConvert('name', (v) => v as String),
      openingBalance: $checkedConvert(
        'opening_balance',
        (v) => v as String? ?? '0',
      ),
      openingDate: $checkedConvert(
        'opening_date',
        (v) => DateTime.parse(v as String),
      ),
      categoryIds: $checkedConvert(
        'category_ids',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      keywords: $checkedConvert(
        'keywords',
        (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
      ),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'openingBalance': 'opening_balance',
    'openingDate': 'opening_date',
    'categoryIds': 'category_ids',
  },
);

Map<String, dynamic> _$TrackerInToJson(TrackerIn instance) => <String, dynamic>{
  'name': instance.name,
  'opening_balance': ?instance.openingBalance,
  'opening_date': instance.openingDate.toIso8601String(),
  'category_ids': ?instance.categoryIds,
  'keywords': ?instance.keywords,
  'notes': ?instance.notes,
};
