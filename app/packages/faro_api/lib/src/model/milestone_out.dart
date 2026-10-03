//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'milestone_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MilestoneOut {
  /// Returns a new [MilestoneOut] instance.
  MilestoneOut({

    required  this.amount,

    required  this.reachedOn,

    required  this.beforeStart,
  });

  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'reached_on',
    required: true,
    includeIfNull: true,
  )


  final DateTime? reachedOn;



      /// Ya se superaba al empezar la serie
  @JsonKey(
    
    name: r'before_start',
    required: true,
    includeIfNull: false,
  )


  final bool beforeStart;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MilestoneOut &&
      other.amount == amount &&
      other.reachedOn == reachedOn &&
      other.beforeStart == beforeStart;

    @override
    int get hashCode =>
        amount.hashCode +
        (reachedOn == null ? 0 : reachedOn.hashCode) +
        beforeStart.hashCode;

  factory MilestoneOut.fromJson(Map<String, dynamic> json) => _$MilestoneOutFromJson(json);

  Map<String, dynamic> toJson() => _$MilestoneOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

