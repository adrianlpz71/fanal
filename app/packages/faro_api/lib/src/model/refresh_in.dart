//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'refresh_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class RefreshIn {
  /// Returns a new [RefreshIn] instance.
  RefreshIn({

     this.refreshToken,
  });

  @JsonKey(
    
    name: r'refresh_token',
    required: false,
    includeIfNull: false,
  )


  final String? refreshToken;





    @override
    bool operator ==(Object other) => identical(this, other) || other is RefreshIn &&
      other.refreshToken == refreshToken;

    @override
    int get hashCode =>
        (refreshToken == null ? 0 : refreshToken.hashCode);

  factory RefreshIn.fromJson(Map<String, dynamic> json) => _$RefreshInFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

