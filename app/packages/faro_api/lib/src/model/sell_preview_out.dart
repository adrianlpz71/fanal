//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/sale_part_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'sell_preview_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SellPreviewOut {
  /// Returns a new [SellPreviewOut] instance.
  SellPreviewOut({

    required  this.amount,

    required  this.gain,

    required  this.tax,

    required  this.net,

    required  this.available,

    required  this.parts,
  });

  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'gain',
    required: true,
    includeIfNull: false,
  )


  final String gain;



      /// Lo que la venta añade a tu IRPF del año
  @JsonKey(
    
    name: r'tax',
    required: true,
    includeIfNull: false,
  )


  final String tax;



  @JsonKey(
    
    name: r'net',
    required: true,
    includeIfNull: false,
  )


  final String net;



  @JsonKey(
    
    name: r'available',
    required: true,
    includeIfNull: false,
  )


  final String available;



  @JsonKey(
    
    name: r'parts',
    required: true,
    includeIfNull: false,
  )


  final List<SalePartOut> parts;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SellPreviewOut &&
      other.amount == amount &&
      other.gain == gain &&
      other.tax == tax &&
      other.net == net &&
      other.available == available &&
      other.parts == parts;

    @override
    int get hashCode =>
        amount.hashCode +
        gain.hashCode +
        tax.hashCode +
        net.hashCode +
        available.hashCode +
        parts.hashCode;

  factory SellPreviewOut.fromJson(Map<String, dynamic> json) => _$SellPreviewOutFromJson(json);

  Map<String, dynamic> toJson() => _$SellPreviewOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

