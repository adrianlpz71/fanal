//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'installment_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InstallmentOut {
  /// Returns a new [InstallmentOut] instance.
  InstallmentOut({

    required  this.seq,

    required  this.dueDate,

    required  this.amount,

    required  this.status,

    required  this.movementId,
  });

  @JsonKey(
    
    name: r'seq',
    required: true,
    includeIfNull: false,
  )


  final int seq;



  @JsonKey(
    
    name: r'due_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime dueDate;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final String status;



  @JsonKey(
    
    name: r'movement_id',
    required: true,
    includeIfNull: true,
  )


  final String? movementId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InstallmentOut &&
      other.seq == seq &&
      other.dueDate == dueDate &&
      other.amount == amount &&
      other.status == status &&
      other.movementId == movementId;

    @override
    int get hashCode =>
        seq.hashCode +
        dueDate.hashCode +
        amount.hashCode +
        status.hashCode +
        (movementId == null ? 0 : movementId.hashCode);

  factory InstallmentOut.fromJson(Map<String, dynamic> json) => _$InstallmentOutFromJson(json);

  Map<String, dynamic> toJson() => _$InstallmentOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

