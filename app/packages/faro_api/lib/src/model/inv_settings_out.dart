//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'inv_settings_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InvSettingsOut {
  /// Returns a new [InvSettingsOut] instance.
  InvSettingsOut({

    required  this.configured,

    required  this.minOperation,

    required  this.monthlyContribution,

    required  this.trackStart,
  });

  @JsonKey(
    
    name: r'configured',
    required: true,
    includeIfNull: false,
  )


  final bool configured;



  @JsonKey(
    
    name: r'min_operation',
    required: true,
    includeIfNull: false,
  )


  final String minOperation;



  @JsonKey(
    
    name: r'monthly_contribution',
    required: true,
    includeIfNull: true,
  )


  final String? monthlyContribution;



  @JsonKey(
    
    name: r'track_start',
    required: true,
    includeIfNull: true,
  )


  final DateTime? trackStart;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InvSettingsOut &&
      other.configured == configured &&
      other.minOperation == minOperation &&
      other.monthlyContribution == monthlyContribution &&
      other.trackStart == trackStart;

    @override
    int get hashCode =>
        configured.hashCode +
        minOperation.hashCode +
        (monthlyContribution == null ? 0 : monthlyContribution.hashCode) +
        (trackStart == null ? 0 : trackStart.hashCode);

  factory InvSettingsOut.fromJson(Map<String, dynamic> json) => _$InvSettingsOutFromJson(json);

  Map<String, dynamic> toJson() => _$InvSettingsOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

