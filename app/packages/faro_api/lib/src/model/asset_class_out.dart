//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'asset_class_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetClassOut {
  /// Returns a new [AssetClassOut] instance.
  AssetClassOut({

    required  this.id,

    required  this.name,

    required  this.defaultTolerancePp,

    required  this.sort,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'default_tolerance_pp',
    required: true,
    includeIfNull: false,
  )


  final String defaultTolerancePp;



  @JsonKey(
    
    name: r'sort',
    required: true,
    includeIfNull: false,
  )


  final int sort;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetClassOut &&
      other.id == id &&
      other.name == name &&
      other.defaultTolerancePp == defaultTolerancePp &&
      other.sort == sort;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        defaultTolerancePp.hashCode +
        sort.hashCode;

  factory AssetClassOut.fromJson(Map<String, dynamic> json) => _$AssetClassOutFromJson(json);

  Map<String, dynamic> toJson() => _$AssetClassOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

