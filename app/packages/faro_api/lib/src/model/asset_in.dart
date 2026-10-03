//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'asset_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetIn {
  /// Returns a new [AssetIn] instance.
  AssetIn({

     this.id,

    required  this.name,

    required  this.type,

     this.assetClassId,

     this.platformId,

     this.isin,

     this.ticker,

     this.coingeckoId,

     this.currency = 'EUR',

     this.priceProvider,

     this.priceRef,

     this.unitsDecimals,

     this.sector,

     this.country,

     this.watchlist = false,

     this.notes,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



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


  final AssetInTypeEnum type;



  @JsonKey(
    
    name: r'asset_class_id',
    required: false,
    includeIfNull: false,
  )


  final String? assetClassId;



  @JsonKey(
    
    name: r'platform_id',
    required: false,
    includeIfNull: false,
  )


  final String? platformId;



  @JsonKey(
    
    name: r'isin',
    required: false,
    includeIfNull: false,
  )


  final String? isin;



  @JsonKey(
    
    name: r'ticker',
    required: false,
    includeIfNull: false,
  )


  final String? ticker;



  @JsonKey(
    
    name: r'coingecko_id',
    required: false,
    includeIfNull: false,
  )


  final String? coingeckoId;



  @JsonKey(
    defaultValue: 'EUR',
    name: r'currency',
    required: false,
    includeIfNull: false,
  )


  final String? currency;



  @JsonKey(
    
    name: r'price_provider',
    required: false,
    includeIfNull: false,
  )


  final AssetInPriceProviderEnum? priceProvider;



  @JsonKey(
    
    name: r'price_ref',
    required: false,
    includeIfNull: false,
  )


  final String? priceRef;



          // minimum: 0
          // maximum: 10
  @JsonKey(
    
    name: r'units_decimals',
    required: false,
    includeIfNull: false,
  )


  final int? unitsDecimals;



  @JsonKey(
    
    name: r'sector',
    required: false,
    includeIfNull: false,
  )


  final String? sector;



  @JsonKey(
    
    name: r'country',
    required: false,
    includeIfNull: false,
  )


  final String? country;



  @JsonKey(
    defaultValue: false,
    name: r'watchlist',
    required: false,
    includeIfNull: false,
  )


  final bool? watchlist;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetIn &&
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
      other.notes == notes;

    @override
    int get hashCode =>
        (id == null ? 0 : id.hashCode) +
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
        (notes == null ? 0 : notes.hashCode);

  factory AssetIn.fromJson(Map<String, dynamic> json) => _$AssetInFromJson(json);

  Map<String, dynamic> toJson() => _$AssetInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssetInTypeEnum {
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

const AssetInTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum AssetInPriceProviderEnum {
@JsonValue(r'ft')
ft(r'ft'),
@JsonValue(r'coingecko')
coingecko(r'coingecko'),
@JsonValue(r'manual')
manual(r'manual');

const AssetInPriceProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


