//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'cycle_start_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CycleStartIn {
  /// Returns a new [CycleStartIn] instance.
  CycleStartIn({

    required  this.currentBalance,

     this.payrollAmount = '0',

     this.payrollDate,
  });

  @JsonKey(
    
    name: r'current_balance',
    required: true,
    includeIfNull: false,
  )


  final String currentBalance;



  @JsonKey(
    defaultValue: '0',
    name: r'payroll_amount',
    required: false,
    includeIfNull: false,
  )


  final String? payrollAmount;



  @JsonKey(
    
    name: r'payroll_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? payrollDate;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CycleStartIn &&
      other.currentBalance == currentBalance &&
      other.payrollAmount == payrollAmount &&
      other.payrollDate == payrollDate;

    @override
    int get hashCode =>
        currentBalance.hashCode +
        payrollAmount.hashCode +
        (payrollDate == null ? 0 : payrollDate.hashCode);

  factory CycleStartIn.fromJson(Map<String, dynamic> json) => _$CycleStartInFromJson(json);

  Map<String, dynamic> toJson() => _$CycleStartInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

