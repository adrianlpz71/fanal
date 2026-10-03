//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'advance_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AdvanceOut {
  /// Returns a new [AdvanceOut] instance.
  AdvanceOut({

    required  this.moved,

    required  this.amount,
  });

  @JsonKey(
    
    name: r'moved',
    required: true,
    includeIfNull: false,
  )


  final int moved;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AdvanceOut &&
      other.moved == moved &&
      other.amount == amount;

    @override
    int get hashCode =>
        moved.hashCode +
        amount.hashCode;

  factory AdvanceOut.fromJson(Map<String, dynamic> json) => _$AdvanceOutFromJson(json);

  Map<String, dynamic> toJson() => _$AdvanceOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

