//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'price_change_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PriceChangeOut {
  /// Returns a new [PriceChangeOut] instance.
  PriceChangeOut({

    required  this.id,

    required  this.oldAmount,

    required  this.newAmount,

    required  this.detectedAt,
  });

  @JsonKey(
    
    name: r'id',
    required: true,
    includeIfNull: false,
  )


  final String id;



  @JsonKey(
    
    name: r'old_amount',
    required: true,
    includeIfNull: false,
  )


  final String oldAmount;



  @JsonKey(
    
    name: r'new_amount',
    required: true,
    includeIfNull: false,
  )


  final String newAmount;



  @JsonKey(
    
    name: r'detected_at',
    required: true,
    includeIfNull: false,
  )


  final String detectedAt;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PriceChangeOut &&
      other.id == id &&
      other.oldAmount == oldAmount &&
      other.newAmount == newAmount &&
      other.detectedAt == detectedAt;

    @override
    int get hashCode =>
        id.hashCode +
        oldAmount.hashCode +
        newAmount.hashCode +
        detectedAt.hashCode;

  factory PriceChangeOut.fromJson(Map<String, dynamic> json) => _$PriceChangeOutFromJson(json);

  Map<String, dynamic> toJson() => _$PriceChangeOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

