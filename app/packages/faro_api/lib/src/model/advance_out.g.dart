// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'advance_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdvanceOut _$AdvanceOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('AdvanceOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['moved', 'amount']);
      final val = AdvanceOut(
        moved: $checkedConvert('moved', (v) => (v as num).toInt()),
        amount: $checkedConvert('amount', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$AdvanceOutToJson(AdvanceOut instance) =>
    <String, dynamic>{'moved': instance.moved, 'amount': instance.amount};
