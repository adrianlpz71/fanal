//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'platform_batch_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PlatformBatchOut {
  /// Returns a new [PlatformBatchOut] instance.
  PlatformBatchOut({

    required  this.id,

    required  this.filename,

    required  this.status,

    required  this.counts,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'filename',
    required: true,
    includeIfNull: false,
  )


  final String filename;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(
    
    name: r'counts',
    required: true,
    includeIfNull: false,
  )


  final Map<String, int> counts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PlatformBatchOut &&
      other.id == id &&
      other.filename == filename &&
      other.status == status &&
      other.counts == counts;

    @override
    int get hashCode =>
        id.hashCode +
        filename.hashCode +
        status.hashCode +
        counts.hashCode;

  factory PlatformBatchOut.fromJson(Map<String, dynamic> json) => _$PlatformBatchOutFromJson(json);

  Map<String, dynamic> toJson() => _$PlatformBatchOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

