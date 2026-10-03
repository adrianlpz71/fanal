//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/tracker_cycle_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'tracker_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TrackerOut {
  /// Returns a new [TrackerOut] instance.
  TrackerOut({

    required  this.id,

    required  this.name,

    required  this.openingBalance,

    required  this.openingDate,

    required  this.categoryIds,

    required  this.keywords,

    required  this.archived,

    required  this.notes,

    required  this.balance,

    required  this.movementsCount,

    required  this.byCycle,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'name',
    required: true,
    includeIfNull: false,
  )


  final String name;



  @JsonKey(
    
    name: r'opening_balance',
    required: true,
    includeIfNull: false,
  )


  final String openingBalance;



  @JsonKey(
    
    name: r'opening_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime openingDate;



  @JsonKey(
    
    name: r'category_ids',
    required: true,
    includeIfNull: false,
  )


  final List<String> categoryIds;



  @JsonKey(
    
    name: r'keywords',
    required: true,
    includeIfNull: false,
  )


  final List<String> keywords;



  @JsonKey(
    
    name: r'archived',
    required: true,
    includeIfNull: false,
  )


  final bool archived;



  @JsonKey(
    
    name: r'notes',
    required: true,
    includeIfNull: true,
  )


  final String? notes;



  @JsonKey(
    
    name: r'balance',
    required: true,
    includeIfNull: false,
  )


  final String balance;



  @JsonKey(
    
    name: r'movements_count',
    required: true,
    includeIfNull: false,
  )


  final int movementsCount;



  @JsonKey(
    
    name: r'by_cycle',
    required: true,
    includeIfNull: false,
  )


  final List<TrackerCycleOut> byCycle;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TrackerOut &&
      other.id == id &&
      other.name == name &&
      other.openingBalance == openingBalance &&
      other.openingDate == openingDate &&
      other.categoryIds == categoryIds &&
      other.keywords == keywords &&
      other.archived == archived &&
      other.notes == notes &&
      other.balance == balance &&
      other.movementsCount == movementsCount &&
      other.byCycle == byCycle;

    @override
    int get hashCode =>
        id.hashCode +
        name.hashCode +
        openingBalance.hashCode +
        openingDate.hashCode +
        categoryIds.hashCode +
        keywords.hashCode +
        archived.hashCode +
        (notes == null ? 0 : notes.hashCode) +
        balance.hashCode +
        movementsCount.hashCode +
        byCycle.hashCode;

  factory TrackerOut.fromJson(Map<String, dynamic> json) => _$TrackerOutFromJson(json);

  Map<String, dynamic> toJson() => _$TrackerOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

