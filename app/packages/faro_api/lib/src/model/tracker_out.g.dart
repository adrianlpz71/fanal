// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackerOut _$TrackerOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TrackerOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'name',
        'opening_balance',
        'opening_date',
        'category_ids',
        'keywords',
        'archived',
        'notes',
        'balance',
        'movements_count',
        'by_cycle',
      ],
    );
    final val = TrackerOut(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      openingBalance: $checkedConvert('opening_balance', (v) => v as String),
      openingDate: $checkedConvert(
        'opening_date',
        (v) => DateTime.parse(v as String),
      ),
      categoryIds: $checkedConvert(
        'category_ids',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      keywords: $checkedConvert(
        'keywords',
        (v) => (v as List<dynamic>).map((e) => e as String).toList(),
      ),
      archived: $checkedConvert('archived', (v) => v as bool),
      notes: $checkedConvert('notes', (v) => v as String?),
      balance: $checkedConvert('balance', (v) => v as String),
      movementsCount: $checkedConvert(
        'movements_count',
        (v) => (v as num).toInt(),
      ),
      byCycle: $checkedConvert(
        'by_cycle',
        (v) => (v as List<dynamic>)
            .map((e) => TrackerCycleOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
    );
    return val;
  },
  fieldKeyMap: const {
    'openingBalance': 'opening_balance',
    'openingDate': 'opening_date',
    'categoryIds': 'category_ids',
    'movementsCount': 'movements_count',
    'byCycle': 'by_cycle',
  },
);

Map<String, dynamic> _$TrackerOutToJson(TrackerOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'opening_balance': instance.openingBalance,
      'opening_date': instance.openingDate.toIso8601String(),
      'category_ids': instance.categoryIds,
      'keywords': instance.keywords,
      'archived': instance.archived,
      'notes': instance.notes,
      'balance': instance.balance,
      'movements_count': instance.movementsCount,
      'by_cycle': instance.byCycle.map((e) => e.toJson()).toList(),
    };
