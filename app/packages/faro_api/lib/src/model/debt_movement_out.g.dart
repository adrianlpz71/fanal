// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_movement_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtMovementOut _$DebtMovementOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DebtMovementOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['id', 'date', 'concept', 'amount']);
      final val = DebtMovementOut(
        id: $checkedConvert('id', (v) => v as String),
        date: $checkedConvert(
          'date',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        concept: $checkedConvert('concept', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$DebtMovementOutToJson(DebtMovementOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'date': instance.date?.toIso8601String(),
      'concept': instance.concept,
      'amount': instance.amount,
    };
