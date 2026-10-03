// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceIn _$PriceInFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PriceIn', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'price']);
      final val = PriceIn(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        price: $checkedConvert('price', (v) => v as String),
      );
      return val;
    });

Map<String, dynamic> _$PriceInToJson(PriceIn instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'price': instance.price,
};
