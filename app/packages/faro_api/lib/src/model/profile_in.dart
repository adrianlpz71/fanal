//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'profile_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ProfileIn {
  /// Returns a new [ProfileIn] instance.
  ProfileIn({

     this.displayName,

     this.birthDate,

     this.taxRegion,

     this.completeOnboarding = false,
  });

  @JsonKey(
    
    name: r'display_name',
    required: false,
    includeIfNull: false,
  )


  final String? displayName;



  @JsonKey(
    
    name: r'birth_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? birthDate;



  @JsonKey(
    
    name: r'tax_region',
    required: false,
    includeIfNull: false,
  )


  final String? taxRegion;



  @JsonKey(
    defaultValue: false,
    name: r'complete_onboarding',
    required: false,
    includeIfNull: false,
  )


  final bool? completeOnboarding;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ProfileIn &&
      other.displayName == displayName &&
      other.birthDate == birthDate &&
      other.taxRegion == taxRegion &&
      other.completeOnboarding == completeOnboarding;

    @override
    int get hashCode =>
        (displayName == null ? 0 : displayName.hashCode) +
        (birthDate == null ? 0 : birthDate.hashCode) +
        (taxRegion == null ? 0 : taxRegion.hashCode) +
        completeOnboarding.hashCode;

  factory ProfileIn.fromJson(Map<String, dynamic> json) => _$ProfileInFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

