// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackerPatch _$TrackerPatchFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'TrackerPatch',
      json,
      ($checkedConvert) {
        final val = TrackerPatch(
          name: $checkedConvert('name', (v) => v as String?),
          openingBalance: $checkedConvert(
            'opening_balance',
            (v) => v as String?,
          ),
          openingDate: $checkedConvert(
            'opening_date',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          categoryIds: $checkedConvert(
            'category_ids',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
          ),
          keywords: $checkedConvert(
            'keywords',
            (v) => (v as List<dynamic>?)?.map((e) => e as String).toList(),
          ),
          archived: $checkedConvert('archived', (v) => v as bool?),
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

Map<String, dynamic> _$TrackerPatchToJson(TrackerPatch instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'opening_balance': ?instance.openingBalance,
      'opening_date': ?instance.openingDate?.toIso8601String(),
      'category_ids': ?instance.categoryIds,
      'keywords': ?instance.keywords,
      'archived': ?instance.archived,
      'notes': ?instance.notes,
    };
