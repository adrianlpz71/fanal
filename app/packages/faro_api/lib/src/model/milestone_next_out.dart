//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'milestone_next_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MilestoneNextOut {
  /// Returns a new [MilestoneNextOut] instance.
  MilestoneNextOut({

    required  this.amount,

    required  this.months,

    required  this.eta,
  });

  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'months',
    required: true,
    includeIfNull: true,
  )


  final int? months;



  @JsonKey(
    
    name: r'eta',
    required: true,
    includeIfNull: true,
  )


  final DateTime? eta;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MilestoneNextOut &&
      other.amount == amount &&
      other.months == months &&
      other.eta == eta;

    @override
    int get hashCode =>
        amount.hashCode +
        (months == null ? 0 : months.hashCode) +
        (eta == null ? 0 : eta.hashCode);

  factory MilestoneNextOut.fromJson(Map<String, dynamic> json) => _$MilestoneNextOutFromJson(json);

  Map<String, dynamic> toJson() => _$MilestoneNextOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

