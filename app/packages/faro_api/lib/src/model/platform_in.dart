//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'platform_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformIn {
  /// Returns a new [PlatformIn] instance.
  PlatformIn({

     this.id,

    required  this.name,

     this.kind,

     this.unitsDecimals = 4,

     this.defaultFee = '0',

     this.notes,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



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


  final PlatformInKindEnum? kind;



          // minimum: 0
          // maximum: 10
  @JsonKey(
    defaultValue: 4,
    name: r'units_decimals',
    required: false,
    includeIfNull: false,
  )


  final int? unitsDecimals;



  @JsonKey(
    defaultValue: '0',
    name: r'default_fee',
    required: false,
    includeIfNull: false,
  )


  final String? defaultFee;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformIn &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.unitsDecimals == unitsDecimals &&
      other.defaultFee == defaultFee &&
      other.notes == notes;

    @override
    int get hashCode =>
        (id == null ? 0 : id.hashCode) +
        name.hashCode +
        kind.hashCode +
        unitsDecimals.hashCode +
        defaultFee.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory PlatformIn.fromJson(Map<String, dynamic> json) => _$PlatformInFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PlatformInKindEnum {
@JsonValue(r'broker')
broker(r'broker'),
@JsonValue(r'exchange')
exchange(r'exchange'),
@JsonValue(r'banco')
banco(r'banco'),
@JsonValue(r'otro')
otro(r'otro');

const PlatformInKindEnum(this.value);

final String value;

@override
String toString() => value;
}


