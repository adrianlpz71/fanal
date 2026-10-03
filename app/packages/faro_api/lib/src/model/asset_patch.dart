//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'asset_patch.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetPatch {
  /// Returns a new [AssetPatch] instance.
  AssetPatch({

     this.name,

     this.assetClassId,

     this.platformId,

     this.isin,

     this.ticker,

     this.coingeckoId,

     this.priceProvider,

     this.priceRef,

     this.unitsDecimals,

     this.sector,

     this.country,

     this.watchlist,

     this.archived,

     this.notes,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



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
    
    name: r'price_provider',
    required: false,
    includeIfNull: false,
  )


  final AssetPatchPriceProviderEnum? priceProvider;



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
    
    name: r'watchlist',
    required: false,
    includeIfNull: false,
  )


  final bool? watchlist;



  @JsonKey(
    
    name: r'archived',
    required: false,
    includeIfNull: false,
  )


  final bool? archived;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetPatch &&
      other.name == name &&
      other.assetClassId == assetClassId &&
      other.platformId == platformId &&
      other.isin == isin &&
      other.ticker == ticker &&
      other.coingeckoId == coingeckoId &&
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
        (name == null ? 0 : name.hashCode) +
        (assetClassId == null ? 0 : assetClassId.hashCode) +
        (platformId == null ? 0 : platformId.hashCode) +
        (isin == null ? 0 : isin.hashCode) +
        (ticker == null ? 0 : ticker.hashCode) +
        (coingeckoId == null ? 0 : coingeckoId.hashCode) +
        (priceProvider == null ? 0 : priceProvider.hashCode) +
        (priceRef == null ? 0 : priceRef.hashCode) +
        (unitsDecimals == null ? 0 : unitsDecimals.hashCode) +
        (sector == null ? 0 : sector.hashCode) +
        (country == null ? 0 : country.hashCode) +
        (watchlist == null ? 0 : watchlist.hashCode) +
        (archived == null ? 0 : archived.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory AssetPatch.fromJson(Map<String, dynamic> json) => _$AssetPatchFromJson(json);

  Map<String, dynamic> toJson() => _$AssetPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssetPatchPriceProviderEnum {
@JsonValue(r'ft')
ft(r'ft'),
@JsonValue(r'coingecko')
coingecko(r'coingecko'),
@JsonValue(r'manual')
manual(r'manual');

const AssetPatchPriceProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


