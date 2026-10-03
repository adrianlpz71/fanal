//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/contribution_month_out.dart';
import 'package:faro_api/src/model/contribution_item_out.dart';
import 'package:faro_api/src/model/contribution_destination_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'contributions_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ContributionsOut {
  /// Returns a new [ContributionsOut] instance.
  ContributionsOut({

    required  this.thisMonth,

    required  this.thisYear,

    required  this.total,

    required  this.withdrawn,

    required  this.starting,

    required  this.pace,

    required  this.streak,

    required  this.paceInvesting,

    required  this.streakInvesting,

    required  this.trackStart,

    required  this.destinations,

    required  this.months,

    required  this.items,
  });

  @JsonKey(
    
    name: r'this_month',
    required: true,
    includeIfNull: false,
  )


  final String thisMonth;



  @JsonKey(
    
    name: r'this_year',
    required: true,
    includeIfNull: false,
  )


  final String thisYear;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final String total;



  @JsonKey(
    
    name: r'withdrawn',
    required: true,
    includeIfNull: false,
  )


  final String withdrawn;



      /// Posiciones iniciales: saldo de partida, no aportación
  @JsonKey(
    
    name: r'starting',
    required: true,
    includeIfNull: false,
  )


  final String starting;



      /// Media mensual de los últimos 12 meses
  @JsonKey(
    
    name: r'pace',
    required: true,
    includeIfNull: false,
  )


  final String pace;



      /// Meses seguidos aportando
  @JsonKey(
    
    name: r'streak',
    required: true,
    includeIfNull: false,
  )


  final int streak;



      /// Como pace, solo a inversiones (sin ahorro)
  @JsonKey(
    
    name: r'pace_investing',
    required: true,
    includeIfNull: false,
  )


  final String paceInvesting;



      /// Como streak, solo a inversiones (sin ahorro)
  @JsonKey(
    
    name: r'streak_investing',
    required: true,
    includeIfNull: false,
  )


  final int streakInvesting;



  @JsonKey(
    
    name: r'track_start',
    required: true,
    includeIfNull: true,
  )


  final DateTime? trackStart;



  @JsonKey(
    
    name: r'destinations',
    required: true,
    includeIfNull: false,
  )


  final List<ContributionDestinationOut> destinations;



  @JsonKey(
    
    name: r'months',
    required: true,
    includeIfNull: false,
  )


  final List<ContributionMonthOut> months;



  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<ContributionItemOut> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ContributionsOut &&
      other.thisMonth == thisMonth &&
      other.thisYear == thisYear &&
      other.total == total &&
      other.withdrawn == withdrawn &&
      other.starting == starting &&
      other.pace == pace &&
      other.streak == streak &&
      other.paceInvesting == paceInvesting &&
      other.streakInvesting == streakInvesting &&
      other.trackStart == trackStart &&
      other.destinations == destinations &&
      other.months == months &&
      other.items == items;

    @override
    int get hashCode =>
        thisMonth.hashCode +
        thisYear.hashCode +
        total.hashCode +
        withdrawn.hashCode +
        starting.hashCode +
        pace.hashCode +
        streak.hashCode +
        paceInvesting.hashCode +
        streakInvesting.hashCode +
        (trackStart == null ? 0 : trackStart.hashCode) +
        destinations.hashCode +
        months.hashCode +
        items.hashCode;

  factory ContributionsOut.fromJson(Map<String, dynamic> json) => _$ContributionsOutFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionsOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

