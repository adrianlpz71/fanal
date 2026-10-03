//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'movement_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MovementIn {
  /// Returns a new [MovementIn] instance.
  MovementIn({

     this.id,

    required  this.concept,

     this.amount,

     this.expression,

     this.kind,

     this.status,

     this.date,

     this.dueDate,

     this.accountId,

     this.cycleId,

     this.month,

     this.categoryId,

     this.notes,

     this.toAccountId,
  });

  @JsonKey(
    
    name: r'id',
    required: false,
    includeIfNull: false,
  )


  final String? id;



  @JsonKey(
    
    name: r'concept',
    required: true,
    includeIfNull: false,
  )


  final String concept;



  @JsonKey(
    
    name: r'amount',
    required: false,
    includeIfNull: false,
  )


  final String? amount;



  @JsonKey(
    
    name: r'expression',
    required: false,
    includeIfNull: false,
  )


  final String? expression;



  @JsonKey(
    
    name: r'kind',
    required: false,
    includeIfNull: false,
  )


  final MovementInKindEnum? kind;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final MovementInStatusEnum? status;



  @JsonKey(
    
    name: r'date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? date;



  @JsonKey(
    
    name: r'due_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? dueDate;



  @JsonKey(
    
    name: r'account_id',
    required: false,
    includeIfNull: false,
  )


  final String? accountId;



  @JsonKey(
    
    name: r'cycle_id',
    required: false,
    includeIfNull: false,
  )


  final String? cycleId;



  @JsonKey(
    
    name: r'month',
    required: false,
    includeIfNull: false,
  )


  final String? month;



  @JsonKey(
    
    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;



  @JsonKey(
    
    name: r'to_account_id',
    required: false,
    includeIfNull: false,
  )


  final String? toAccountId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MovementIn &&
      other.id == id &&
      other.concept == concept &&
      other.amount == amount &&
      other.expression == expression &&
      other.kind == kind &&
      other.status == status &&
      other.date == date &&
      other.dueDate == dueDate &&
      other.accountId == accountId &&
      other.cycleId == cycleId &&
      other.month == month &&
      other.categoryId == categoryId &&
      other.notes == notes &&
      other.toAccountId == toAccountId;

    @override
    int get hashCode =>
        (id == null ? 0 : id.hashCode) +
        concept.hashCode +
        (amount == null ? 0 : amount.hashCode) +
        (expression == null ? 0 : expression.hashCode) +
        kind.hashCode +
        status.hashCode +
        (date == null ? 0 : date.hashCode) +
        (dueDate == null ? 0 : dueDate.hashCode) +
        (accountId == null ? 0 : accountId.hashCode) +
        (cycleId == null ? 0 : cycleId.hashCode) +
        (month == null ? 0 : month.hashCode) +
        (categoryId == null ? 0 : categoryId.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        (toAccountId == null ? 0 : toAccountId.hashCode);

  factory MovementIn.fromJson(Map<String, dynamic> json) => _$MovementInFromJson(json);

  Map<String, dynamic> toJson() => _$MovementInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MovementInKindEnum {
@JsonValue(r'gasto')
gasto(r'gasto'),
@JsonValue(r'ingreso')
ingreso(r'ingreso'),
@JsonValue(r'nomina')
nomina(r'nomina'),
@JsonValue(r'transferencia')
transferencia(r'transferencia'),
@JsonValue(r'reembolso')
reembolso(r'reembolso'),
@JsonValue(r'ajuste')
ajuste(r'ajuste');

const MovementInKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum MovementInStatusEnum {
@JsonValue(r'planned')
planned(r'planned'),
@JsonValue(r'posted')
posted(r'posted');

const MovementInStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


