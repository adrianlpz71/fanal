//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/account_balance_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'net_worth_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NetWorthOut {
  /// Returns a new [NetWorthOut] instance.
  NetWorthOut({

    required  this.total,

    required  this.accounts,

    required  this.investments,

    required  this.pending,

    required  this.byType,

    required  this.receivable,

    required  this.debts,

    required  this.installments,

    required  this.unrealizedGain,

    required  this.taxIfSold,

    required  this.afterTax,

    required  this.taxYear,

    required  this.taxSource,
  });

  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final String total;



  @JsonKey(
    
    name: r'accounts',
    required: true,
    includeIfNull: false,
  )


  final List<AccountBalanceOut> accounts;



  @JsonKey(
    
    name: r'investments',
    required: true,
    includeIfNull: false,
  )


  final String investments;



  @JsonKey(
    
    name: r'pending',
    required: true,
    includeIfNull: false,
  )


  final String pending;



  @JsonKey(
    
    name: r'by_type',
    required: true,
    includeIfNull: false,
  )


  final Map<String, String> byType;



  @JsonKey(
    
    name: r'receivable',
    required: true,
    includeIfNull: false,
  )


  final String receivable;



  @JsonKey(
    
    name: r'debts',
    required: true,
    includeIfNull: false,
  )


  final String debts;



  @JsonKey(
    
    name: r'installments',
    required: true,
    includeIfNull: false,
  )


  final String installments;



  @JsonKey(
    
    name: r'unrealized_gain',
    required: true,
    includeIfNull: false,
  )


  final String unrealizedGain;



  @JsonKey(
    
    name: r'tax_if_sold',
    required: true,
    includeIfNull: true,
  )


  final String? taxIfSold;



  @JsonKey(
    
    name: r'after_tax',
    required: true,
    includeIfNull: true,
  )


  final String? afterTax;



  @JsonKey(
    
    name: r'tax_year',
    required: true,
    includeIfNull: true,
  )


  final int? taxYear;



  @JsonKey(
    
    name: r'tax_source',
    required: true,
    includeIfNull: true,
  )


  final String? taxSource;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NetWorthOut &&
      other.total == total &&
      other.accounts == accounts &&
      other.investments == investments &&
      other.pending == pending &&
      other.byType == byType &&
      other.receivable == receivable &&
      other.debts == debts &&
      other.installments == installments &&
      other.unrealizedGain == unrealizedGain &&
      other.taxIfSold == taxIfSold &&
      other.afterTax == afterTax &&
      other.taxYear == taxYear &&
      other.taxSource == taxSource;

    @override
    int get hashCode =>
        total.hashCode +
        accounts.hashCode +
        investments.hashCode +
        pending.hashCode +
        byType.hashCode +
        receivable.hashCode +
        debts.hashCode +
        installments.hashCode +
        unrealizedGain.hashCode +
        (taxIfSold == null ? 0 : taxIfSold.hashCode) +
        (afterTax == null ? 0 : afterTax.hashCode) +
        (taxYear == null ? 0 : taxYear.hashCode) +
        (taxSource == null ? 0 : taxSource.hashCode);

  factory NetWorthOut.fromJson(Map<String, dynamic> json) => _$NetWorthOutFromJson(json);

  Map<String, dynamic> toJson() => _$NetWorthOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

