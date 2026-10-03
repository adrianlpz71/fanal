//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tax_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TaxIn {
  /// Returns a new [TaxIn] instance.
  TaxIn({

     this.baseGeneral = '0',

     this.baseSavings = '0',

     this.netWealth,

     this.homeValue,

     this.rememberBaseGeneral = false,
  });

  @JsonKey(
    defaultValue: '0',
    name: r'base_general',
    required: false,
    includeIfNull: false,
  )


  final String? baseGeneral;



  @JsonKey(
    defaultValue: '0',
    name: r'base_savings',
    required: false,
    includeIfNull: false,
  )


  final String? baseSavings;



  @JsonKey(
    
    name: r'net_wealth',
    required: false,
    includeIfNull: false,
  )


  final String? netWealth;



  @JsonKey(
    
    name: r'home_value',
    required: false,
    includeIfNull: false,
  )


  final String? homeValue;



      /// Guardar la base general para prellenarla la próxima vez
  @JsonKey(
    defaultValue: false,
    name: r'remember_base_general',
    required: false,
    includeIfNull: false,
  )


  final bool? rememberBaseGeneral;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TaxIn &&
      other.baseGeneral == baseGeneral &&
      other.baseSavings == baseSavings &&
      other.netWealth == netWealth &&
      other.homeValue == homeValue &&
      other.rememberBaseGeneral == rememberBaseGeneral;

    @override
    int get hashCode =>
        baseGeneral.hashCode +
        baseSavings.hashCode +
        (netWealth == null ? 0 : netWealth.hashCode) +
        (homeValue == null ? 0 : homeValue.hashCode) +
        rememberBaseGeneral.hashCode;

  factory TaxIn.fromJson(Map<String, dynamic> json) => _$TaxInFromJson(json);

  Map<String, dynamic> toJson() => _$TaxInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

