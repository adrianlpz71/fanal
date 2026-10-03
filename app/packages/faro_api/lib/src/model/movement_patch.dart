//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'movement_patch.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MovementPatch {
  /// Returns a new [MovementPatch] instance.
  MovementPatch({

     this.concept,

     this.amount,

     this.expression,

     this.kind,

     this.status,

     this.date,

     this.dueDate,

     this.cycleId,

     this.categoryId,

     this.notes,

     this.debtId,

     this.month,
  });

  @JsonKey(
    
    name: r'concept',
    required: false,
    includeIfNull: false,
  )


  final String? concept;



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


  final MovementPatchKindEnum? kind;



  @JsonKey(
    
    name: r'status',
    required: false,
    includeIfNull: false,
  )


  final MovementPatchStatusEnum? status;



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
    
    name: r'cycle_id',
    required: false,
    includeIfNull: false,
  )


  final String? cycleId;



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
    
    name: r'debt_id',
    required: false,
    includeIfNull: false,
  )


  final String? debtId;



  @JsonKey(
    
    name: r'month',
    required: false,
    includeIfNull: false,
  )


  final String? month;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MovementPatch &&
      other.concept == concept &&
      other.amount == amount &&
      other.expression == expression &&
      other.kind == kind &&
      other.status == status &&
      other.date == date &&
      other.dueDate == dueDate &&
      other.cycleId == cycleId &&
      other.categoryId == categoryId &&
      other.notes == notes &&
      other.debtId == debtId &&
      other.month == month;

    @override
    int get hashCode =>
        (concept == null ? 0 : concept.hashCode) +
        (amount == null ? 0 : amount.hashCode) +
        (expression == null ? 0 : expression.hashCode) +
        (kind == null ? 0 : kind.hashCode) +
        (status == null ? 0 : status.hashCode) +
        (date == null ? 0 : date.hashCode) +
        (dueDate == null ? 0 : dueDate.hashCode) +
        (cycleId == null ? 0 : cycleId.hashCode) +
        (categoryId == null ? 0 : categoryId.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        (debtId == null ? 0 : debtId.hashCode) +
        (month == null ? 0 : month.hashCode);

  factory MovementPatch.fromJson(Map<String, dynamic> json) => _$MovementPatchFromJson(json);

  Map<String, dynamic> toJson() => _$MovementPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MovementPatchKindEnum {
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

const MovementPatchKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum MovementPatchStatusEnum {
@JsonValue(r'planned')
planned(r'planned'),
@JsonValue(r'posted')
posted(r'posted'),
@JsonValue(r'cancelled')
cancelled(r'cancelled');

const MovementPatchStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


