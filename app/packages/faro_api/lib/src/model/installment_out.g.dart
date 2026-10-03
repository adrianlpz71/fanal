// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'installment_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InstallmentOut _$InstallmentOutFromJson(
  Map<String, dynamic> json,
) => $checkedCreate('InstallmentOut', json, ($checkedConvert) {
  $checkKeys(
    json,
    requiredKeys: const ['seq', 'due_date', 'amount', 'status', 'movement_id'],
  );
  final val = InstallmentOut(
    seq: $checkedConvert('seq', (v) => (v as num).toInt()),
    dueDate: $checkedConvert('due_date', (v) => DateTime.parse(v as String)),
    amount: $checkedConvert('amount', (v) => v as String),
    status: $checkedConvert('status', (v) => v as String),
    movementId: $checkedConvert('movement_id', (v) => v as String?),
  );
  return val;
}, fieldKeyMap: const {'dueDate': 'due_date', 'movementId': 'movement_id'});

Map<String, dynamic> _$InstallmentOutToJson(InstallmentOut instance) =>
    <String, dynamic>{
      'seq': instance.seq,
      'due_date': instance.dueDate.toIso8601String(),
      'amount': instance.amount,
      'status': instance.status,
      'movement_id': instance.movementId,
    };
