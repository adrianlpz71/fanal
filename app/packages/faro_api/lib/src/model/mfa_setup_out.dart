//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'mfa_setup_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MfaSetupOut {
  /// Returns a new [MfaSetupOut] instance.
  MfaSetupOut({

    required  this.secret,

    required  this.otpauthUri,
  });

  @JsonKey(
    
    name: r'secret',
    required: true,
    includeIfNull: false,
  )


  final String secret;



  @JsonKey(
    
    name: r'otpauth_uri',
    required: true,
    includeIfNull: false,
  )


  final String otpauthUri;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MfaSetupOut &&
      other.secret == secret &&
      other.otpauthUri == otpauthUri;

    @override
    int get hashCode =>
        secret.hashCode +
        otpauthUri.hashCode;

  factory MfaSetupOut.fromJson(Map<String, dynamic> json) => _$MfaSetupOutFromJson(json);

  Map<String, dynamic> toJson() => _$MfaSetupOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

