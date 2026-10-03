// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'price_refresh_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PriceRefreshOut _$PriceRefreshOutFromJson(Map<String, dynamic> json) =>
    $checkedCreate(
      'PriceRefreshOut',
      json,
      ($checkedConvert) {
        $checkKeys(
          json,
          requiredKeys: const [
            'asset_id',
            'asset_name',
            'ok',
            'price',
            'date',
            'source',
            'errors',
          ],
        );
        final val = PriceRefreshOut(
          assetId: $checkedConvert('asset_id', (v) => v as String),
          assetName: $checkedConvert('asset_name', (v) => v as String),
          ok: $checkedConvert('ok', (v) => v as bool),
          price: $checkedConvert('price', (v) => v as String?),
          date: $checkedConvert(
            'date',
            (v) => v == null ? null : DateTime.parse(v as String),
          ),
          source_: $checkedConvert('source', (v) => v as String?),
          errors: $checkedConvert(
            'errors',
            (v) => (v as List<dynamic>).map((e) => e as String).toList(),
          ),
        );
        return val;
      },
      fieldKeyMap: const {
        'assetId': 'asset_id',
        'assetName': 'asset_name',
        'source_': 'source',
      },
    );

Map<String, dynamic> _$PriceRefreshOutToJson(PriceRefreshOut instance) =>
    <String, dynamic>{
      'asset_id': instance.assetId,
      'asset_name': instance.assetName,
      'ok': instance.ok,
      'price': instance.price,
      'date': instance.date?.toIso8601String(),
      'source': instance.source_,
      'errors': instance.errors,
    };
