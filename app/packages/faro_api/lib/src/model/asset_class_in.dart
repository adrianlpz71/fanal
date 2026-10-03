//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'asset_class_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetClassIn {
  /// Returns a new [AssetClassIn] instance.
  AssetClassIn({

    required  this.name,

     this.defaultTolerancePp = '1',
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    defaultValue: '1',
    name: r'default_tolerance_pp',
    required: false,
    includeIfNull: false,
  )


  final String? defaultTolerancePp;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetClassIn &&
      other.name == name &&
      other.defaultTolerancePp == defaultTolerancePp;

    @override
    int get hashCode =>
        name.hashCode +
        defaultTolerancePp.hashCode;

  factory AssetClassIn.fromJson(Map<String, dynamic> json) => _$AssetClassInFromJson(json);

  Map<String, dynamic> toJson() => _$AssetClassInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

