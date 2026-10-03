//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'macro_target_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MacroTargetOut {
  /// Returns a new [MacroTargetOut] instance.
  MacroTargetOut({

    required  this.assetClassId,

    required  this.target,

    required  this.min,

    required  this.max,

    required  this.tolerancePp,

    required  this.validFrom,
  });

  @JsonKey(
    
    name: r'asset_class_id',
    required: true,
    includeIfNull: false,
  )


  final String assetClassId;



  @JsonKey(
    
    name: r'target',
    required: true,
    includeIfNull: false,
  )


  final String target;



  @JsonKey(
    
    name: r'min',
    required: true,
    includeIfNull: true,
  )


  final String? min;



  @JsonKey(
    
    name: r'max',
    required: true,
    includeIfNull: true,
  )


  final String? max;



  @JsonKey(
    
    name: r'tolerance_pp',
    required: true,
    includeIfNull: true,
  )


  final String? tolerancePp;



  @JsonKey(
    
    name: r'valid_from',
    required: true,
    includeIfNull: false,
  )


  final DateTime validFrom;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MacroTargetOut &&
      other.assetClassId == assetClassId &&
      other.target == target &&
      other.min == min &&
      other.max == max &&
      other.tolerancePp == tolerancePp &&
      other.validFrom == validFrom;

    @override
    int get hashCode =>
        assetClassId.hashCode +
        target.hashCode +
        (min == null ? 0 : min.hashCode) +
        (max == null ? 0 : max.hashCode) +
        (tolerancePp == null ? 0 : tolerancePp.hashCode) +
        validFrom.hashCode;

  factory MacroTargetOut.fromJson(Map<String, dynamic> json) => _$MacroTargetOutFromJson(json);

  Map<String, dynamic> toJson() => _$MacroTargetOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

