//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/emergency_out.dart';
import 'package:faro_api/src/model/class_out.dart';
import 'package:faro_api/src/model/position_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'portfolio_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PortfolioOut {
  /// Returns a new [PortfolioOut] instance.
  PortfolioOut({

    required  this.value,

    required  this.cost,

    required  this.pnl,

    required  this.pnlPct,

    required  this.pending,

    required  this.stale,

    required  this.classes,

    required  this.unclassified,

    required  this.emergency,
  });

  @JsonKey(
    
    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;



  @JsonKey(
    
    name: r'cost',
    required: true,
    includeIfNull: false,
  )


  final String cost;



  @JsonKey(
    
    name: r'pnl',
    required: true,
    includeIfNull: false,
  )


  final String pnl;



  @JsonKey(
    
    name: r'pnl_pct',
    required: true,
    includeIfNull: true,
  )


  final String? pnlPct;



  @JsonKey(
    
    name: r'pending',
    required: true,
    includeIfNull: false,
  )


  final String pending;



  @JsonKey(
    
    name: r'stale',
    required: true,
    includeIfNull: false,
  )


  final int stale;



  @JsonKey(
    
    name: r'classes',
    required: true,
    includeIfNull: false,
  )


  final List<ClassOut> classes;



  @JsonKey(
    
    name: r'unclassified',
    required: true,
    includeIfNull: false,
  )


  final List<PositionOut> unclassified;



  @JsonKey(
    
    name: r'emergency',
    required: true,
    includeIfNull: true,
  )


  final EmergencyOut? emergency;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PortfolioOut &&
      other.value == value &&
      other.cost == cost &&
      other.pnl == pnl &&
      other.pnlPct == pnlPct &&
      other.pending == pending &&
      other.stale == stale &&
      other.classes == classes &&
      other.unclassified == unclassified &&
      other.emergency == emergency;

    @override
    int get hashCode =>
        value.hashCode +
        cost.hashCode +
        pnl.hashCode +
        (pnlPct == null ? 0 : pnlPct.hashCode) +
        pending.hashCode +
        stale.hashCode +
        classes.hashCode +
        unclassified.hashCode +
        (emergency == null ? 0 : emergency.hashCode);

  factory PortfolioOut.fromJson(Map<String, dynamic> json) => _$PortfolioOutFromJson(json);

  Map<String, dynamic> toJson() => _$PortfolioOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

