// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale_part_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalePartOut _$SalePartOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate('SalePartOut', json, ($checkedConvert) {
      $checkKeys(
        json,
        requiredKeys: const [
          'asset_id',
          'name',
          'amount',
          'units',
          'cost',
          'gain',
        ],
      );
      final val = SalePartOut(
        assetId: $checkedConvert('asset_id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        amount: $checkedConvert('amount', (v) => v as String),
        units: $checkedConvert('units', (v) => v as String),
        cost: $checkedConvert('cost', (v) => v as String),
        gain: $checkedConvert('gain', (v) => v as String),
      );
      return val;
    }, fieldKeyMap: const {'assetId': 'asset_id'});

Map<String, dynamic> _$SalePartOutToJson(SalePartOut instance) =>
    <String, dynamic>{
      'asset_id': instance.assetId,
      'name': instance.name,
      'amount': instance.amount,
      'units': instance.units,
      'cost': instance.cost,
      'gain': instance.gain,
    };
