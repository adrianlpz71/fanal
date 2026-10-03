//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'goal_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoalIn {
  /// Returns a new [GoalIn] instance.
  GoalIn({

     this.id,

    required  this.kind,

    required  this.name,

     this.targetValue,

     this.targetDate,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final GoalInKindEnum kind;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'target_value',
    required: false,
    includeIfNull: false,
  )


  final String? targetValue;



  @JsonKey(
    
    name: r'target_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? targetDate;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GoalIn &&
      other.id == id &&
      other.kind == kind &&
      other.name == name &&
      other.targetValue == targetValue &&
      other.targetDate == targetDate;

    @override
    int get hashCode =>
        (id == null ? 0 : id.hashCode) +
        kind.hashCode +
        name.hashCode +
        (targetValue == null ? 0 : targetValue.hashCode) +
        (targetDate == null ? 0 : targetDate.hashCode);

  factory GoalIn.fromJson(Map<String, dynamic> json) => _$GoalInFromJson(json);

  Map<String, dynamic> toJson() => _$GoalInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum GoalInKindEnum {
@JsonValue(r'edad_fi')
edadFi(r'edad_fi'),
@JsonValue(r'fondo_emergencia')
fondoEmergencia(r'fondo_emergencia'),
@JsonValue(r'patrimonio')
patrimonio(r'patrimonio'),
@JsonValue(r'cartera_en_fecha')
carteraEnFecha(r'cartera_en_fecha'),
@JsonValue(r'fijos_max')
fijosMax(r'fijos_max'),
@JsonValue(r'tasa_ahorro_min')
tasaAhorroMin(r'tasa_ahorro_min');

const GoalInKindEnum(this.value);

final String value;

@override
String toString() => value;
}


