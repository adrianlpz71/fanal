// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debt_payment_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DebtPaymentIn _$DebtPaymentInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('DebtPaymentIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['amount']);
      final val = DebtPaymentIn(
        amount: $checkedConvert('amount', (v) => v as String),
        date: $checkedConvert(
          'date',
          (v) => v == null ? null : DateTime.parse(v as String),
        ),
        concept: $checkedConvert('concept', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$DebtPaymentInToJson(DebtPaymentIn instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'date': ?instance.date?.toIso8601String(),
      'concept': ?instance.concept,
    };
