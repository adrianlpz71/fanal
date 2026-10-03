//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'asset_target_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetTargetOut {
  /// Returns a new [AssetTargetOut] instance.
  AssetTargetOut({

    required  this.assetId,

    required  this.target,

    required  this.validFrom,
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



  @JsonKey(
    
    name: r'valid_from',
    required: true,
    includeIfNull: false,
  )


  final DateTime validFrom;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetTargetOut &&
      other.assetId == assetId &&
      other.target == target &&
      other.validFrom == validFrom;

    @override
    int get hashCode =>
        assetId.hashCode +
        target.hashCode +
        validFrom.hashCode;

  factory AssetTargetOut.fromJson(Map<String, dynamic> json) => _$AssetTargetOutFromJson(json);

  Map<String, dynamic> toJson() => _$AssetTargetOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

