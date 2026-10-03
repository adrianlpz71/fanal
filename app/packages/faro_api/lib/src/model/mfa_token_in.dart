//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'mfa_token_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MfaTokenIn {
  /// Returns a new [MfaTokenIn] instance.
  MfaTokenIn({

    required  this.mfaToken,
  });

  @JsonKey(
    
    name: r'mfa_token',
    required: true,
    includeIfNull: false,
  )


  final String mfaToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MfaTokenIn &&
      other.mfaToken == mfaToken;

    @override
    int get hashCode =>
        mfaToken.hashCode;

  factory MfaTokenIn.fromJson(Map<String, dynamic> json) => _$MfaTokenInFromJson(json);

  Map<String, dynamic> toJson() => _$MfaTokenInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

