//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'payday_undo_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaydayUndoOut {
  /// Returns a new [PaydayUndoOut] instance.
  PaydayUndoOut({

    required  this.available,

     this.reason,
  });

  @JsonKey(
    
    name: r'available',
    required: true,
    includeIfNull: false,
  )


  final bool available;



  @JsonKey(
    
    name: r'reason',
    required: false,
    includeIfNull: false,
  )


  final String? reason;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PaydayUndoOut &&
      other.available == available &&
      other.reason == reason;

    @override
    int get hashCode =>
        available.hashCode +
        (reason == null ? 0 : reason.hashCode);

  factory PaydayUndoOut.fromJson(Map<String, dynamic> json) => _$PaydayUndoOutFromJson(json);

  Map<String, dynamic> toJson() => _$PaydayUndoOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

