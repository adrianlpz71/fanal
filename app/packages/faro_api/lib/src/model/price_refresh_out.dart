//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'price_refresh_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PriceRefreshOut {
  /// Returns a new [PriceRefreshOut] instance.
  PriceRefreshOut({

    required  this.assetId,

    required  this.assetName,

    required  this.ok,

    required  this.price,

    required  this.date,

    required  this.source_,

    required  this.errors,
  });

  @JsonKey(
    
    name: r'asset_id',
    required: true,
    includeIfNull: false,
  )


  final String assetId;



  @JsonKey(
    
    name: r'asset_name',
    required: true,
    includeIfNull: false,
  )


  final String assetName;



  @JsonKey(
    
    name: r'ok',
    required: true,
    includeIfNull: false,
  )


  final bool ok;



  @JsonKey(
    
    name: r'price',
    required: true,
    includeIfNull: true,
  )


  final String? price;



  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? date;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: true,
  )


  final String? source_;



  @JsonKey(
    
    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final List<String> errors;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PriceRefreshOut &&
      other.assetId == assetId &&
      other.assetName == assetName &&
      other.ok == ok &&
      other.price == price &&
      other.date == date &&
      other.source_ == source_ &&
      other.errors == errors;

    @override
    int get hashCode =>
        assetId.hashCode +
        assetName.hashCode +
        ok.hashCode +
        (price == null ? 0 : price.hashCode) +
        (date == null ? 0 : date.hashCode) +
        (source_ == null ? 0 : source_.hashCode) +
        errors.hashCode;

  factory PriceRefreshOut.fromJson(Map<String, dynamic> json) => _$PriceRefreshOutFromJson(json);

  Map<String, dynamic> toJson() => _$PriceRefreshOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

