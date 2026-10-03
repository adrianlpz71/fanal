//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'job_result_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class JobResultOut {
  /// Returns a new [JobResultOut] instance.
  JobResultOut({

    required  this.updated,

    required  this.errors,
  });

  @JsonKey(
    
    name: r'updated',
    required: true,
    includeIfNull: false,
  )


  final int updated;



  @JsonKey(
    
    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final List<String> errors;





    @override
    bool operator ==(Object other) => identical(this, other) || other is JobResultOut &&
      other.updated == updated &&
      other.errors == errors;

    @override
    int get hashCode =>
        updated.hashCode +
        errors.hashCode;

  factory JobResultOut.fromJson(Map<String, dynamic> json) => _$JobResultOutFromJson(json);

  Map<String, dynamic> toJson() => _$JobResultOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

