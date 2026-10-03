//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'gastos_settings_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class GastosSettingsIn {
  /// Returns a new [GastosSettingsIn] instance.
  GastosSettingsIn({

     this.paydayDay,

     this.usualPayroll,

     this.emergencyTarget,

     this.monthlyRefugio,

     this.forecastMonths,
  });

          // minimum: 1
          // maximum: 31
  @JsonKey(
    
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



          // minimum: 1
          // maximum: 24
  @JsonKey(
    
    name: r'forecast_months',
    required: false,
    includeIfNull: false,
  )


  final int? forecastMonths;





    @override
    bool operator ==(Object other) => identical(this, other) || other is GastosSettingsIn &&
      other.paydayDay == paydayDay &&
      other.usualPayroll == usualPayroll &&
      other.emergencyTarget == emergencyTarget &&
      other.monthlyRefugio == monthlyRefugio &&
      other.forecastMonths == forecastMonths;

    @override
    int get hashCode =>
        (paydayDay == null ? 0 : paydayDay.hashCode) +
        (usualPayroll == null ? 0 : usualPayroll.hashCode) +
        (emergencyTarget == null ? 0 : emergencyTarget.hashCode) +
        (monthlyRefugio == null ? 0 : monthlyRefugio.hashCode) +
        (forecastMonths == null ? 0 : forecastMonths.hashCode);

  factory GastosSettingsIn.fromJson(Map<String, dynamic> json) => _$GastosSettingsInFromJson(json);

  Map<String, dynamic> toJson() => _$GastosSettingsInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

