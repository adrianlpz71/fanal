//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'asset_target_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetTargetIn {
  /// Returns a new [AssetTargetIn] instance.
  AssetTargetIn({

    required  this.assetId,

    required  this.target,
  });

  @JsonKey(
    
    name: r'asset_id',
    required: true,
    includeIfNull: false,
  )


  final String assetId;



  @JsonKey(
    
    name: r'target',
    required: true,
    includeIfNull: false,
  )


  final String target;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetTargetIn &&
      other.assetId == assetId &&
      other.target == target;

    @override
    int get hashCode =>
        assetId.hashCode +
        target.hashCode;

  factory AssetTargetIn.fromJson(Map<String, dynamic> json) => _$AssetTargetInFromJson(json);

  Map<String, dynamic> toJson() => _$AssetTargetInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

