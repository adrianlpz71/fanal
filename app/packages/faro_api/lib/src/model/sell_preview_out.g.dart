// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sell_preview_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellPreviewOut _$SellPreviewOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SellPreviewOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'amount',
          'gain',
          'tax',
          'net',
          'available',
          'parts',
        ],
      );
      final val = SellPreviewOut(
        amount: $checkedConvert('amount', (v) => v as String),
        gain: $checkedConvert('gain', (v) => v as String),
        tax: $checkedConvert('tax', (v) => v as String),
        net: $checkedConvert('net', (v) => v as String),
        available: $checkedConvert('available', (v) => v as String),
        parts: $checkedConvert(
          'parts',
          (v) => (v as List<dynamic>)
              .map((e) => SalePartOut.fromJson(e as Map<String, dynamic>))
              .toList(),
        ),
      );
      return val;
    });

Map<String, dynamic> _$SellPreviewOutToJson(SellPreviewOut instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'gain': instance.gain,
      'tax': instance.tax,
      'net': instance.net,
      'available': instance.available,
      'parts': instance.parts.map((e) => e.toJson()).toList(),
    };
