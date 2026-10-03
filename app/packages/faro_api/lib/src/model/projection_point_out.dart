//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'projection_point_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProjectionPointOut {
  /// Returns a new [ProjectionPointOut] instance.
  ProjectionPointOut({

    required  this.age,

    required  this.pessimistic,

    required  this.base_,

    required  this.optimistic,
  });

  @JsonKey(
    
    name: r'age',
    required: true,
    includeIfNull: false,
  )


  final String age;



  @JsonKey(
    
    name: r'pessimistic',
    required: true,
    includeIfNull: false,
  )


  final String pessimistic;



  @JsonKey(
    
    name: r'base',
    required: true,
    includeIfNull: false,
  )


  final String base_;



  @JsonKey(
    
    name: r'optimistic',
    required: true,
    includeIfNull: false,
  )


  final String optimistic;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProjectionPointOut &&
      other.age == age &&
      other.pessimistic == pessimistic &&
      other.base_ == base_ &&
      other.optimistic == optimistic;

    @override
    int get hashCode =>
        age.hashCode +
        pessimistic.hashCode +
        base_.hashCode +
        optimistic.hashCode;

  factory ProjectionPointOut.fromJson(Map<String, dynamic> json) => _$ProjectionPointOutFromJson(json);

  Map<String, dynamic> toJson() => _$ProjectionPointOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

