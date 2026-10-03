//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/platform_op_out.dart';
import 'package:faro_api/src/model/platform_position_out.dart';
import 'package:faro_api/src/model/new_asset_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'platform_preview_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformPreviewOut {
  /// Returns a new [PlatformPreviewOut] instance.
  PlatformPreviewOut({

    required  this.source_,

    required  this.platform,

    required  this.counts,

    required  this.warnings,

    required  this.ops,

    required  this.createAssets,

    required  this.positions,
  });

  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final PlatformPreviewOutSource_Enum source_;



  @JsonKey(
    
    name: r'platform',
    required: true,
    includeIfNull: false,
  )


  final String platform;



  @JsonKey(
    
    name: r'counts',
    required: true,
    includeIfNull: false,
  )


  final Map<String, int> counts;



  @JsonKey(
    
    name: r'warnings',
    required: true,
    includeIfNull: false,
  )


  final List<String> warnings;



  @JsonKey(
    
    name: r'ops',
    required: true,
    includeIfNull: false,
  )


  final List<PlatformOpOut> ops;



  @JsonKey(
    
    name: r'create_assets',
    required: true,
    includeIfNull: false,
  )


  final List<NewAssetOut> createAssets;



  @JsonKey(
    
    name: r'positions',
    required: true,
    includeIfNull: false,
  )


  final List<PlatformPositionOut> positions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformPreviewOut &&
      other.source_ == source_ &&
      other.platform == platform &&
      other.counts == counts &&
      other.warnings == warnings &&
      other.ops == ops &&
      other.createAssets == createAssets &&
      other.positions == positions;

    @override
    int get hashCode =>
        source_.hashCode +
        platform.hashCode +
        counts.hashCode +
        warnings.hashCode +
        ops.hashCode +
        createAssets.hashCode +
        positions.hashCode;

  factory PlatformPreviewOut.fromJson(Map<String, dynamic> json) => _$PlatformPreviewOutFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformPreviewOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PlatformPreviewOutSource_Enum {
@JsonValue(r'myinvestor')
myinvestor(r'myinvestor'),
@JsonValue(r'neverless')
neverless(r'neverless'),
@JsonValue(r'generic')
generic(r'generic');

const PlatformPreviewOutSource_Enum(this.value);

final String value;

@override
String toString() => value;
}


