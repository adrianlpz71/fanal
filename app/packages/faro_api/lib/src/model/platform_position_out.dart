//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'platform_position_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformPositionOut {
  /// Returns a new [PlatformPositionOut] instance.
  PlatformPositionOut({

    required  this.key,

    required  this.name,

    required  this.unitsNow,

    required  this.unitsAfter,

    required  this.avgCostAfter,

    required  this.replacedInitial,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'units_now',
    required: true,
    includeIfNull: false,
  )


  final String unitsNow;



  @JsonKey(
    
    name: r'units_after',
    required: true,
    includeIfNull: false,
  )


  final String unitsAfter;



  @JsonKey(
    
    name: r'avg_cost_after',
    required: true,
    includeIfNull: false,
  )


  final String avgCostAfter;



  @JsonKey(
    
    name: r'replaced_initial',
    required: true,
    includeIfNull: false,
  )


  final bool replacedInitial;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformPositionOut &&
      other.key == key &&
      other.name == name &&
      other.unitsNow == unitsNow &&
      other.unitsAfter == unitsAfter &&
      other.avgCostAfter == avgCostAfter &&
      other.replacedInitial == replacedInitial;

    @override
    int get hashCode =>
        key.hashCode +
        name.hashCode +
        unitsNow.hashCode +
        unitsAfter.hashCode +
        avgCostAfter.hashCode +
        replacedInitial.hashCode;

  factory PlatformPositionOut.fromJson(Map<String, dynamic> json) => _$PlatformPositionOutFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformPositionOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

