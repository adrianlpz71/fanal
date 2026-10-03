//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/macro_target_out.dart';
import 'package:faro_api/src/model/asset_target_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'targets_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TargetsOut {
  /// Returns a new [TargetsOut] instance.
  TargetsOut({

    required  this.macro,

    required  this.assets,
  });

  @JsonKey(
    
    name: r'macro',
    required: true,
    includeIfNull: false,
  )


  final List<MacroTargetOut> macro;



  @JsonKey(
    
    name: r'assets',
    required: true,
    includeIfNull: false,
  )


  final List<AssetTargetOut> assets;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TargetsOut &&
      other.macro == macro &&
      other.assets == assets;

    @override
    int get hashCode =>
        macro.hashCode +
        assets.hashCode;

  factory TargetsOut.fromJson(Map<String, dynamic> json) => _$TargetsOutFromJson(json);

  Map<String, dynamic> toJson() => _$TargetsOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

