//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'lot_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LotOut {
  /// Returns a new [LotOut] instance.
  LotOut({

    required  this.acquired,

    required  this.units,

    required  this.cost,
  });

  @JsonKey(
    
    name: r'acquired',
    required: true,
    includeIfNull: false,
  )


  final DateTime acquired;



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





    @override
    bool operator ==(Object other) => identical(this, other) || other is LotOut &&
      other.acquired == acquired &&
      other.units == units &&
      other.cost == cost;

    @override
    int get hashCode =>
        acquired.hashCode +
        units.hashCode +
        cost.hashCode;

  factory LotOut.fromJson(Map<String, dynamic> json) => _$LotOutFromJson(json);

  Map<String, dynamic> toJson() => _$LotOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

