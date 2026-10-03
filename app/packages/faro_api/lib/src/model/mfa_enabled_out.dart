//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'mfa_enabled_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MfaEnabledOut {
  /// Returns a new [MfaEnabledOut] instance.
  MfaEnabledOut({

    required  this.accessToken,

    required  this.expiresIn,

     this.refreshToken,

    required  this.recoveryCodes,
  });

  @JsonKey(
    
    name: r'access_token',
    required: true,
    includeIfNull: false,
  )


  final String accessToken;



  @JsonKey(
    
    name: r'expires_in',
    required: true,
    includeIfNull: false,
  )


  final int expiresIn;



  @JsonKey(
    
    name: r'refresh_token',
    required: false,
    includeIfNull: false,
  )


  final String? refreshToken;



  @JsonKey(
    
    name: r'recovery_codes',
    required: true,
    includeIfNull: false,
  )


  final List<String> recoveryCodes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MfaEnabledOut &&
      other.accessToken == accessToken &&
      other.expiresIn == expiresIn &&
      other.refreshToken == refreshToken &&
      other.recoveryCodes == recoveryCodes;

    @override
    int get hashCode =>
        accessToken.hashCode +
        expiresIn.hashCode +
        (refreshToken == null ? 0 : refreshToken.hashCode) +
        recoveryCodes.hashCode;

  factory MfaEnabledOut.fromJson(Map<String, dynamic> json) => _$MfaEnabledOutFromJson(json);

  Map<String, dynamic> toJson() => _$MfaEnabledOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

