// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetPatch _$AssetPatchFromJson(Map<String, dynamic> json) => $checkedCreate(
  'AssetPatch',
  json,
  ($checkedConvert) {
    final val = AssetPatch(
      name: $checkedConvert('name', (v) => v as String?),
      assetClassId: $checkedConvert('asset_class_id', (v) => v as String?),
      platformId: $checkedConvert('platform_id', (v) => v as String?),
      isin: $checkedConvert('isin', (v) => v as String?),
      ticker: $checkedConvert('ticker', (v) => v as String?),
      coingeckoId: $checkedConvert('coingecko_id', (v) => v as String?),
      priceProvider: $checkedConvert(
        'price_provider',
        (v) => $enumDecodeNullable(_$AssetPatchPriceProviderEnumEnumMap, v),
      ),
      priceRef: $checkedConvert('price_ref', (v) => v as String?),
      unitsDecimals: $checkedConvert(
        'units_decimals',
        (v) => (v as num?)?.toInt(),
      ),
      sector: $checkedConvert('sector', (v) => v as String?),
      country: $checkedConvert('country', (v) => v as String?),
      watchlist: $checkedConvert('watchlist', (v) => v as bool?),
      archived: $checkedConvert('archived', (v) => v as bool?),
      notes: $checkedConvert('notes', (v) => v as String?),
    );
    return val;
  },
  fieldKeyMap: const {
    'assetClassId': 'asset_class_id',
    'platformId': 'platform_id',
    'coingeckoId': 'coingecko_id',
    'priceProvider': 'price_provider',
    'priceRef': 'price_ref',
    'unitsDecimals': 'units_decimals',
  },
);

Map<String, dynamic> _$AssetPatchToJson(AssetPatch instance) =>
    <String, dynamic>{
      'name': ?instance.name,
      'asset_class_id': ?instance.assetClassId,
      'platform_id': ?instance.platformId,
      'isin': ?instance.isin,
      'ticker': ?instance.ticker,
      'coingecko_id': ?instance.coingeckoId,
      'price_provider':
          ?_$AssetPatchPriceProviderEnumEnumMap[instance.priceProvider],
      'price_ref': ?instance.priceRef,
      'units_decimals': ?instance.unitsDecimals,
      'sector': ?instance.sector,
      'country': ?instance.country,
      'watchlist': ?instance.watchlist,
      'archived': ?instance.archived,
      'notes': ?instance.notes,
    };

const _$AssetPatchPriceProviderEnumEnumMap = {
  AssetPatchPriceProviderEnum.ft: 'ft',
  AssetPatchPriceProviderEnum.coingecko: 'coingecko',
  AssetPatchPriceProviderEnum.manual: 'manual',
};
