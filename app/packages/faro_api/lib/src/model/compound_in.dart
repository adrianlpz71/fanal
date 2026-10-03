//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'compound_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompoundIn {
  /// Returns a new [CompoundIn] instance.
  CompoundIn({

     this.initial = '0',

     this.contribution = '0',

     this.periods,

     this.timing,

     this.annualIncrease = '0',

    required  this.annualRate,

    required  this.years,

     this.convention,

     this.inflation = '0',

     this.taxOnWithdrawal = false,
  });

  @JsonKey(
    defaultValue: '0',
    name: r'initial',
    required: false,
    includeIfNull: false,
  )


  final String? initial;



  @JsonKey(
    defaultValue: '0',
    name: r'contribution',
    required: false,
    includeIfNull: false,
  )


  final String? contribution;



  @JsonKey(
    
    name: r'periods',
    required: false,
    includeIfNull: false,
  )


  final CompoundInPeriodsEnum? periods;



  @JsonKey(
    
    name: r'timing',
    required: false,
    includeIfNull: false,
  )


  final CompoundInTimingEnum? timing;



  @JsonKey(
    defaultValue: '0',
    name: r'annual_increase',
    required: false,
    includeIfNull: false,
  )


  final String? annualIncrease;



  @JsonKey(
    
    name: r'annual_rate',
    required: true,
    includeIfNull: false,
  )


  final String annualRate;



          // minimum: 1
          // maximum: 80
  @JsonKey(
    
    name: r'years',
    required: true,
    includeIfNull: false,
  )


  final int years;



  @JsonKey(
    
    name: r'convention',
    required: false,
    includeIfNull: false,
  )


  final CompoundInConventionEnum? convention;



  @JsonKey(
    defaultValue: '0',
    name: r'inflation',
    required: false,
    includeIfNull: false,
  )


  final String? inflation;



  @JsonKey(
    defaultValue: false,
    name: r'tax_on_withdrawal',
    required: false,
    includeIfNull: false,
  )


  final bool? taxOnWithdrawal;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompoundIn &&
      other.initial == initial &&
      other.contribution == contribution &&
      other.periods == periods &&
      other.timing == timing &&
      other.annualIncrease == annualIncrease &&
      other.annualRate == annualRate &&
      other.years == years &&
      other.convention == convention &&
      other.inflation == inflation &&
      other.taxOnWithdrawal == taxOnWithdrawal;

    @override
    int get hashCode =>
        initial.hashCode +
        contribution.hashCode +
        periods.hashCode +
        timing.hashCode +
        annualIncrease.hashCode +
        annualRate.hashCode +
        years.hashCode +
        convention.hashCode +
        inflation.hashCode +
        taxOnWithdrawal.hashCode;

  factory CompoundIn.fromJson(Map<String, dynamic> json) => _$CompoundInFromJson(json);

  Map<String, dynamic> toJson() => _$CompoundInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum CompoundInPeriodsEnum {
@JsonValue(12)
number12('12'),
@JsonValue(1)
number1('1');

const CompoundInPeriodsEnum(this.value);

final String value;

@override
String toString() => value;
}



enum CompoundInTimingEnum {
@JsonValue(r'inicio')
inicio(r'inicio'),
@JsonValue(r'final')
final_(r'final');

const CompoundInTimingEnum(this.value);

final String value;

@override
String toString() => value;
}



enum CompoundInConventionEnum {
@JsonValue(r'nominal')
nominal(r'nominal'),
@JsonValue(r'efectivo')
efectivo(r'efectivo');

const CompoundInConventionEnum(this.value);

final String value;

@override
String toString() => value;
}


