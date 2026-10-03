//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'exposure_item_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ExposureItemOut {
  /// Returns a new [ExposureItemOut] instance.
  ExposureItemOut({

    required  this.key,

    required  this.weight,

    required  this.value,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'weight',
    required: true,
    includeIfNull: false,
  )


  final String weight;



  @JsonKey(
    
    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ExposureItemOut &&
      other.key == key &&
      other.weight == weight &&
      other.value == value;

    @override
    int get hashCode =>
        key.hashCode +
        weight.hashCode +
        value.hashCode;

  factory ExposureItemOut.fromJson(Map<String, dynamic> json) => _$ExposureItemOutFromJson(json);

  Map<String, dynamic> toJson() => _$ExposureItemOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

