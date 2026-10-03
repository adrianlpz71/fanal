//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'order_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class OrderOut {
  /// Returns a new [OrderOut] instance.
  OrderOut({

    required  this.assetId,

    required  this.assetName,

    required  this.amount,

    required  this.price,

    required  this.approxUnits,
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
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'price',
    required: true,
    includeIfNull: true,
  )


  final String? price;



  @JsonKey(
    
    name: r'approx_units',
    required: true,
    includeIfNull: true,
  )


  final String? approxUnits;





    @override
    bool operator ==(Object other) => identical(this, other) || other is OrderOut &&
      other.assetId == assetId &&
      other.assetName == assetName &&
      other.amount == amount &&
      other.price == price &&
      other.approxUnits == approxUnits;

    @override
    int get hashCode =>
        assetId.hashCode +
        assetName.hashCode +
        amount.hashCode +
        (price == null ? 0 : price.hashCode) +
        (approxUnits == null ? 0 : approxUnits.hashCode);

  factory OrderOut.fromJson(Map<String, dynamic> json) => _$OrderOutFromJson(json);

  Map<String, dynamic> toJson() => _$OrderOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

