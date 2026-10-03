// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'milestones_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MilestonesOut _$MilestonesOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MilestonesOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'thresholds',
          'items',
          'next',
          'pace',
          'net',
          'start',
        ],
      );
      final val = MilestonesOut(
        thresholds: $checkedConvert(
          'thresholds',
          (v) => (v as List<dynamic>).map((e) => e as String).toList(),
        ),
        items: $checkedConvert(
          'items',
          (v) => (v as List<dynamic>)
              .map((e) => MilestoneOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
        next: $checkedConvert(
          'next',
          (v) => v == null
              ? null
              : MilestoneNextOut.fromJson(v as Map<String, dynamic>),
        ),
        pace: $checkedConvert('pace', (v) => v as String),
        net: $checkedConvert('net', (v) => v as String),
        start: $checkedConvert(
          'start',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
      );
      return val;
    });

Map<String, dynamic> _$MilestonesOutToJson(MilestonesOut instance) =>
    <String, dynamic>{
      'thresholds': instance.thresholds,
      'items': instance.items.map((e) => e.toJson()).toList(),
      'next': instance.next?.toJson(),
      'pace': instance.pace,
      'net': instance.net,
      'start': instance.start?.toIso8601String(),
    };
