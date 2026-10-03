// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tx_settle_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TxSettleIn _$TxSettleInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('TxSettleIn', json, ($checkedConvert) {
      final val = TxSettleIn(
        units: $checkedConvert('units', (v) => v as String?),
        price: $checkedConvert('price', (v) => v as String?),
        fee: $checkedConvert('fee', (v) => v as String?),
      );
      return val;
    });

Map<String, dynamic> _$TxSettleInToJson(TxSettleIn instance) =>
    <String, dynamic>{
      'units': ?instance.units,
      'price': ?instance.price,
      'fee': ?instance.fee,
    };
