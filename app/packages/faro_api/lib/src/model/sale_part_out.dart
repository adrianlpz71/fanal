//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sale_part_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SalePartOut {
  /// Returns a new [SalePartOut] instance.
  SalePartOut({

    required  this.assetId,

    required  this.name,

    required  this.amount,

    required  this.units,

    required  this.cost,

    required  this.gain,
  });

  @JsonKey(
    
    name: r'asset_id',
    required: true,
    includeIfNull: false,
  )


  final String assetId;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'units',
    required: true,
    includeIfNull: false,
  )


  final String units;



  @JsonKey(
    
    name: r'cost',
    required: true,
    includeIfNull: false,
  )


  final String cost;



  @JsonKey(
    
    name: r'gain',
    required: true,
    includeIfNull: false,
  )


  final String gain;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SalePartOut &&
      other.assetId == assetId &&
      other.name == name &&
      other.amount == amount &&
      other.units == units &&
      other.cost == cost &&
      other.gain == gain;

    @override
    int get hashCode =>
        assetId.hashCode +
        name.hashCode +
        amount.hashCode +
        units.hashCode +
        cost.hashCode +
        gain.hashCode;

  factory SalePartOut.fromJson(Map<String, dynamic> json) => _$SalePartOutFromJson(json);

  Map<String, dynamic> toJson() => _$SalePartOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

