//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'token_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TokenOut {
  /// Returns a new [TokenOut] instance.
  TokenOut({

    required  this.accessToken,

    required  this.expiresIn,

     this.refreshToken,
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





    @override
    bool operator ==(Object other) => identical(this, other) || other is TokenOut &&
      other.accessToken == accessToken &&
      other.expiresIn == expiresIn &&
      other.refreshToken == refreshToken;

    @override
    int get hashCode =>
        accessToken.hashCode +
        expiresIn.hashCode +
        (refreshToken == null ? 0 : refreshToken.hashCode);

  factory TokenOut.fromJson(Map<String, dynamic> json) => _$TokenOutFromJson(json);

  Map<String, dynamic> toJson() => _$TokenOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

