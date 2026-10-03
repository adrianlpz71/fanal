// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'snapshot_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SnapshotOut _$SnapshotOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SnapshotOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['date', 'value', 'cost', 'net_flow', 'manual'],
      );
      final val = SnapshotOut(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        value: $checkedConvert('value', (v) => v as String),
        cost: $checkedConvert('cost', (v) => v as String?),
        netFlow: $checkedConvert('net_flow', (v) => v as String),
        manual: $checkedConvert('manual', (v) => v as bool),
      );
      return val;
    }, fieldKeyMap: const {'netFlow': 'net_flow'});

Map<String, dynamic> _$SnapshotOutToJson(SnapshotOut instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'value': instance.value,
      'cost': instance.cost,
      'net_flow': instance.netFlow,
      'manual': instance.manual,
    };
