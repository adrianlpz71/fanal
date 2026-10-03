// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'asset_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AssetOut _$AssetOutFromJson(Map<String, dynamic> json) => $checkedCreate(
  'AssetOut',
  json,
  ($checkedConvert) {
    $checkKeys(
      json,
      requiredKeys: const [
        'id',
        'name',
        'type',
        'asset_class_id',
        'platform_id',
        'isin',
        'ticker',
        'coingecko_id',
        'currency',
        'price_provider',
        'price_ref',
        'units_decimals',
        'sector',
        'country',
        'watchlist',
        'archived',
        'notes',
      ],
    );
    final val = AssetOut(
      id: $checkedConvert('id', (v) => v as String),
      name: $checkedConvert('name', (v) => v as String),
      type: $checkedConvert(
        'type',
        (v) => $enumDecode(_$AssetOutTypeEnumEnumMap, v),
      ),
      assetClassId: $checkedConvert('asset_class_id', (v) => v as String?),
      platformId: $checkedConvert('platform_id', (v) => v as String?),
      isin: $checkedConvert('isin', (v) => v as String?),
      ticker: $checkedConvert('ticker', (v) => v as String?),
      coingeckoId: $checkedConvert('coingecko_id', (v) => v as String?),
      currency: $checkedConvert('currency', (v) => v as String),
      priceProvider: $checkedConvert(
        'price_provider',
        (v) => $enumDecode(_$AssetOutPriceProviderEnumEnumMap, v),
      ),
      priceRef: $checkedConvert('price_ref', (v) => v as String?),
      unitsDecimals: $checkedConvert(
        'units_decimals',
        (v) => (v as num?)?.toInt(),
      ),
      sector: $checkedConvert('sector', (v) => v as String?),
      country: $checkedConvert('country', (v) => v as String?),
      watchlist: $checkedConvert('watchlist', (v) => v as bool),
      archived: $checkedConvert('archived', (v) => v as bool),
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

Map<String, dynamic> _$AssetOutToJson(AssetOut instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': _$AssetOutTypeEnumEnumMap[instance.type]!,
  'asset_class_id': instance.assetClassId,
  'platform_id': instance.platformId,
  'isin': instance.isin,
  'ticker': instance.ticker,
  'coingecko_id': instance.coingeckoId,
  'currency': instance.currency,
  'price_provider': _$AssetOutPriceProviderEnumEnumMap[instance.priceProvider]!,
  'price_ref': instance.priceRef,
  'units_decimals': instance.unitsDecimals,
  'sector': instance.sector,
  'country': instance.country,
  'watchlist': instance.watchlist,
  'archived': instance.archived,
  'notes': instance.notes,
};

const _$AssetOutTypeEnumEnumMap = {
  AssetOutTypeEnum.fondo: 'fondo',
  AssetOutTypeEnum.etf: 'etf',
  AssetOutTypeEnum.accion: 'accion',
  AssetOutTypeEnum.cripto: 'cripto',
  AssetOutTypeEnum.cuenta: 'cuenta',
  AssetOutTypeEnum.otro: 'otro',
};

const _$AssetOutPriceProviderEnumEnumMap = {
  AssetOutPriceProviderEnum.ft: 'ft',
  AssetOutPriceProviderEnum.coingecko: 'coingecko',
  AssetOutPriceProviderEnum.manual: 'manual',
};
