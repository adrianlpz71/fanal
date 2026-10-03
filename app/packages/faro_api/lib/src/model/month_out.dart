//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/month_item_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'month_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class MonthOut {
  /// Returns a new [MonthOut] instance.
  MonthOut({

    required  this.label,

    required  this.ym,

    required  this.start,

    required  this.end,

    required  this.payroll,

    required  this.recurring,

    required  this.installments,

    required  this.other,

    required  this.free,

    required  this.cumulative,

    required  this.items,
  });

  @JsonKey(
    
    name: r'label',
    required: true,
    includeIfNull: false,
  )


  final String label;



  @JsonKey(
    
    name: r'ym',
    required: true,
    includeIfNull: false,
  )


  final String ym;



  @JsonKey(
    
    name: r'start',
    required: true,
    includeIfNull: false,
  )


  final DateTime start;



  @JsonKey(
    
    name: r'end',
    required: true,
    includeIfNull: false,
  )


  final DateTime end;



  @JsonKey(
    
    name: r'payroll',
    required: true,
    includeIfNull: false,
  )


  final String payroll;



  @JsonKey(
    
    name: r'recurring',
    required: true,
    includeIfNull: false,
  )


  final String recurring;



  @JsonKey(
    
    name: r'installments',
    required: true,
    includeIfNull: false,
  )


  final String installments;



  @JsonKey(
    
    name: r'other',
    required: true,
    includeIfNull: false,
  )


  final String other;



  @JsonKey(
    
    name: r'free',
    required: true,
    includeIfNull: false,
  )


  final String free;



  @JsonKey(
    
    name: r'cumulative',
    required: true,
    includeIfNull: false,
  )


  final String cumulative;



  @JsonKey(
    
    name: r'items',
    required: true,
    includeIfNull: false,
  )


  final List<MonthItemOut> items;





    @override
    bool operator ==(Object other) => identical(this, other) || other is MonthOut &&
      other.label == label &&
      other.ym == ym &&
      other.start == start &&
      other.end == end &&
      other.payroll == payroll &&
      other.recurring == recurring &&
      other.installments == installments &&
      other.other == other &&
      other.free == free &&
      other.cumulative == cumulative &&
      other.items == items;

    @override
    int get hashCode =>
        label.hashCode +
        ym.hashCode +
        start.hashCode +
        end.hashCode +
        payroll.hashCode +
        recurring.hashCode +
        installments.hashCode +
        other.hashCode +
        free.hashCode +
        cumulative.hashCode +
        items.hashCode;

  factory MonthOut.fromJson(Map<String, dynamic> json) => _$MonthOutFromJson(json);

  Map<String, dynamic> toJson() => _$MonthOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

