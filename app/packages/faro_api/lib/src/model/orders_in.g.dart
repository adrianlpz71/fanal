// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrdersIn _$OrdersInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'OrdersIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['orders', 'trade_date']);
    final val = OrdersIn(
      orders: $checkedConvert(
        'orders',
        (v) => (v as List<dynamic>)
            .map((e) => OrderIn.fromJson(e as Map<String, dynamic>))
            .toList(),
      ),
      tradeDate: $checkedConvert(
        'trade_date',
        (v) => DateTime.parse(v as String),
      ),
      fromAccountId: $checkedConvert('from_account_id', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'tradeDate': 'trade_date',
    'fromAccountId': 'from_account_id',
  },
);

Map<String, dynamic> _$OrdersInToJson(OrdersIn instance) => <String, dynamic>{
  'orders': instance.orders.map((e) => e.toJson()).toList(),
  'trade_date': instance.tradeDate.toIso8601String(),
  'from_account_id': ?instance.fromAccountId,
};
