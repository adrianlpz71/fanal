// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tracker_cycle_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TrackerCycleOut _$TrackerCycleOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TrackerCycleOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['label', 'amount']);
      final val = TrackerCycleOut(
        label: $checkedConvert('label', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$TrackerCycleOutToJson(TrackerCycleOut instance) =>
    <String, dynamic>{'label': instance.label, 'amount': instance.amount};
