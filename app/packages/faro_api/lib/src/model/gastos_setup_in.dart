//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'gastos_setup_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GastosSetupIn {
  /// Returns a new [GastosSetupIn] instance.
  GastosSetupIn({

    required  this.bank,

    required  this.currentBalance,

     this.paydayDay = 27,

     this.usualPayroll,

     this.refugioBank,

     this.refugioBalance,

     this.emergencyTarget,

     this.monthlyRefugio,
  });

      /// Banco de la cuenta donde cobras
  @JsonKey(
    
    name: r'bank',
    required: true,
    includeIfNull: false,
  )


  final String bank;



      /// Saldo real hoy
  @JsonKey(
    
    name: r'current_balance',
    required: true,
    includeIfNull: false,
  )


  final String currentBalance;



          // minimum: 1
          // maximum: 31
  @JsonKey(
    defaultValue: 27,
    name: r'payday_day',
    required: false,
    includeIfNull: false,
  )


  final int? paydayDay;



  @JsonKey(
    
    name: r'usual_payroll',
    required: false,
    includeIfNull: false,
  )


  final String? usualPayroll;



  @JsonKey(
    
    name: r'refugio_bank',
    required: false,
    includeIfNull: false,
  )


  final String? refugioBank;



  @JsonKey(
    
    name: r'refugio_balance',
    required: false,
    includeIfNull: false,
  )


  final String? refugioBalance;



  @JsonKey(
    
    name: r'emergency_target',
    required: false,
    includeIfNull: false,
  )


  final String? emergencyTarget;



  @JsonKey(
    
    name: r'monthly_refugio',
    required: false,
    includeIfNull: false,
  )


  final String? monthlyRefugio;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GastosSetupIn &&
      other.bank == bank &&
      other.currentBalance == currentBalance &&
      other.paydayDay == paydayDay &&
      other.usualPayroll == usualPayroll &&
      other.refugioBank == refugioBank &&
      other.refugioBalance == refugioBalance &&
      other.emergencyTarget == emergencyTarget &&
      other.monthlyRefugio == monthlyRefugio;

    @override
    int get hashCode =>
        bank.hashCode +
        currentBalance.hashCode +
        paydayDay.hashCode +
        (usualPayroll == null ? 0 : usualPayroll.hashCode) +
        (refugioBank == null ? 0 : refugioBank.hashCode) +
        (refugioBalance == null ? 0 : refugioBalance.hashCode) +
        (emergencyTarget == null ? 0 : emergencyTarget.hashCode) +
        (monthlyRefugio == null ? 0 : monthlyRefugio.hashCode);

  factory GastosSetupIn.fromJson(Map<String, dynamic> json) => _$GastosSetupInFromJson(json);

  Map<String, dynamic> toJson() => _$GastosSetupInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

