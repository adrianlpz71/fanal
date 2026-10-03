//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'snapshot_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SnapshotIn {
  /// Returns a new [SnapshotIn] instance.
  SnapshotIn({

    required  this.date,

    required  this.value,

     this.cost,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;



  @JsonKey(
    
    name: r'cost',
    required: false,
    includeIfNull: false,
  )


  final String? cost;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SnapshotIn &&
      other.date == date &&
      other.value == value &&
      other.cost == cost;

    @override
    int get hashCode =>
        date.hashCode +
        value.hashCode +
        (cost == null ? 0 : cost.hashCode);

  factory SnapshotIn.fromJson(Map<String, dynamic> json) => _$SnapshotInFromJson(json);

  Map<String, dynamic> toJson() => _$SnapshotInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

