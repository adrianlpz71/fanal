//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'series_point_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SeriesPointOut {
  /// Returns a new [SeriesPointOut] instance.
  SeriesPointOut({

    required  this.date,

    required  this.value,

    required  this.contributed,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;



  @JsonKey(
    
    name: r'contributed',
    required: true,
    includeIfNull: false,
  )


  final String contributed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SeriesPointOut &&
      other.date == date &&
      other.value == value &&
      other.contributed == contributed;

    @override
    int get hashCode =>
        date.hashCode +
        value.hashCode +
        contributed.hashCode;

  factory SeriesPointOut.fromJson(Map<String, dynamic> json) => _$SeriesPointOutFromJson(json);

  Map<String, dynamic> toJson() => _$SeriesPointOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

