//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tracker_cycle_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TrackerCycleOut {
  /// Returns a new [TrackerCycleOut] instance.
  TrackerCycleOut({

    required  this.label,

    required  this.amount,
  });

  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TrackerCycleOut &&
      other.label == label &&
      other.amount == amount;

    @override
    int get hashCode =>
        label.hashCode +
        amount.hashCode;

  factory TrackerCycleOut.fromJson(Map<String, dynamic> json) => _$TrackerCycleOutFromJson(json);

  Map<String, dynamic> toJson() => _$TrackerCycleOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

