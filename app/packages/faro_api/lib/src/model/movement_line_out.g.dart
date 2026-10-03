// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'movement_line_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MovementLineOut _$MovementLineOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('MovementLineOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['seq', 'amount', 'note']);
      final val = MovementLineOut(
        seq: $checkedConvert('seq', (v) => (v as num).toInt()),
        amount: $checkedConvert('amount', (v) => v as String),
        note: $checkedConvert('note', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$MovementLineOutToJson(MovementLineOut instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'amount': instance.amount,
      'note': instance.note,
    };
