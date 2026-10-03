//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'asset_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetOut {
  /// Returns a new [AssetOut] instance.
  AssetOut({

    required  this.id,

    required  this.name,

    required  this.type,

    required  this.assetClassId,

    required  this.platformId,

    required  this.isin,

    required  this.ticker,

    required  this.coingeckoId,

    required  this.currency,

    required  this.priceProvider,

    required  this.priceRef,

    required  this.unitsDecimals,

    required  this.sector,

    required  this.country,

    required  this.watchlist,

    required  this.archived,

    required  this.notes,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final AssetOutTypeEnum type;



  @JsonKey(
    
    name: r'asset_class_id',
    required: true,
    includeIfNull: true,
  )


  final String? assetClassId;



  @JsonKey(
    
    name: r'platform_id',
    required: true,
    includeIfNull: true,
  )


  final String? platformId;



  @JsonKey(
    
    name: r'isin',
    required: true,
    includeIfNull: true,
  )


  final String? isin;



  @JsonKey(
    
    name: r'ticker',
    required: true,
    includeIfNull: true,
  )


  final String? ticker;



  @JsonKey(
    
    name: r'coingecko_id',
    required: true,
    includeIfNull: true,
  )


  final String? coingeckoId;



  @JsonKey(
    
    name: r'currency',
    required: true,
    includeIfNull: false,
  )


  final String currency;



  @JsonKey(
    
    name: r'price_provider',
    required: true,
    includeIfNull: false,
  )


  final AssetOutPriceProviderEnum priceProvider;



  @JsonKey(
    
    name: r'price_ref',
    required: true,
    includeIfNull: true,
  )


  final String? priceRef;



  @JsonKey(
    
    name: r'units_decimals',
    required: true,
    includeIfNull: true,
  )


  final int? unitsDecimals;



  @JsonKey(
    
    name: r'sector',
    required: true,
    includeIfNull: true,
  )


  final String? sector;



  @JsonKey(
    
    name: r'country',
    required: true,
    includeIfNull: true,
  )


  final String? country;



  @JsonKey(
    
    name: r'watchlist',
    required: true,
    includeIfNull: false,
  )


  final bool watchlist;



  @JsonKey(
    
    name: r'archived',
    required: true,
    includeIfNull: false,
  )


  final bool archived;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: true,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetOut &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.assetClassId == assetClassId &&
      other.platformId == platformId &&
      other.isin == isin &&
      other.ticker == ticker &&
      other.coingeckoId == coingeckoId &&
      other.currency == currency &&
      other.priceProvider == priceProvider &&
      other.priceRef == priceRef &&
      other.unitsDecimals == unitsDecimals &&
      other.sector == sector &&
      other.country == country &&
      other.watchlist == watchlist &&
      other.archived == archived &&
      other.notes == notes;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        type.hashCode +
        (assetClassId == null ? 0 : assetClassId.hashCode) +
        (platformId == null ? 0 : platformId.hashCode) +
        (isin == null ? 0 : isin.hashCode) +
        (ticker == null ? 0 : ticker.hashCode) +
        (coingeckoId == null ? 0 : coingeckoId.hashCode) +
        currency.hashCode +
        priceProvider.hashCode +
        (priceRef == null ? 0 : priceRef.hashCode) +
        (unitsDecimals == null ? 0 : unitsDecimals.hashCode) +
        (sector == null ? 0 : sector.hashCode) +
        (country == null ? 0 : country.hashCode) +
        watchlist.hashCode +
        archived.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory AssetOut.fromJson(Map<String, dynamic> json) => _$AssetOutFromJson(json);

  Map<String, dynamic> toJson() => _$AssetOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssetOutTypeEnum {
@JsonValue(r'fondo')
fondo(r'fondo'),
@JsonValue(r'etf')
etf(r'etf'),
@JsonValue(r'accion')
accion(r'accion'),
@JsonValue(r'cripto')
cripto(r'cripto'),
@JsonValue(r'cuenta')
cuenta(r'cuenta'),
@JsonValue(r'otro')
otro(r'otro');

const AssetOutTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum AssetOutPriceProviderEnum {
@JsonValue(r'ft')
ft(r'ft'),
@JsonValue(r'coingecko')
coingecko(r'coingecko'),
@JsonValue(r'manual')
manual(r'manual');

const AssetOutPriceProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


