//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'mfa_code_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MfaCodeIn {
  /// Returns a new [MfaCodeIn] instance.
  MfaCodeIn({

    required  this.mfaToken,

    required  this.code,
  });

  @JsonKey(
    
    name: r'mfa_token',
    required: true,
    includeIfNull: false,
  )


  final String mfaToken;



      /// Código TOTP o de recuperación
  @JsonKey(
    
    name: r'code',
    required: true,
    includeIfNull: false,
  )


  final String code;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MfaCodeIn &&
      other.mfaToken == mfaToken &&
      other.code == code;

    @override
    int get hashCode =>
        mfaToken.hashCode +
        code.hashCode;

  factory MfaCodeIn.fromJson(Map<String, dynamic> json) => _$MfaCodeInFromJson(json);

  Map<String, dynamic> toJson() => _$MfaCodeInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

