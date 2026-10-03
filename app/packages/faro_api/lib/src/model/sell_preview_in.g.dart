// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sell_preview_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SellPreviewIn _$SellPreviewInFromJson(
  Map<String, dynamic> json,
) => $checkedCreate(
  'SellPreviewIn',
  json,
  ($checkedConvert) {
    $checkKeys(json, requiredKeys: const ['amount']);
    final val = SellPreviewIn(
      amount: $checkedConvert('amount', (v) => v as String),
      assetId: $checkedConvert('asset_id', (v) => v as String?),
      baseGeneral: $checkedConvert('base_general', (v) => v as String? ?? '0'),
      baseSavings: $checkedConvert('base_savings', (v) => v as String? ?? '0'),
    );
    return val;
  },
  fieldKeyMap: const {
    'assetId': 'asset_id',
    'baseGeneral': 'base_general',
    'baseSavings': 'base_savings',
  },
);

Map<String, dynamic> _$SellPreviewInToJson(SellPreviewIn instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'asset_id': ?instance.assetId,
      'base_general': ?instance.baseGeneral,
      'base_savings': ?instance.baseSavings,
    };
