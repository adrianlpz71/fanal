// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payday_undo_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaydayUndoOut _$PaydayUndoOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PaydayUndoOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['available']);
      final val = PaydayUndoOut(
        available: $checkedConvert('available', (v) => v as bool),
        reason: $checkedConvert('reason', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$PaydayUndoOutToJson(PaydayUndoOut instance) =>
    <String, dynamic>{
      'available': instance.available,
      'reason': ?instance.reason,
    };
