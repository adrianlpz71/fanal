//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'account_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountOut {
  /// Returns a new [AccountOut] instance.
  AccountOut({

    required  this.id,

    required  this.kind,

    required  this.name,

    required  this.bank,

    required  this.balance,

    required  this.balanceWithPlanned,

    required  this.archived,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final AccountOutKindEnum kind;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'bank',
    required: true,
    includeIfNull: false,
  )


  final String bank;



  @JsonKey(
    
    name: r'balance',
    required: true,
    includeIfNull: false,
  )


  final String balance;



  @JsonKey(
    
    name: r'balance_with_planned',
    required: true,
    includeIfNull: false,
  )


  final String balanceWithPlanned;



  @JsonKey(
    
    name: r'archived',
    required: true,
    includeIfNull: false,
  )


  final bool archived;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AccountOut &&
      other.id == id &&
      other.kind == kind &&
      other.name == name &&
      other.bank == bank &&
      other.balance == balance &&
      other.balanceWithPlanned == balanceWithPlanned &&
      other.archived == archived;

    @override
    int get hashCode =>
        id.hashCode +
        kind.hashCode +
        name.hashCode +
        bank.hashCode +
        balance.hashCode +
        balanceWithPlanned.hashCode +
        archived.hashCode;

  factory AccountOut.fromJson(Map<String, dynamic> json) => _$AccountOutFromJson(json);

  Map<String, dynamic> toJson() => _$AccountOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum AccountOutKindEnum {
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

const AccountOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}


