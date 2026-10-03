//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'app_release.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AppRelease {
  /// Returns a new [AppRelease] instance.
  AppRelease({

    required  this.version,

    required  this.build,

    required  this.apkUrl,

     this.sha256,

     this.minSupportedBuild = 0,

     this.notes,
  });

  @JsonKey(
    
    name: r'version',
    required: true,
    includeIfNull: false,
  )


  final String version;



  @JsonKey(
    
    name: r'build',
    required: true,
    includeIfNull: false,
  )


  final int build;



  @JsonKey(
    
    name: r'apk_url',
    required: true,
    includeIfNull: false,
  )


  final String apkUrl;



  @JsonKey(
    
    name: r'sha256',
    required: false,
    includeIfNull: false,
  )


  final String? sha256;



  @JsonKey(
    defaultValue: 0,
    name: r'min_supported_build',
    required: false,
    includeIfNull: false,
  )


  final int? minSupportedBuild;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AppRelease &&
      other.version == version &&
      other.build == build &&
      other.apkUrl == apkUrl &&
      other.sha256 == sha256 &&
      other.minSupportedBuild == minSupportedBuild &&
      other.notes == notes;

    @override
    int get hashCode =>
        version.hashCode +
        build.hashCode +
        apkUrl.hashCode +
        (sha256 == null ? 0 : sha256.hashCode) +
        minSupportedBuild.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory AppRelease.fromJson(Map<String, dynamic> json) => _$AppReleaseFromJson(json);

  Map<String, dynamic> toJson() => _$AppReleaseToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

