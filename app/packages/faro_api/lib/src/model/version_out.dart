//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/app_release.dart';
import 'package:json_annotation/json_annotation.dart';

part 'version_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class VersionOut {
  /// Returns a new [VersionOut] instance.
  VersionOut({

    required  this.apiVersion,

    required  this.app,
  });

  @JsonKey(
    
    name: r'api_version',
    required: true,
    includeIfNull: false,
  )


  final String apiVersion;



  @JsonKey(
    
    name: r'app',
    required: true,
    includeIfNull: true,
  )


  final AppRelease? app;





    @override
    bool operator ==(Object other) => identical(this, other) || other is VersionOut &&
      other.apiVersion == apiVersion &&
      other.app == app;

    @override
    int get hashCode =>
        apiVersion.hashCode +
        (app == null ? 0 : app.hashCode);

  factory VersionOut.fromJson(Map<String, dynamic> json) => _$VersionOutFromJson(json);

  Map<String, dynamic> toJson() => _$VersionOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

