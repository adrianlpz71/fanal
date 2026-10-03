//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/milestone_next_out.dart';
import 'package:faro_api/src/model/milestone_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'milestones_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MilestonesOut {
  /// Returns a new [MilestonesOut] instance.
  MilestonesOut({

    required  this.thresholds,

    required  this.items,

    required  this.next,

    required  this.pace,

    required  this.net,

    required  this.start,
  });

  @JsonKey(
    
    name: r'thresholds',
    required: true,
    includeIfNull: false,
  )


  final List<String> thresholds;



  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<MilestoneOut> items;



  @JsonKey(
    
    name: r'next',
    required: true,
    includeIfNull: true,
  )


  final MilestoneNextOut? next;



      /// Aportación media mensual (inversión + ahorro), 12 meses
  @JsonKey(
    
    name: r'pace',
    required: true,
    includeIfNull: false,
  )


  final String pace;



  @JsonKey(
    
    name: r'net',
    required: true,
    includeIfNull: false,
  )


  final String net;



  @JsonKey(
    
    name: r'start',
    required: true,
    includeIfNull: true,
  )


  final DateTime? start;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MilestonesOut &&
      other.thresholds == thresholds &&
      other.items == items &&
      other.next == next &&
      other.pace == pace &&
      other.net == net &&
      other.start == start;

    @override
    int get hashCode =>
        thresholds.hashCode +
        items.hashCode +
        (next == null ? 0 : next.hashCode) +
        pace.hashCode +
        net.hashCode +
        (start == null ? 0 : start.hashCode);

  factory MilestonesOut.fromJson(Map<String, dynamic> json) => _$MilestonesOutFromJson(json);

  Map<String, dynamic> toJson() => _$MilestonesOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

