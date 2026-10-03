//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'compound_year_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompoundYearOut {
  /// Returns a new [CompoundYearOut] instance.
  CompoundYearOut({

    required  this.year,

    required  this.contributed,

    required  this.interest,

    required  this.total,

    required  this.realTotal,
  });

  @JsonKey(
    
    name: r'year',
    required: true,
    includeIfNull: false,
  )


  final int year;



  @JsonKey(
    
    name: r'contributed',
    required: true,
    includeIfNull: false,
  )


  final String contributed;



  @JsonKey(
    
    name: r'interest',
    required: true,
    includeIfNull: false,
  )


  final String interest;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final String total;



  @JsonKey(
    
    name: r'real_total',
    required: true,
    includeIfNull: false,
  )


  final String realTotal;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompoundYearOut &&
      other.year == year &&
      other.contributed == contributed &&
      other.interest == interest &&
      other.total == total &&
      other.realTotal == realTotal;

    @override
    int get hashCode =>
        year.hashCode +
        contributed.hashCode +
        interest.hashCode +
        total.hashCode +
        realTotal.hashCode;

  factory CompoundYearOut.fromJson(Map<String, dynamic> json) => _$CompoundYearOutFromJson(json);

  Map<String, dynamic> toJson() => _$CompoundYearOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

