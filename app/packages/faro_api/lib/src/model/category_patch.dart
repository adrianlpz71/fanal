//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'category_patch.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategoryPatch {
  /// Returns a new [CategoryPatch] instance.
  CategoryPatch({

     this.name,

     this.icon,

     this.color,

     this.fixed,

     this.archived,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'icon',
    required: false,
    includeIfNull: false,
  )


  final String? icon;



  @JsonKey(
    
    name: r'color',
    required: false,
    includeIfNull: false,
  )


  final String? color;



  @JsonKey(
    
    name: r'fixed',
    required: false,
    includeIfNull: false,
  )


  final bool? fixed;



  @JsonKey(
    
    name: r'archived',
    required: false,
    includeIfNull: false,
  )


  final bool? archived;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CategoryPatch &&
      other.name == name &&
      other.icon == icon &&
      other.color == color &&
      other.fixed == fixed &&
      other.archived == archived;

    @override
    int get hashCode =>
        (name == null ? 0 : name.hashCode) +
        (icon == null ? 0 : icon.hashCode) +
        (color == null ? 0 : color.hashCode) +
        (fixed == null ? 0 : fixed.hashCode) +
        (archived == null ? 0 : archived.hashCode);

  factory CategoryPatch.fromJson(Map<String, dynamic> json) => _$CategoryPatchFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

