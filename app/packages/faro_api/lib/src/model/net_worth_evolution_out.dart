//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/net_worth_component_out.dart';
import 'package:faro_api/src/model/evolution_point_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'net_worth_evolution_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NetWorthEvolutionOut {
  /// Returns a new [NetWorthEvolutionOut] instance.
  NetWorthEvolutionOut({

    required  this.start,

    required  this.perCycleUntil,

    required  this.components,

    required  this.points,
  });

  @JsonKey(
    
    name: r'start',
    required: true,
    includeIfNull: true,
  )


  final DateTime? start;



  @JsonKey(
    
    name: r'per_cycle_until',
    required: true,
    includeIfNull: true,
  )


  final DateTime? perCycleUntil;



  @JsonKey(
    
    name: r'components',
    required: true,
    includeIfNull: false,
  )


  final List<NetWorthComponentOut> components;



  @JsonKey(
    
    name: r'points',
    required: true,
    includeIfNull: false,
  )


  final List<EvolutionPointOut> points;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NetWorthEvolutionOut &&
      other.start == start &&
      other.perCycleUntil == perCycleUntil &&
      other.components == components &&
      other.points == points;

    @override
    int get hashCode =>
        (start == null ? 0 : start.hashCode) +
        (perCycleUntil == null ? 0 : perCycleUntil.hashCode) +
        components.hashCode +
        points.hashCode;

  factory NetWorthEvolutionOut.fromJson(Map<String, dynamic> json) => _$NetWorthEvolutionOutFromJson(json);

  Map<String, dynamic> toJson() => _$NetWorthEvolutionOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

