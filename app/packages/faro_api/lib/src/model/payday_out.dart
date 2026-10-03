//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/cycle_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'payday_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PaydayOut {
  /// Returns a new [PaydayOut] instance.
  PaydayOut({

    required  this.closedId,

    required  this.opened,

    required  this.discrepancy,

    required  this.carriedOver,

    required  this.cancelled,
  });

  @JsonKey(
    
    name: r'closed_id',
    required: true,
    includeIfNull: false,
  )


  final String closedId;



  @JsonKey(
    
    name: r'opened',
    required: true,
    includeIfNull: false,
  )


  final CycleOut opened;



  @JsonKey(
    
    name: r'discrepancy',
    required: true,
    includeIfNull: false,
  )


  final String discrepancy;



  @JsonKey(
    
    name: r'carried_over',
    required: true,
    includeIfNull: false,
  )


  final int carriedOver;



  @JsonKey(
    
    name: r'cancelled',
    required: true,
    includeIfNull: false,
  )


  final int cancelled;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PaydayOut &&
      other.closedId == closedId &&
      other.opened == opened &&
      other.discrepancy == discrepancy &&
      other.carriedOver == carriedOver &&
      other.cancelled == cancelled;

    @override
    int get hashCode =>
        closedId.hashCode +
        opened.hashCode +
        discrepancy.hashCode +
        carriedOver.hashCode +
        cancelled.hashCode;

  factory PaydayOut.fromJson(Map<String, dynamic> json) => _$PaydayOutFromJson(json);

  Map<String, dynamic> toJson() => _$PaydayOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

