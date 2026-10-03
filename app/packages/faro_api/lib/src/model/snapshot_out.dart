//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'snapshot_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SnapshotOut {
  /// Returns a new [SnapshotOut] instance.
  SnapshotOut({

    required  this.date,

    required  this.value,

    required  this.cost,

    required  this.netFlow,

    required  this.manual,
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
    required: true,
    includeIfNull: true,
  )


  final String? cost;



  @JsonKey(
    
    name: r'net_flow',
    required: true,
    includeIfNull: false,
  )


  final String netFlow;



  @JsonKey(
    
    name: r'manual',
    required: true,
    includeIfNull: false,
  )


  final bool manual;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SnapshotOut &&
      other.date == date &&
      other.value == value &&
      other.cost == cost &&
      other.netFlow == netFlow &&
      other.manual == manual;

    @override
    int get hashCode =>
        date.hashCode +
        value.hashCode +
        (cost == null ? 0 : cost.hashCode) +
        netFlow.hashCode +
        manual.hashCode;

  factory SnapshotOut.fromJson(Map<String, dynamic> json) => _$SnapshotOutFromJson(json);

  Map<String, dynamic> toJson() => _$SnapshotOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

