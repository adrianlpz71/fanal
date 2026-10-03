//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'account_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountIn {
  /// Returns a new [AccountIn] instance.
  AccountIn({

     this.id,

    required  this.kind,

    required  this.name,

     this.bank = '',

     this.openingBalance = '0',

     this.openingDate,

     this.apy,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final AccountInKindEnum kind;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    defaultValue: '',
    name: r'bank',
    required: false,
    includeIfNull: false,
  )


  final String? bank;



  @JsonKey(
    defaultValue: '0',
    name: r'opening_balance',
    required: false,
    includeIfNull: false,
  )


  final String? openingBalance;



  @JsonKey(
    
    name: r'opening_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? openingDate;



  @JsonKey(
    
    name: r'apy',
    required: false,
    includeIfNull: false,
  )


  final String? apy;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AccountIn &&
      other.id == id &&
      other.kind == kind &&
      other.name == name &&
      other.bank == bank &&
      other.openingBalance == openingBalance &&
      other.openingDate == openingDate &&
      other.apy == apy;

    @override
    int get hashCode =>
        (id == null ? 0 : id.hashCode) +
        kind.hashCode +
        name.hashCode +
        bank.hashCode +
        openingBalance.hashCode +
        (openingDate == null ? 0 : openingDate.hashCode) +
        (apy == null ? 0 : apy.hashCode);

  factory AccountIn.fromJson(Map<String, dynamic> json) => _$AccountInFromJson(json);

  Map<String, dynamic> toJson() => _$AccountInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AccountInKindEnum {
@JsonValue(r'gastos')
gastos(r'gastos'),
@JsonValue(r'refugio')
refugio(r'refugio'),
@JsonValue(r'ahorro')
ahorro(r'ahorro'),
@JsonValue(r'inversion')
inversion(r'inversion'),
@JsonValue(r'efectivo')
efectivo(r'efectivo'),
@JsonValue(r'otra')
otra(r'otra');

const AccountInKindEnum(this.value);

final String value;

@override
String toString() => value;
}


