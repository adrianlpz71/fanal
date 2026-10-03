//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'platform_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformOut {
  /// Returns a new [PlatformOut] instance.
  PlatformOut({

    required  this.id,

    required  this.name,

    required  this.kind,

    required  this.unitsDecimals,

    required  this.defaultFee,

    required  this.notes,
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
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final PlatformOutKindEnum kind;



  @JsonKey(
    
    name: r'units_decimals',
    required: true,
    includeIfNull: false,
  )


  final int unitsDecimals;



  @JsonKey(
    
    name: r'default_fee',
    required: true,
    includeIfNull: false,
  )


  final String defaultFee;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: true,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformOut &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.unitsDecimals == unitsDecimals &&
      other.defaultFee == defaultFee &&
      other.notes == notes;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        kind.hashCode +
        unitsDecimals.hashCode +
        defaultFee.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory PlatformOut.fromJson(Map<String, dynamic> json) => _$PlatformOutFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PlatformOutKindEnum {
@JsonValue(r'broker')
broker(r'broker'),
@JsonValue(r'exchange')
exchange(r'exchange'),
@JsonValue(r'banco')
banco(r'banco'),
@JsonValue(r'otro')
otro(r'otro');

const PlatformOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


