// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bank_line_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BankLineOut _$BankLineOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'BankLineOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'row',
        'date',
        'concept',
        'amount',
        'balance',
        'outcome',
        'movement_id',
        'category_id',
      ],
    );
    final val = BankLineOut(
      row: $checkedConvert('row', (v) => (v as num).toInt()),
      date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
      concept: $checkedConvert('concept', (v) => v as String),
      amount: $checkedConvert('amount', (v) => v as String),
      balance: $checkedConvert('balance', (v) => v as String?),
      outcome: $checkedConvert('outcome', (v) => v as String),
      movementId: $checkedConvert('movement_id', (v) => v as String?),
      categoryId: $checkedConvert('category_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {'movementId': 'movement_id', 'categoryId': 'category_id'},
);

Map<String, dynamic> _$BankLineOutToJson(BankLineOut instance) =>
    <String, dynamic>{
      'row': instance.row,
      'date': instance.date.toIso8601String(),
      'concept': instance.concept,
      'amount': instance.amount,
      'balance': instance.balance,
      'outcome': instance.outcome,
      'movement_id': instance.movementId,
      'category_id': instance.categoryId,
    };
