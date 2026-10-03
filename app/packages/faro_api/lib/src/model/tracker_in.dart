//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tracker_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TrackerIn {
  /// Returns a new [TrackerIn] instance.
  TrackerIn({

    required  this.name,

     this.openingBalance = '0',

    required  this.openingDate,

     this.categoryIds,

     this.keywords,

     this.notes,
  });

  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    defaultValue: '0',
    name: r'opening_balance',
    required: false,
    includeIfNull: false,
  )


  final String? openingBalance;



  @JsonKey(
    
    name: r'opening_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime openingDate;



  @JsonKey(
    
    name: r'category_ids',
    required: false,
    includeIfNull: false,
  )


  final List<String>? categoryIds;



  @JsonKey(
    
    name: r'keywords',
    required: false,
    includeIfNull: false,
  )


  final List<String>? keywords;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TrackerIn &&
      other.name == name &&
      other.openingBalance == openingBalance &&
      other.openingDate == openingDate &&
      other.categoryIds == categoryIds &&
      other.keywords == keywords &&
      other.notes == notes;

    @override
    int get hashCode =>
        name.hashCode +
        openingBalance.hashCode +
        openingDate.hashCode +
        categoryIds.hashCode +
        keywords.hashCode +
        (notes == null ? 0 : notes.hashCode);

  factory TrackerIn.fromJson(Map<String, dynamic> json) => _$TrackerInFromJson(json);

  Map<String, dynamic> toJson() => _$TrackerInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

