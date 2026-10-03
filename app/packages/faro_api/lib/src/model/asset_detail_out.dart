//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/tx_out.dart';
import 'package:faro_api/src/model/realized_out.dart';
import 'package:faro_api/src/model/lot_out.dart';
import 'package:faro_api/src/model/position_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'asset_detail_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class AssetDetailOut {
  /// Returns a new [AssetDetailOut] instance.
  AssetDetailOut({

    required  this.position,

    required  this.lots,

    required  this.realized,

    required  this.income,

    required  this.transactions,
  });

  @JsonKey(
    
    name: r'position',
    required: true,
    includeIfNull: false,
  )


  final PositionOut position;



  @JsonKey(
    
    name: r'lots',
    required: true,
    includeIfNull: false,
  )


  final List<LotOut> lots;



  @JsonKey(
    
    name: r'realized',
    required: true,
    includeIfNull: false,
  )


  final List<RealizedOut> realized;



  @JsonKey(
    
    name: r'income',
    required: true,
    includeIfNull: false,
  )


  final String income;



  @JsonKey(
    
    name: r'transactions',
    required: true,
    includeIfNull: false,
  )


  final List<TxOut> transactions;





    @override
    bool operator ==(Object other) => identical(this, other) || other is AssetDetailOut &&
      other.position == position &&
      other.lots == lots &&
      other.realized == realized &&
      other.income == income &&
      other.transactions == transactions;

    @override
    int get hashCode =>
        position.hashCode +
        lots.hashCode +
        realized.hashCode +
        income.hashCode +
        transactions.hashCode;

  factory AssetDetailOut.fromJson(Map<String, dynamic> json) => _$AssetDetailOutFromJson(json);

  Map<String, dynamic> toJson() => _$AssetDetailOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

