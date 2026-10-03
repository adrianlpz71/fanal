//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'macro_target_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MacroTargetIn {
  /// Returns a new [MacroTargetIn] instance.
  MacroTargetIn({

    required  this.assetClassId,

    required  this.target,

     this.min,

     this.max,

     this.tolerancePp,
  });

  @JsonKey(
    
    name: r'asset_class_id',
    required: true,
    includeIfNull: false,
  )


  final String assetClassId;



      /// Tanto por uno (0.9 = 90 %)
  @JsonKey(
    
    name: r'target',
    required: true,
    includeIfNull: false,
  )


  final String target;



  @JsonKey(
    
    name: r'min',
    required: false,
    includeIfNull: false,
  )


  final String? min;



  @JsonKey(
    
    name: r'max',
    required: false,
    includeIfNull: false,
  )


  final String? max;



  @JsonKey(
    
    name: r'tolerance_pp',
    required: false,
    includeIfNull: false,
  )


  final String? tolerancePp;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MacroTargetIn &&
      other.assetClassId == assetClassId &&
      other.target == target &&
      other.min == min &&
      other.max == max &&
      other.tolerancePp == tolerancePp;

    @override
    int get hashCode =>
        assetClassId.hashCode +
        target.hashCode +
        (min == null ? 0 : min.hashCode) +
        (max == null ? 0 : max.hashCode) +
        (tolerancePp == null ? 0 : tolerancePp.hashCode);

  factory MacroTargetIn.fromJson(Map<String, dynamic> json) => _$MacroTargetInFromJson(json);

  Map<String, dynamic> toJson() => _$MacroTargetInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

