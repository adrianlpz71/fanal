//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'category_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CategoryIn {
  /// Returns a new [CategoryIn] instance.
  CategoryIn({

     this.parentId,

    required  this.name,

     this.kind,

     this.icon = 'category',

     this.color = '#607D8B',

     this.fixed = false,
  });

  @JsonKey(
    
    name: r'parent_id',
    required: false,
    includeIfNull: false,
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
    required: false,
    includeIfNull: false,
  )


  final CategoryInKindEnum? kind;



  @JsonKey(
    defaultValue: 'category',
    name: r'icon',
    required: false,
    includeIfNull: false,
  )


  final String? icon;



  @JsonKey(
    defaultValue: '#607D8B',
    name: r'color',
    required: false,
    includeIfNull: false,
  )


  final String? color;



  @JsonKey(
    defaultValue: false,
    name: r'fixed',
    required: false,
    includeIfNull: false,
  )


  final bool? fixed;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CategoryIn &&
      other.parentId == parentId &&
      other.name == name &&
      other.kind == kind &&
      other.icon == icon &&
      other.color == color &&
      other.fixed == fixed;

    @override
    int get hashCode =>
        (parentId == null ? 0 : parentId.hashCode) +
        name.hashCode +
        kind.hashCode +
        icon.hashCode +
        color.hashCode +
        fixed.hashCode;

  factory CategoryIn.fromJson(Map<String, dynamic> json) => _$CategoryInFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CategoryInKindEnum {
@JsonValue(r'gasto')
gasto(r'gasto'),
@JsonValue(r'ingreso')
ingreso(r'ingreso'),
@JsonValue(r'transferencia')
transferencia(r'transferencia');

const CategoryInKindEnum(this.value);

final String value;

@override
String toString() => value;
}


