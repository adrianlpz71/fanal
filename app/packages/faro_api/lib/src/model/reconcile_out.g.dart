// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reconcile_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReconcileOut _$ReconcileOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ReconcileOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const ['computed', 'real', 'difference', 'adjustment_id'],
      );
      final val = ReconcileOut(
        computed: $checkedConvert('computed', (v) => v as String),
        real: $checkedConvert('real', (v) => v as String),
        difference: $checkedConvert('difference', (v) => v as String),
        adjustmentId: $checkedConvert('adjustment_id', (v) => v as String?),
      );
      return val;
    }, fieldKeyMap: const {'adjustmentId': 'adjustment_id'});

Map<String, dynamic> _$ReconcileOutToJson(ReconcileOut instance) =>
    <String, dynamic>{
      'computed': instance.computed,
      'real': instance.real,
      'difference': instance.difference,
      'adjustment_id': instance.adjustmentId,
    };
