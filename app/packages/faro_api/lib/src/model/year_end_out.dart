//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'year_end_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class YearEndOut {
  /// Returns a new [YearEndOut] instance.
  YearEndOut({

    required  this.name,

    required  this.kind,

    required  this.value,

    required  this.foreignHint,
  });

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


  final YearEndOutKindEnum kind;



  @JsonKey(
    
    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;



  @JsonKey(
    
    name: r'foreign_hint',
    required: true,
    includeIfNull: false,
  )


  final bool foreignHint;





    @override
    bool operator ==(Object other) => identical(this, other) || other is YearEndOut &&
      other.name == name &&
      other.kind == kind &&
      other.value == value &&
      other.foreignHint == foreignHint;

    @override
    int get hashCode =>
        name.hashCode +
        kind.hashCode +
        value.hashCode +
        foreignHint.hashCode;

  factory YearEndOut.fromJson(Map<String, dynamic> json) => _$YearEndOutFromJson(json);

  Map<String, dynamic> toJson() => _$YearEndOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum YearEndOutKindEnum {
@JsonValue(r'cuenta')
cuenta(r'cuenta'),
@JsonValue(r'activo')
activo(r'activo');

const YearEndOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


