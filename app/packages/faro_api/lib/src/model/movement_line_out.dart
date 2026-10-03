//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'movement_line_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MovementLineOut {
  /// Returns a new [MovementLineOut] instance.
  MovementLineOut({

    required  this.seq,

    required  this.amount,

    required  this.note,
  });

  @JsonKey(
    
    name: r'seq',
    required: true,
    includeIfNull: false,
  )


  final int seq;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'note',
    required: true,
    includeIfNull: true,
  )


  final String? note;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MovementLineOut &&
      other.seq == seq &&
      other.amount == amount &&
      other.note == note;

    @override
    int get hashCode =>
        seq.hashCode +
        amount.hashCode +
        (note == null ? 0 : note.hashCode);

  factory MovementLineOut.fromJson(Map<String, dynamic> json) => _$MovementLineOutFromJson(json);

  Map<String, dynamic> toJson() => _$MovementLineOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

