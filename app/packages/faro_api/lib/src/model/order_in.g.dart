// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderIn _$OrderInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('OrderIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['asset_id', 'amount']);
      final val = OrderIn(
        assetId: $checkedConvert('asset_id', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'assetId': 'asset_id'});

Map<String, dynamic> _$OrderInToJson(OrderIn instance) => <String, dynamic>{
  'asset_id': instance.assetId,
  'amount': instance.amount,
};
