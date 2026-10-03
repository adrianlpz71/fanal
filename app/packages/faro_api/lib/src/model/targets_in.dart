//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/asset_target_in.dart';
import 'package:faro_api/src/model/macro_target_in.dart';
import 'package:json_annotation/json_annotation.dart';

part 'targets_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TargetsIn {
  /// Returns a new [TargetsIn] instance.
  TargetsIn({

     this.macro,

     this.assets,

     this.validFrom,
  });

  @JsonKey(
    
    name: r'macro',
    required: false,
    includeIfNull: false,
  )


  final List<MacroTargetIn>? macro;



  @JsonKey(
    
    name: r'assets',
    required: false,
    includeIfNull: false,
  )


  final List<AssetTargetIn>? assets;



  @JsonKey(
    
    name: r'valid_from',
    required: false,
    includeIfNull: false,
  )


  final DateTime? validFrom;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TargetsIn &&
      other.macro == macro &&
      other.assets == assets &&
      other.validFrom == validFrom;

    @override
    int get hashCode =>
        macro.hashCode +
        assets.hashCode +
        (validFrom == null ? 0 : validFrom.hashCode);

  factory TargetsIn.fromJson(Map<String, dynamic> json) => _$TargetsInFromJson(json);

  Map<String, dynamic> toJson() => _$TargetsInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

