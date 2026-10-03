//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/installment_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'installment_plan_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InstallmentPlanOut {
  /// Returns a new [InstallmentPlanOut] instance.
  InstallmentPlanOut({

    required  this.id,

    required  this.description,

    required  this.merchant,

    required  this.provider,

    required  this.total,

    required  this.n,

    required  this.everyMonths,

    required  this.firstDue,

    required  this.fee,

    required  this.status,

    required  this.categoryId,

    required  this.paid,

    required  this.remainingAmount,

    required  this.nextDue,

    required  this.installments,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'description',
    required: true,
    includeIfNull: false,
  )


  final String description;



  @JsonKey(
    
    name: r'merchant',
    required: true,
    includeIfNull: false,
  )


  final String merchant;



  @JsonKey(
    
    name: r'provider',
    required: true,
    includeIfNull: false,
  )


  final InstallmentPlanOutProviderEnum provider;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final String total;



  @JsonKey(
    
    name: r'n',
    required: true,
    includeIfNull: false,
  )


  final int n;



  @JsonKey(
    
    name: r'every_months',
    required: true,
    includeIfNull: false,
  )


  final int everyMonths;



  @JsonKey(
    
    name: r'first_due',
    required: true,
    includeIfNull: false,
  )


  final DateTime firstDue;



  @JsonKey(
    
    name: r'fee',
    required: true,
    includeIfNull: false,
  )


  final String fee;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'paid',
    required: true,
    includeIfNull: false,
  )


  final int paid;



  @JsonKey(
    
    name: r'remaining_amount',
    required: true,
    includeIfNull: false,
  )


  final String remainingAmount;



  @JsonKey(
    
    name: r'next_due',
    required: true,
    includeIfNull: true,
  )


  final DateTime? nextDue;



  @JsonKey(
    
    name: r'installments',
    required: true,
    includeIfNull: false,
  )


  final List<InstallmentOut> installments;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InstallmentPlanOut &&
      other.id == id &&
      other.description == description &&
      other.merchant == merchant &&
      other.provider == provider &&
      other.total == total &&
      other.n == n &&
      other.everyMonths == everyMonths &&
      other.firstDue == firstDue &&
      other.fee == fee &&
      other.status == status &&
      other.categoryId == categoryId &&
      other.paid == paid &&
      other.remainingAmount == remainingAmount &&
      other.nextDue == nextDue &&
      other.installments == installments;

    @override
    int get hashCode =>
        id.hashCode +
        description.hashCode +
        merchant.hashCode +
        provider.hashCode +
        total.hashCode +
        n.hashCode +
        everyMonths.hashCode +
        firstDue.hashCode +
        fee.hashCode +
        status.hashCode +
        (categoryId == null ? 0 : categoryId.hashCode) +
        paid.hashCode +
        remainingAmount.hashCode +
        (nextDue == null ? 0 : nextDue.hashCode) +
        installments.hashCode;

  factory InstallmentPlanOut.fromJson(Map<String, dynamic> json) => _$InstallmentPlanOutFromJson(json);

  Map<String, dynamic> toJson() => _$InstallmentPlanOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum InstallmentPlanOutProviderEnum {
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

const InstallmentPlanOutProviderEnum(this.value);

final String value;

@override
String toString() => value;
}


