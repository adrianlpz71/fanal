//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'sell_preview_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SellPreviewIn {
  /// Returns a new [SellPreviewIn] instance.
  SellPreviewIn({

    required  this.amount,

     this.assetId,

     this.baseGeneral = '0',

     this.baseSavings = '0',
  });

  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'asset_id',
    required: false,
    includeIfNull: false,
  )


  final String? assetId;



  @JsonKey(
    defaultValue: '0',
    name: r'base_general',
    required: false,
    includeIfNull: false,
  )


  final String? baseGeneral;



  @JsonKey(
    defaultValue: '0',
    name: r'base_savings',
    required: false,
    includeIfNull: false,
  )


  final String? baseSavings;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SellPreviewIn &&
      other.amount == amount &&
      other.assetId == assetId &&
      other.baseGeneral == baseGeneral &&
      other.baseSavings == baseSavings;

    @override
    int get hashCode =>
        amount.hashCode +
        (assetId == null ? 0 : assetId.hashCode) +
        baseGeneral.hashCode +
        baseSavings.hashCode;

  factory SellPreviewIn.fromJson(Map<String, dynamic> json) => _$SellPreviewInFromJson(json);

  Map<String, dynamic> toJson() => _$SellPreviewInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

