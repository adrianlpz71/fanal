// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_amount_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassAmountOut _$ClassAmountOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('ClassAmountOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['asset_class_id', 'amount']);
      final val = ClassAmountOut(
        assetClassId: $checkedConvert('asset_class_id', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'assetClassId': 'asset_class_id'});

Map<String, dynamic> _$ClassAmountOutToJson(ClassAmountOut instance) =>
    <String, dynamic>{
      'asset_class_id': instance.assetClassId,
      'amount': instance.amount,
    };
