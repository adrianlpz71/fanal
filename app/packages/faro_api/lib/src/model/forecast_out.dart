//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/forecast_month_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'forecast_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ForecastOut {
  /// Returns a new [ForecastOut] instance.
  ForecastOut({

    required  this.months,

    required  this.liveInstallmentDebt,
  });

  @JsonKey(
    
    name: r'months',
    required: true,
    includeIfNull: false,
  )


  final List<ForecastMonthOut> months;



  @JsonKey(
    
    name: r'live_installment_debt',
    required: true,
    includeIfNull: false,
  )


  final String liveInstallmentDebt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ForecastOut &&
      other.months == months &&
      other.liveInstallmentDebt == liveInstallmentDebt;

    @override
    int get hashCode =>
        months.hashCode +
        liveInstallmentDebt.hashCode;

  factory ForecastOut.fromJson(Map<String, dynamic> json) => _$ForecastOutFromJson(json);

  Map<String, dynamic> toJson() => _$ForecastOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

