//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'account_balance_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AccountBalanceOut {
  /// Returns a new [AccountBalanceOut] instance.
  AccountBalanceOut({

    required  this.id,

    required  this.name,

    required  this.kind,

    required  this.balance,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final String kind;



  @JsonKey(
    
    name: r'balance',
    required: true,
    includeIfNull: false,
  )


  final String balance;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AccountBalanceOut &&
      other.id == id &&
      other.name == name &&
      other.kind == kind &&
      other.balance == balance;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        kind.hashCode +
        balance.hashCode;

  factory AccountBalanceOut.fromJson(Map<String, dynamic> json) => _$AccountBalanceOutFromJson(json);

  Map<String, dynamic> toJson() => _$AccountBalanceOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

