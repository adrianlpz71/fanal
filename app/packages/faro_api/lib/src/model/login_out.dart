//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'login_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class LoginOut {
  /// Returns a new [LoginOut] instance.
  LoginOut({

    required  this.status,

     this.mfaToken,

     this.accessToken,

     this.expiresIn,

     this.refreshToken,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final LoginOutStatusEnum status;



  @JsonKey(
    
    name: r'mfa_token',
    required: false,
    includeIfNull: false,
  )


  final String? mfaToken;



  @JsonKey(
    
    name: r'access_token',
    required: false,
    includeIfNull: false,
  )


  final String? accessToken;



  @JsonKey(
    
    name: r'expires_in',
    required: false,
    includeIfNull: false,
  )


  final int? expiresIn;



  @JsonKey(
    
    name: r'refresh_token',
    required: false,
    includeIfNull: false,
  )


  final String? refreshToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is LoginOut &&
      other.status == status &&
      other.mfaToken == mfaToken &&
      other.accessToken == accessToken &&
      other.expiresIn == expiresIn &&
      other.refreshToken == refreshToken;

    @override
    int get hashCode =>
        status.hashCode +
        (mfaToken == null ? 0 : mfaToken.hashCode) +
        (accessToken == null ? 0 : accessToken.hashCode) +
        (expiresIn == null ? 0 : expiresIn.hashCode) +
        (refreshToken == null ? 0 : refreshToken.hashCode);

  factory LoginOut.fromJson(Map<String, dynamic> json) => _$LoginOutFromJson(json);

  Map<String, dynamic> toJson() => _$LoginOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum LoginOutStatusEnum {
@JsonValue(r'verify')
verify(r'verify'),
@JsonValue(r'setup')
setup(r'setup'),
@JsonValue(r'done')
done(r'done');

const LoginOutStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


