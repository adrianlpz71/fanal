//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'gastos_settings_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GastosSettingsOut {
  /// Returns a new [GastosSettingsOut] instance.
  GastosSettingsOut({

    required  this.configured,

    required  this.paydayDay,

    required  this.usualPayroll,

    required  this.mainAccountId,

    required  this.refugioAccountId,

    required  this.emergencyTarget,

    required  this.monthlyRefugio,

    required  this.forecastMonths,
  });

  @JsonKey(
    
    name: r'configured',
    required: true,
    includeIfNull: false,
  )


  final bool configured;



  @JsonKey(
    
    name: r'payday_day',
    required: true,
    includeIfNull: false,
  )


  final int paydayDay;



  @JsonKey(
    
    name: r'usual_payroll',
    required: true,
    includeIfNull: true,
  )


  final String? usualPayroll;



  @JsonKey(
    
    name: r'main_account_id',
    required: true,
    includeIfNull: true,
  )


  final String? mainAccountId;



  @JsonKey(
    
    name: r'refugio_account_id',
    required: true,
    includeIfNull: true,
  )


  final String? refugioAccountId;



  @JsonKey(
    
    name: r'emergency_target',
    required: true,
    includeIfNull: true,
  )


  final String? emergencyTarget;



  @JsonKey(
    
    name: r'monthly_refugio',
    required: true,
    includeIfNull: true,
  )


  final String? monthlyRefugio;



  @JsonKey(
    
    name: r'forecast_months',
    required: true,
    includeIfNull: false,
  )


  final int forecastMonths;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GastosSettingsOut &&
      other.configured == configured &&
      other.paydayDay == paydayDay &&
      other.usualPayroll == usualPayroll &&
      other.mainAccountId == mainAccountId &&
      other.refugioAccountId == refugioAccountId &&
      other.emergencyTarget == emergencyTarget &&
      other.monthlyRefugio == monthlyRefugio &&
      other.forecastMonths == forecastMonths;

    @override
    int get hashCode =>
        configured.hashCode +
        paydayDay.hashCode +
        (usualPayroll == null ? 0 : usualPayroll.hashCode) +
        (mainAccountId == null ? 0 : mainAccountId.hashCode) +
        (refugioAccountId == null ? 0 : refugioAccountId.hashCode) +
        (emergencyTarget == null ? 0 : emergencyTarget.hashCode) +
        (monthlyRefugio == null ? 0 : monthlyRefugio.hashCode) +
        forecastMonths.hashCode;

  factory GastosSettingsOut.fromJson(Map<String, dynamic> json) => _$GastosSettingsOutFromJson(json);

  Map<String, dynamic> toJson() => _$GastosSettingsOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

