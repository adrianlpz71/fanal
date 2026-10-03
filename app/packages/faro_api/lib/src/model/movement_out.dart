//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/share_brief_out.dart';
import 'package:faro_api/src/model/movement_line_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'movement_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MovementOut {
  /// Returns a new [MovementOut] instance.
  MovementOut({

    required  this.id,

    required  this.accountId,

    required  this.cycleId,

    required  this.date,

    required  this.dueDate,

    required  this.kind,

    required  this.status,

    required  this.concept,

    required  this.amount,

    required  this.expression,

    required  this.lines,

    required  this.categoryId,

    required  this.source_,

    required  this.sourceRef,

    required  this.notes,

     this.debtId,

     this.refundOfId,

    required  this.shares,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'account_id',
    required: true,
    includeIfNull: false,
  )


  final String accountId;



  @JsonKey(
    
    name: r'cycle_id',
    required: true,
    includeIfNull: true,
  )


  final String? cycleId;



  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? date;



  @JsonKey(
    
    name: r'due_date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? dueDate;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final MovementOutKindEnum kind;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final MovementOutStatusEnum status;



  @JsonKey(
    
    name: r'concept',
    required: true,
    includeIfNull: false,
  )


  final String concept;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'expression',
    required: true,
    includeIfNull: true,
  )


  final String? expression;



  @JsonKey(
    
    name: r'lines',
    required: true,
    includeIfNull: false,
  )


  final List<MovementLineOut> lines;



  @JsonKey(
    
    name: r'category_id',
    required: true,
    includeIfNull: true,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'source',
    required: true,
    includeIfNull: false,
  )


  final String source_;



  @JsonKey(
    
    name: r'source_ref',
    required: true,
    includeIfNull: true,
  )


  final String? sourceRef;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: true,
  )


  final String? notes;



  @JsonKey(
    
    name: r'debt_id',
    required: false,
    includeIfNull: false,
  )


  final String? debtId;



  @JsonKey(
    
    name: r'refund_of_id',
    required: false,
    includeIfNull: false,
  )


  final String? refundOfId;



  @JsonKey(
    
    name: r'shares',
    required: true,
    includeIfNull: false,
  )


  final List<ShareBriefOut> shares;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MovementOut &&
      other.id == id &&
      other.accountId == accountId &&
      other.cycleId == cycleId &&
      other.date == date &&
      other.dueDate == dueDate &&
      other.kind == kind &&
      other.status == status &&
      other.concept == concept &&
      other.amount == amount &&
      other.expression == expression &&
      other.lines == lines &&
      other.categoryId == categoryId &&
      other.source_ == source_ &&
      other.sourceRef == sourceRef &&
      other.notes == notes &&
      other.debtId == debtId &&
      other.refundOfId == refundOfId &&
      other.shares == shares;

    @override
    int get hashCode =>
        id.hashCode +
        accountId.hashCode +
        (cycleId == null ? 0 : cycleId.hashCode) +
        (date == null ? 0 : date.hashCode) +
        (dueDate == null ? 0 : dueDate.hashCode) +
        kind.hashCode +
        status.hashCode +
        concept.hashCode +
        amount.hashCode +
        (expression == null ? 0 : expression.hashCode) +
        lines.hashCode +
        (categoryId == null ? 0 : categoryId.hashCode) +
        source_.hashCode +
        (sourceRef == null ? 0 : sourceRef.hashCode) +
        (notes == null ? 0 : notes.hashCode) +
        (debtId == null ? 0 : debtId.hashCode) +
        (refundOfId == null ? 0 : refundOfId.hashCode) +
        shares.hashCode;

  factory MovementOut.fromJson(Map<String, dynamic> json) => _$MovementOutFromJson(json);

  Map<String, dynamic> toJson() => _$MovementOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum MovementOutKindEnum {
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

const MovementOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum MovementOutStatusEnum {
@JsonValue(r'planned')
planned(r'planned'),
@JsonValue(r'posted')
posted(r'posted'),
@JsonValue(r'cancelled')
cancelled(r'cancelled');

const MovementOutStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


