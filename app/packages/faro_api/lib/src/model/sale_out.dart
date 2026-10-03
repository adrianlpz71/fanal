//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sale_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SaleOut {
  /// Returns a new [SaleOut] instance.
  SaleOut({

    required  this.asset,

    required  this.date,

    required  this.units,

    required  this.proceeds,

    required  this.cost,

    required  this.gain,
  });

  @JsonKey(
    
    name: r'asset',
    required: true,
    includeIfNull: false,
  )


  final String asset;



  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'units',
    required: true,
    includeIfNull: false,
  )


  final String units;



  @JsonKey(
    
    name: r'proceeds',
    required: true,
    includeIfNull: false,
  )


  final String proceeds;



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
    bool operator ==(Object other) => identical(this, other) || other is SaleOut &&
      other.asset == asset &&
      other.date == date &&
      other.units == units &&
      other.proceeds == proceeds &&
      other.cost == cost &&
      other.gain == gain;

    @override
    int get hashCode =>
        asset.hashCode +
        date.hashCode +
        units.hashCode +
        proceeds.hashCode +
        cost.hashCode +
        gain.hashCode;

  factory SaleOut.fromJson(Map<String, dynamic> json) => _$SaleOutFromJson(json);

  Map<String, dynamic> toJson() => _$SaleOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

