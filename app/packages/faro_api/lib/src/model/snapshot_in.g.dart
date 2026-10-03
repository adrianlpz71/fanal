// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnapshotIn _$SnapshotInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SnapshotIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'value']);
      final val = SnapshotIn(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        value: $checkedConvert('value', (v) => v as String),
        cost: $checkedConvert('cost', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$SnapshotInToJson(SnapshotIn instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'cost': ?instance.cost,
    };
