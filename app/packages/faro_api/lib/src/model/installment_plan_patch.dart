//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'installment_plan_patch.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class InstallmentPlanPatch {
  /// Returns a new [InstallmentPlanPatch] instance.
  InstallmentPlanPatch({

     this.description,

     this.merchant,

     this.categoryId,

     this.notes,
  });

  @JsonKey(
    
    name: r'description',
    required: false,
    includeIfNull: false,
  )


  final String? description;



  @JsonKey(
    
    name: r'merchant',
    required: false,
    includeIfNull: false,
  )


  final String? merchant;



  @JsonKey(
    
    name: r'category_id',
    required: false,
    includeIfNull: false,
  )


  final String? categoryId;



  @JsonKey(
    
    name: r'notes',
    required: false,
    includeIfNull: false,
  )


  final String? notes;





    @override
    bool operator ==(Object other) => identical(this, other) || other is InstallmentPlanPatch &&
      other.description == description &&
      other.merchant == merchant &&
      other.categoryId == categoryId &&
      other.notes == notes;

    @override
    int get hashCode =>
        (description == null ? 0 : description.hashCode) +
        (merchant == null ? 0 : merchant.hashCode) +
        (categoryId == null ? 0 : categoryId.hashCode) +
        (notes == null ? 0 : notes.hashCode);

  factory InstallmentPlanPatch.fromJson(Map<String, dynamic> json) => _$InstallmentPlanPatchFromJson(json);

  Map<String, dynamic> toJson() => _$InstallmentPlanPatchToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

