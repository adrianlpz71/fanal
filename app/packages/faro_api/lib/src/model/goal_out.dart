//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'goal_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GoalOut {
  /// Returns a new [GoalOut] instance.
  GoalOut({

    required  this.id,

    required  this.kind,

    required  this.name,

    required  this.targetValue,

    required  this.targetDate,

    required  this.current,

    required  this.progress,

    required  this.onTrack,

    required  this.detail,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final GoalOutKindEnum kind;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'target_value',
    required: true,
    includeIfNull: true,
  )


  final String? targetValue;



  @JsonKey(
    
    name: r'target_date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? targetDate;



  @JsonKey(
    
    name: r'current',
    required: true,
    includeIfNull: true,
  )


  final String? current;



  @JsonKey(
    
    name: r'progress',
    required: true,
    includeIfNull: true,
  )


  final String? progress;



  @JsonKey(
    
    name: r'on_track',
    required: true,
    includeIfNull: true,
  )


  final bool? onTrack;



  @JsonKey(
    
    name: r'detail',
    required: true,
    includeIfNull: false,
  )


  final String detail;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GoalOut &&
      other.id == id &&
      other.kind == kind &&
      other.name == name &&
      other.targetValue == targetValue &&
      other.targetDate == targetDate &&
      other.current == current &&
      other.progress == progress &&
      other.onTrack == onTrack &&
      other.detail == detail;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        name.hashCode +
        (targetValue == null ? 0 : targetValue.hashCode) +
        (targetDate == null ? 0 : targetDate.hashCode) +
        (current == null ? 0 : current.hashCode) +
        (progress == null ? 0 : progress.hashCode) +
        (onTrack == null ? 0 : onTrack.hashCode) +
        detail.hashCode;

  factory GoalOut.fromJson(Map<String, dynamic> json) => _$GoalOutFromJson(json);

  Map<String, dynamic> toJson() => _$GoalOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum GoalOutKindEnum {
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

const GoalOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


