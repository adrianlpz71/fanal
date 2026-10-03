//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'asset_exposure_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetExposureOut {
  /// Returns a new [AssetExposureOut] instance.
  AssetExposureOut({

    required  this.dimension,

    required  this.key,

    required  this.weight,

    required  this.source_,

    required  this.asOf,
  });

  @JsonKey(
    
    name: r'dimension',
    required: true,
    includeIfNull: false,
  )


  final String dimension;



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
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;



  @JsonKey(
    
    name: r'as_of',
    required: true,
    includeIfNull: true,
  )


  final DateTime? asOf;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetExposureOut &&
      other.dimension == dimension &&
      other.key == key &&
      other.weight == weight &&
      other.source_ == source_ &&
      other.asOf == asOf;

    @override
    int get hashCode =>
        dimension.hashCode +
        key.hashCode +
        weight.hashCode +
        source_.hashCode +
        (asOf == null ? 0 : asOf.hashCode);

  factory AssetExposureOut.fromJson(Map<String, dynamic> json) => _$AssetExposureOutFromJson(json);

  Map<String, dynamic> toJson() => _$AssetExposureOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

