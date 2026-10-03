//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'inv_settings_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InvSettingsIn {
  /// Returns a new [InvSettingsIn] instance.
  InvSettingsIn({

     this.minOperation,

     this.monthlyContribution,

     this.trackStart,

     this.clearTrackStart = false,
  });

  @JsonKey(
    
    name: r'min_operation',
    required: false,
    includeIfNull: false,
  )


  final String? minOperation;



  @JsonKey(
    
    name: r'monthly_contribution',
    required: false,
    includeIfNull: false,
  )


  final String? monthlyContribution;



  @JsonKey(
    
    name: r'track_start',
    required: false,
    includeIfNull: false,
  )


  final DateTime? trackStart;



  @JsonKey(
    defaultValue: false,
    name: r'clear_track_start',
    required: false,
    includeIfNull: false,
  )


  final bool? clearTrackStart;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InvSettingsIn &&
      other.minOperation == minOperation &&
      other.monthlyContribution == monthlyContribution &&
      other.trackStart == trackStart &&
      other.clearTrackStart == clearTrackStart;

    @override
    int get hashCode =>
        (minOperation == null ? 0 : minOperation.hashCode) +
        (monthlyContribution == null ? 0 : monthlyContribution.hashCode) +
        (trackStart == null ? 0 : trackStart.hashCode) +
        clearTrackStart.hashCode;

  factory InvSettingsIn.fromJson(Map<String, dynamic> json) => _$InvSettingsInFromJson(json);

  Map<String, dynamic> toJson() => _$InvSettingsInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

