//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'asset_exposure_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetExposureIn {
  /// Returns a new [AssetExposureIn] instance.
  AssetExposureIn({

    required  this.dimension,

    required  this.key,

    required  this.weight,
  });

  @JsonKey(
    
    name: r'dimension',
    required: true,
    includeIfNull: false,
  )


  final AssetExposureInDimensionEnum dimension;



  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



      /// Tanto por uno
  @JsonKey(
    
    name: r'weight',
    required: true,
    includeIfNull: false,
  )


  final String weight;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetExposureIn &&
      other.dimension == dimension &&
      other.key == key &&
      other.weight == weight;

    @override
    int get hashCode =>
        dimension.hashCode +
        key.hashCode +
        weight.hashCode;

  factory AssetExposureIn.fromJson(Map<String, dynamic> json) => _$AssetExposureInFromJson(json);

  Map<String, dynamic> toJson() => _$AssetExposureInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AssetExposureInDimensionEnum {
@JsonValue(r'sector')
sector(r'sector'),
@JsonValue(r'region')
region(r'region'),
@JsonValue(r'pais')
pais(r'pais');

const AssetExposureInDimensionEnum(this.value);

final String value;

@override
String toString() => value;
}


