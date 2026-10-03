//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/cycle_summary_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'cycle_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CycleOut {
  /// Returns a new [CycleOut] instance.
  CycleOut({

    required  this.id,

    required  this.label,

    required  this.status,

    required  this.startDate,

    required  this.endDate,

    required  this.carriedExpected,

    required  this.discrepancy,

    required  this.summary,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final CycleOutStatusEnum status;



  @JsonKey(
    
    name: r'start_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime startDate;



  @JsonKey(
    
    name: r'end_date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? endDate;



  @JsonKey(
    
    name: r'carried_expected',
    required: true,
    includeIfNull: true,
  )


  final String? carriedExpected;



  @JsonKey(
    
    name: r'discrepancy',
    required: true,
    includeIfNull: true,
  )


  final String? discrepancy;



  @JsonKey(
    
    name: r'summary',
    required: true,
    includeIfNull: false,
  )


  final CycleSummaryOut summary;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CycleOut &&
      other.id == id &&
      other.label == label &&
      other.status == status &&
      other.startDate == startDate &&
      other.endDate == endDate &&
      other.carriedExpected == carriedExpected &&
      other.discrepancy == discrepancy &&
      other.summary == summary;

    @override
    int get hashCode =>
        id.hashCode +
        label.hashCode +
        status.hashCode +
        startDate.hashCode +
        (endDate == null ? 0 : endDate.hashCode) +
        (carriedExpected == null ? 0 : carriedExpected.hashCode) +
        (discrepancy == null ? 0 : discrepancy.hashCode) +
        summary.hashCode;

  factory CycleOut.fromJson(Map<String, dynamic> json) => _$CycleOutFromJson(json);

  Map<String, dynamic> toJson() => _$CycleOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CycleOutStatusEnum {
@JsonValue(r'open')
open(r'open'),
@JsonValue(r'closed')
closed(r'closed');

const CycleOutStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


