//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'user_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class UserOut {
  /// Returns a new [UserOut] instance.
  UserOut({

    required  this.id,

    required  this.email,

    required  this.displayName,

    required  this.birthDate,

    required  this.locale,

    required  this.currency,

    required  this.timezone,

    required  this.taxRegion,

    required  this.onboardingCompleted,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'email',
    required: true,
    includeIfNull: false,
  )


  final String email;



  @JsonKey(
    
    name: r'display_name',
    required: true,
    includeIfNull: false,
  )


  final String displayName;



  @JsonKey(
    
    name: r'birth_date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? birthDate;



  @JsonKey(
    
    name: r'locale',
    required: true,
    includeIfNull: false,
  )


  final String locale;



  @JsonKey(
    
    name: r'currency',
    required: true,
    includeIfNull: false,
  )


  final String currency;



  @JsonKey(
    
    name: r'timezone',
    required: true,
    includeIfNull: false,
  )


  final String timezone;



  @JsonKey(
    
    name: r'tax_region',
    required: true,
    includeIfNull: false,
  )


  final String taxRegion;



  @JsonKey(
    
    name: r'onboarding_completed',
    required: true,
    includeIfNull: false,
  )


  final bool onboardingCompleted;





    @override
    bool operator ==(Object other) => identical(this, other) || other is UserOut &&
      other.id == id &&
      other.email == email &&
      other.displayName == displayName &&
      other.birthDate == birthDate &&
      other.locale == locale &&
      other.currency == currency &&
      other.timezone == timezone &&
      other.taxRegion == taxRegion &&
      other.onboardingCompleted == onboardingCompleted;

    @override
    int get hashCode =>
        id.hashCode +
        email.hashCode +
        displayName.hashCode +
        (birthDate == null ? 0 : birthDate.hashCode) +
        locale.hashCode +
        currency.hashCode +
        timezone.hashCode +
        taxRegion.hashCode +
        onboardingCompleted.hashCode;

  factory UserOut.fromJson(Map<String, dynamic> json) => _$UserOutFromJson(json);

  Map<String, dynamic> toJson() => _$UserOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

