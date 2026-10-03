//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'reconcile_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReconcileOut {
  /// Returns a new [ReconcileOut] instance.
  ReconcileOut({

    required  this.computed,

    required  this.real,

    required  this.difference,

    required  this.adjustmentId,
  });

  @JsonKey(
    
    name: r'computed',
    required: true,
    includeIfNull: false,
  )


  final String computed;



  @JsonKey(
    
    name: r'real',
    required: true,
    includeIfNull: false,
  )


  final String real;



  @JsonKey(
    
    name: r'difference',
    required: true,
    includeIfNull: false,
  )


  final String difference;



  @JsonKey(
    
    name: r'adjustment_id',
    required: true,
    includeIfNull: true,
  )


  final String? adjustmentId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReconcileOut &&
      other.computed == computed &&
      other.real == real &&
      other.difference == difference &&
      other.adjustmentId == adjustmentId;

    @override
    int get hashCode =>
        computed.hashCode +
        real.hashCode +
        difference.hashCode +
        (adjustmentId == null ? 0 : adjustmentId.hashCode);

  factory ReconcileOut.fromJson(Map<String, dynamic> json) => _$ReconcileOutFromJson(json);

  Map<String, dynamic> toJson() => _$ReconcileOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

