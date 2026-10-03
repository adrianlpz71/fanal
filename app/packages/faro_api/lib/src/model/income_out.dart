//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'income_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class IncomeOut {
  /// Returns a new [IncomeOut] instance.
  IncomeOut({

    required  this.source_,

    required  this.date,

    required  this.amount,

    required  this.kind,
  });

  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;



  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final IncomeOutKindEnum kind;





    @override
    bool operator ==(Object other) => identical(this, other) || other is IncomeOut &&
      other.source_ == source_ &&
      other.date == date &&
      other.amount == amount &&
      other.kind == kind;

    @override
    int get hashCode =>
        source_.hashCode +
        date.hashCode +
        amount.hashCode +
        kind.hashCode;

  factory IncomeOut.fromJson(Map<String, dynamic> json) => _$IncomeOutFromJson(json);

  Map<String, dynamic> toJson() => _$IncomeOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum IncomeOutKindEnum {
@JsonValue(r'interes_cuenta')
interesCuenta(r'interes_cuenta'),
@JsonValue(r'dividendo')
dividendo(r'dividendo'),
@JsonValue(r'interes')
interes(r'interes'),
@JsonValue(r'recompensa_cripto')
recompensaCripto(r'recompensa_cripto');

const IncomeOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


