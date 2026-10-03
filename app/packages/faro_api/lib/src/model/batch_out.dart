//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'batch_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BatchOut {
  /// Returns a new [BatchOut] instance.
  BatchOut({

    required  this.id,

    required  this.kind,

    required  this.filename,

    required  this.status,

    required  this.createdAt,

    required  this.counts,

    required  this.fileBalance,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final String kind;



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
    
    name: r'created_at',
    required: true,
    includeIfNull: false,
  )


  final DateTime createdAt;



  @JsonKey(
    
    name: r'counts',
    required: true,
    includeIfNull: false,
  )


  final Map<String, int> counts;



  @JsonKey(
    
    name: r'file_balance',
    required: true,
    includeIfNull: true,
  )


  final String? fileBalance;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BatchOut &&
      other.id == id &&
      other.kind == kind &&
      other.filename == filename &&
      other.status == status &&
      other.createdAt == createdAt &&
      other.counts == counts &&
      other.fileBalance == fileBalance;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        filename.hashCode +
        status.hashCode +
        createdAt.hashCode +
        counts.hashCode +
        (fileBalance == null ? 0 : fileBalance.hashCode);

  factory BatchOut.fromJson(Map<String, dynamic> json) => _$BatchOutFromJson(json);

  Map<String, dynamic> toJson() => _$BatchOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

