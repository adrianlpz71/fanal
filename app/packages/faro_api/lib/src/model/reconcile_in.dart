//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'reconcile_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ReconcileIn {
  /// Returns a new [ReconcileIn] instance.
  ReconcileIn({

    required  this.realBalance,

     this.createAdjustment = true,
  });

  @JsonKey(
    
    name: r'real_balance',
    required: true,
    includeIfNull: false,
  )


  final String realBalance;



  @JsonKey(
    defaultValue: true,
    name: r'create_adjustment',
    required: false,
    includeIfNull: false,
  )


  final bool? createAdjustment;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ReconcileIn &&
      other.realBalance == realBalance &&
      other.createAdjustment == createAdjustment;

    @override
    int get hashCode =>
        realBalance.hashCode +
        createAdjustment.hashCode;

  factory ReconcileIn.fromJson(Map<String, dynamic> json) => _$ReconcileInFromJson(json);

  Map<String, dynamic> toJson() => _$ReconcileInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

