//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'payday_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaydayIn {
  /// Returns a new [PaydayIn] instance.
  PaydayIn({

    required  this.payrollAmount,

    required  this.payrollDate,

    required  this.realBalanceBefore,

     this.pendingActions,
  });

  @JsonKey(
    
    name: r'payroll_amount',
    required: true,
    includeIfNull: false,
  )


  final String payrollAmount;



  @JsonKey(
    
    name: r'payroll_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime payrollDate;



      /// Saldo real del banco ANTES de la nómina
  @JsonKey(
    
    name: r'real_balance_before',
    required: true,
    includeIfNull: false,
  )


  final String realBalanceBefore;



  @JsonKey(
    
    name: r'pending_actions',
    required: false,
    includeIfNull: false,
  )


  final Map<String, PaydayInPendingActionsEnum>? pendingActions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PaydayIn &&
      other.payrollAmount == payrollAmount &&
      other.payrollDate == payrollDate &&
      other.realBalanceBefore == realBalanceBefore &&
      other.pendingActions == pendingActions;

    @override
    int get hashCode =>
        payrollAmount.hashCode +
        payrollDate.hashCode +
        realBalanceBefore.hashCode +
        pendingActions.hashCode;

  factory PaydayIn.fromJson(Map<String, dynamic> json) => _$PaydayInFromJson(json);

  Map<String, dynamic> toJson() => _$PaydayInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PaydayInPendingActionsEnum {
@JsonValue(r'carry')
carry(r'carry'),
@JsonValue(r'cancel')
cancel(r'cancel');

const PaydayInPendingActionsEnum(this.value);

final String value;

@override
String toString() => value;
}


