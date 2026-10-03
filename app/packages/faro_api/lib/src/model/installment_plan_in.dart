//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'installment_plan_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InstallmentPlanIn {
  /// Returns a new [InstallmentPlanIn] instance.
  InstallmentPlanIn({

    required  this.description,

     this.merchant = '',

     this.provider,

    required  this.total,

    required  this.n,

    required  this.firstDue,

     this.everyMonths = 1,

     this.fee = '0',

     this.categoryId,

     this.customAmounts,

     this.paidCount = 0,
  });

  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



  @JsonKey(
    defaultValue: '',
    name: r'merchant',
    required: false,
    includeIfNull: false,
  )


  final String? merchant;



  @JsonKey(
    
    name: r'provider',
    required: false,
    includeIfNull: false,
  )


  final InstallmentPlanInProviderEnum? provider;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final String total;



          // minimum: 1
          // maximum: 120
  @JsonKey(
    
    name: r'n',
    required: true,
    includeIfNull: false,
  )


  final int n;



  @JsonKey(
    
    name: r'first_due',
    required: true,
    includeIfNull: false,
  )


  final DateTime firstDue;



          // minimum: 1
          // maximum: 12
  @JsonKey(
    defaultValue: 1,
    name: r'every_months',
    required: false,
    includeIfNull: false,
  )


  final int? everyMonths;



  @JsonKey(
    defaultValue: '0',
    name: r'fee',
    required: false,
    includeIfNull: false,
  )


  final String? fee;



  @JsonKey(
    
    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'custom_amounts',
    required: false,
    includeIfNull: false,
  )


  final List<String>? customAmounts;



      /// Cuotas ya pagadas antes de darla de alta
          // minimum: 0
  @JsonKey(
    defaultValue: 0,
    name: r'paid_count',
    required: false,
    includeIfNull: false,
  )


  final int? paidCount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InstallmentPlanIn &&
      other.description == description &&
      other.merchant == merchant &&
      other.provider == provider &&
      other.total == total &&
      other.n == n &&
      other.firstDue == firstDue &&
      other.everyMonths == everyMonths &&
      other.fee == fee &&
      other.categoryId == categoryId &&
      other.customAmounts == customAmounts &&
      other.paidCount == paidCount;

    @override
    int get hashCode =>
        description.hashCode +
        merchant.hashCode +
        provider.hashCode +
        total.hashCode +
        n.hashCode +
        firstDue.hashCode +
        everyMonths.hashCode +
        fee.hashCode +
        (categoryId == null ? 0 : categoryId.hashCode) +
        (customAmounts == null ? 0 : customAmounts.hashCode) +
        paidCount.hashCode;

  factory InstallmentPlanIn.fromJson(Map<String, dynamic> json) => _$InstallmentPlanInFromJson(json);

  Map<String, dynamic> toJson() => _$InstallmentPlanInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum InstallmentPlanInProviderEnum {
@JsonValue(r'paypal')
paypal(r'paypal'),
@JsonValue(r'klarna')
klarna(r'klarna'),
@JsonValue(r'tarjeta')
tarjeta(r'tarjeta'),
@JsonValue(r'amazon')
amazon(r'amazon'),
@JsonValue(r'eci')
eci(r'eci'),
@JsonValue(r'otro')
otro(r'otro');

const InstallmentPlanInProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


