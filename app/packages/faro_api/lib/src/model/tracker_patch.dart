//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'tracker_patch.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TrackerPatch {
  /// Returns a new [TrackerPatch] instance.
  TrackerPatch({

     this.name,

     this.openingBalance,

     this.openingDate,

     this.categoryIds,

     this.keywords,

     this.archived,

     this.notes,
  });

  @JsonKey(
    
    name: r'name',
    required: false,
    includeIfNull: false,
  )


  final String? name;



  @JsonKey(
    
    name: r'opening_balance',
    required: false,
    includeIfNull: false,
  )


  final String? openingBalance;



  @JsonKey(
    
    name: r'opening_date',
    required: false,
    includeIfNull: false,
  )


  final DateTime? openingDate;



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
    
    name: r'archived',
    required: false,
    includeIfNull: false,
  )


  final bool? archived;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TrackerPatch &&
      other.name == name &&
      other.openingBalance == openingBalance &&
      other.openingDate == openingDate &&
      other.categoryIds == categoryIds &&
      other.keywords == keywords &&
      other.archived == archived &&
      other.notes == notes;

    @override
    int get hashCode =>
        (name == null ? 0 : name.hashCode) +
        (openingBalance == null ? 0 : openingBalance.hashCode) +
        (openingDate == null ? 0 : openingDate.hashCode) +
        (categoryIds == null ? 0 : categoryIds.hashCode) +
        (keywords == null ? 0 : keywords.hashCode) +
        (archived == null ? 0 : archived.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory TrackerPatch.fromJson(Map<String, dynamic> json) => _$TrackerPatchFromJson(json);

  Map<String, dynamic> toJson() => _$TrackerPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

