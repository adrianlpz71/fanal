// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_change_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceChangeOut _$PriceChangeOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PriceChangeOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const ['id', 'old_amount', 'new_amount', 'detected_at'],
        );
        final val = PriceChangeOut(
          id: $checkedConvert('id', (v) => v as String),
          oldAmount: $checkedConvert('old_amount', (v) => v as String),
          newAmount: $checkedConvert('new_amount', (v) => v as String),
          detectedAt: $checkedConvert('detected_at', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'oldAmount': 'old_amount',
        'newAmount': 'new_amount',
        'detectedAt': 'detected_at',
      },
    );

Map<String, dynamic> _$PriceChangeOutToJson(PriceChangeOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'old_amount': instance.oldAmount,
      'new_amount': instance.newAmount,
      'detected_at': instance.detectedAt,
    };
