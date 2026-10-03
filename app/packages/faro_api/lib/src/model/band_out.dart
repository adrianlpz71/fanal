//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'band_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BandOut {
  /// Returns a new [BandOut] instance.
  BandOut({

    required  this.age,

    required  this.p10,

    required  this.p50,

    required  this.p90,
  });

  @JsonKey(
    
    name: r'age',
    required: true,
    includeIfNull: false,
  )


  final int age;



  @JsonKey(
    
    name: r'p10',
    required: true,
    includeIfNull: false,
  )


  final String p10;



  @JsonKey(
    
    name: r'p50',
    required: true,
    includeIfNull: false,
  )


  final String p50;



  @JsonKey(
    
    name: r'p90',
    required: true,
    includeIfNull: false,
  )


  final String p90;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BandOut &&
      other.age == age &&
      other.p10 == p10 &&
      other.p50 == p50 &&
      other.p90 == p90;

    @override
    int get hashCode =>
        age.hashCode +
        p10.hashCode +
        p50.hashCode +
        p90.hashCode;

  factory BandOut.fromJson(Map<String, dynamic> json) => _$BandOutFromJson(json);

  Map<String, dynamic> toJson() => _$BandOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

