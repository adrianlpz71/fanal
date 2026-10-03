//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'new_asset_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NewAssetOut {
  /// Returns a new [NewAssetOut] instance.
  NewAssetOut({

    required  this.key,

    required  this.name,
  });

  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NewAssetOut &&
      other.key == key &&
      other.name == name;

    @override
    int get hashCode =>
        key.hashCode +
        name.hashCode;

  factory NewAssetOut.fromJson(Map<String, dynamic> json) => _$NewAssetOutFromJson(json);

  Map<String, dynamic> toJson() => _$NewAssetOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

