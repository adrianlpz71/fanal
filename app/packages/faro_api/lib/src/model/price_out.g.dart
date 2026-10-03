// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceOut _$PriceOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PriceOut', json, ($checkedConvert) {
      $checkKeys(json, requiredKeys: const ['date', 'price', 'source']);
      final val = PriceOut(
        date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
        price: $checkedConvert('price', (v) => v as String),
        source_: $checkedConvert('source', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'source_': 'source'});

Map<String, dynamic> _$PriceOutToJson(PriceOut instance) => <String, dynamic>{
  'date': instance.date.toIso8601String(),
  'price': instance.price,
  'source': instance.source_,
};
