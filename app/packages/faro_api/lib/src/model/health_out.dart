//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'health_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class HealthOut {
  /// Returns a new [HealthOut] instance.
  HealthOut({

    required  this.status,

    required  this.db,

    required  this.workerSeen,
  });

  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(
    
    name: r'db',
    required: true,
    includeIfNull: false,
  )


  final bool db;



  @JsonKey(
    
    name: r'worker_seen',
    required: true,
    includeIfNull: false,
  )


  final bool workerSeen;





    @override
    bool operator ==(Object other) => identical(this, other) || other is HealthOut &&
      other.status == status &&
      other.db == db &&
      other.workerSeen == workerSeen;

    @override
    int get hashCode =>
        status.hashCode +
        db.hashCode +
        workerSeen.hashCode;

  factory HealthOut.fromJson(Map<String, dynamic> json) => _$HealthOutFromJson(json);

  Map<String, dynamic> toJson() => _$HealthOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

