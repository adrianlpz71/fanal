// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transfer_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferIn _$TransferInFromJson(Map<String, dynamic> json) => $checkedCreate(
  'TransferIn',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'from_asset_id',
        'to_asset_id',
        'trade_date',
        'units_out',
        'units_in',
        'amount_eur',
      ],
    );
    final val = TransferIn(
      fromAssetId: $checkedConvert('from_asset_id', (v) => v as String),
      toAssetId: $checkedConvert('to_asset_id', (v) => v as String),
      tradeDate: $checkedConvert(
        'trade_date',
        (v) => DateTime.parse(v as String),
      ),
      unitsOut: $checkedConvert('units_out', (v) => v as String),
      unitsIn: $checkedConvert('units_in', (v) => v as String),
      amountEur: $checkedConvert('amount_eur', (v) => v as String),
    );
    return val;
  },
  fieldKeyMap: const {
    'fromAssetId': 'from_asset_id',
    'toAssetId': 'to_asset_id',
    'tradeDate': 'trade_date',
    'unitsOut': 'units_out',
    'unitsIn': 'units_in',
    'amountEur': 'amount_eur',
  },
);

Map<String, dynamic> _$TransferInToJson(TransferIn instance) =>
    <String, dynamic>{
      'from_asset_id': instance.fromAssetId,
      'to_asset_id': instance.toAssetId,
      'trade_date': instance.tradeDate.toIso8601String(),
      'units_out': instance.unitsOut,
      'units_in': instance.unitsIn,
      'amount_eur': instance.amountEur,
    };
