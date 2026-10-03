//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'transfer_in.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TransferIn {
  /// Returns a new [TransferIn] instance.
  TransferIn({

    required  this.fromAssetId,

    required  this.toAssetId,

    required  this.tradeDate,

    required  this.unitsOut,

    required  this.unitsIn,

    required  this.amountEur,
  });

  @JsonKey(
    
    name: r'from_asset_id',
    required: true,
    includeIfNull: false,
  )


  final String fromAssetId;



  @JsonKey(
    
    name: r'to_asset_id',
    required: true,
    includeIfNull: false,
  )


  final String toAssetId;



  @JsonKey(
    
    name: r'trade_date',
    required: true,
    includeIfNull: false,
  )


  final DateTime tradeDate;



  @JsonKey(
    
    name: r'units_out',
    required: true,
    includeIfNull: false,
  )


  final String unitsOut;



  @JsonKey(
    
    name: r'units_in',
    required: true,
    includeIfNull: false,
  )


  final String unitsIn;



      /// Valor del traspaso (informativo)
  @JsonKey(
    
    name: r'amount_eur',
    required: true,
    includeIfNull: false,
  )


  final String amountEur;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TransferIn &&
      other.fromAssetId == fromAssetId &&
      other.toAssetId == toAssetId &&
      other.tradeDate == tradeDate &&
      other.unitsOut == unitsOut &&
      other.unitsIn == unitsIn &&
      other.amountEur == amountEur;

    @override
    int get hashCode =>
        fromAssetId.hashCode +
        toAssetId.hashCode +
        tradeDate.hashCode +
        unitsOut.hashCode +
        unitsIn.hashCode +
        amountEur.hashCode;

  factory TransferIn.fromJson(Map<String, dynamic> json) => _$TransferInFromJson(json);

  Map<String, dynamic> toJson() => _$TransferInToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

