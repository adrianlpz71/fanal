//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'net_worth_component_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NetWorthComponentOut {
  /// Returns a new [NetWorthComponentOut] instance.
  NetWorthComponentOut({

    required  this.key,

    required  this.label,

    required  this.kind,

    required  this.group,

    required  this.entity,
  });

      /// c:<cuenta> o a:<activo>
  @JsonKey(
    
    name: r'key',
    required: true,
    includeIfNull: false,
  )


  final String key;



  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final NetWorthComponentOutKindEnum kind;



      /// Tipo de cuenta (gastos, ahorro, refugio) o de activo
  @JsonKey(
    
    name: r'group',
    required: true,
    includeIfNull: false,
  )


  final String group;



      /// Banco o plataforma
  @JsonKey(
    
    name: r'entity',
    required: true,
    includeIfNull: false,
  )


  final String entity;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NetWorthComponentOut &&
      other.key == key &&
      other.label == label &&
      other.kind == kind &&
      other.group == group &&
      other.entity == entity;

    @override
    int get hashCode =>
        key.hashCode +
        label.hashCode +
        kind.hashCode +
        group.hashCode +
        entity.hashCode;

  factory NetWorthComponentOut.fromJson(Map<String, dynamic> json) => _$NetWorthComponentOutFromJson(json);

  Map<String, dynamic> toJson() => _$NetWorthComponentOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum NetWorthComponentOutKindEnum {
@JsonValue(r'cuenta')
cuenta(r'cuenta'),
@JsonValue(r'inversion')
inversion(r'inversion');

const NetWorthComponentOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


