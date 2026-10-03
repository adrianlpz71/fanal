//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'contribution_month_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ContributionMonthOut {
  /// Returns a new [ContributionMonthOut] instance.
  ContributionMonthOut({

    required  this.year,

    required  this.month,

    required  this.total,

    required  this.byDestination,
  });

  @JsonKey(
    
    name: r'year',
    required: true,
    includeIfNull: false,
  )


  final int year;



  @JsonKey(
    
    name: r'month',
    required: true,
    includeIfNull: false,
  )


  final int month;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final String total;



  @JsonKey(
    
    name: r'by_destination',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> byDestination;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ContributionMonthOut &&
      other.year == year &&
      other.month == month &&
      other.total == total &&
      other.byDestination == byDestination;

    @override
    int get hashCode =>
        year.hashCode +
        month.hashCode +
        total.hashCode +
        byDestination.hashCode;

  factory ContributionMonthOut.fromJson(Map<String, dynamic> json) => _$ContributionMonthOutFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionMonthOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

