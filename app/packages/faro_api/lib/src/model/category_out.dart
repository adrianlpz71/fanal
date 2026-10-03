//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'category_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategoryOut {
  /// Returns a new [CategoryOut] instance.
  CategoryOut({

    required  this.id,

    required  this.parentId,

    required  this.name,

    required  this.kind,

    required  this.icon,

    required  this.color,

    required  this.fixed,

    required  this.archived,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'parent_id',
    required: true,
    includeIfNull: true,
  )


  final String? parentId;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final String kind;



  @JsonKey(
    
    name: r'icon',
    required: true,
    includeIfNull: false,
  )


  final String icon;



  @JsonKey(
    
    name: r'color',
    required: true,
    includeIfNull: false,
  )


  final String color;



  @JsonKey(
    
    name: r'fixed',
    required: true,
    includeIfNull: false,
  )


  final bool fixed;



  @JsonKey(
    
    name: r'archived',
    required: true,
    includeIfNull: false,
  )


  final bool archived;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CategoryOut &&
      other.id == id &&
      other.parentId == parentId &&
      other.name == name &&
      other.kind == kind &&
      other.icon == icon &&
      other.color == color &&
      other.fixed == fixed &&
      other.archived == archived;

    @override
    int get hashCode =>
        id.hashCode +
        (parentId == null ? 0 : parentId.hashCode) +
        name.hashCode +
        kind.hashCode +
        icon.hashCode +
        color.hashCode +
        fixed.hashCode +
        archived.hashCode;

  factory CategoryOut.fromJson(Map<String, dynamic> json) => _$CategoryOutFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

