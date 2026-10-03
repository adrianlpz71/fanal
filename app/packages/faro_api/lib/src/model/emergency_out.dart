//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'emergency_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class EmergencyOut {
  /// Returns a new [EmergencyOut] instance.
  EmergencyOut({

    required  this.target,

    required  this.current,

    required  this.coverage,

    required  this.missing,

    required  this.suggestedMonthly,
  });

  @JsonKey(
    
    name: r'target',
    required: true,
    includeIfNull: false,
  )


  final String target;



  @JsonKey(
    
    name: r'current',
    required: true,
    includeIfNull: false,
  )


  final String current;



  @JsonKey(
    
    name: r'coverage',
    required: true,
    includeIfNull: false,
  )


  final String coverage;



  @JsonKey(
    
    name: r'missing',
    required: true,
    includeIfNull: false,
  )


  final String missing;



  @JsonKey(
    
    name: r'suggested_monthly',
    required: true,
    includeIfNull: false,
  )


  final String suggestedMonthly;





    @override
    bool operator ==(Object other) => identical(this, other) || other is EmergencyOut &&
      other.target == target &&
      other.current == current &&
      other.coverage == coverage &&
      other.missing == missing &&
      other.suggestedMonthly == suggestedMonthly;

    @override
    int get hashCode =>
        target.hashCode +
        current.hashCode +
        coverage.hashCode +
        missing.hashCode +
        suggestedMonthly.hashCode;

  factory EmergencyOut.fromJson(Map<String, dynamic> json) => _$EmergencyOutFromJson(json);

  Map<String, dynamic> toJson() => _$EmergencyOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

