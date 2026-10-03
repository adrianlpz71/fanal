//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/asset_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'position_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class PositionOut {
  /// Returns a new [PositionOut] instance.
  PositionOut({

    required  this.asset,

    required  this.units,

    required  this.avgCost,

    required  this.cost,

    required  this.price,

    required  this.priceDate,

    required  this.priceSource,

    required  this.stale,

    required  this.value,

    required  this.pnl,

    required  this.pnlPct,

    required  this.pending,

    required  this.innerWeight,

    required  this.innerTarget,

    required  this.innerStatus,
  });

  @JsonKey(
    
    name: r'asset',
    required: true,
    includeIfNull: false,
  )


  final AssetOut asset;



  @JsonKey(
    
    name: r'units',
    required: true,
    includeIfNull: false,
  )


  final String units;



  @JsonKey(
    
    name: r'avg_cost',
    required: true,
    includeIfNull: false,
  )


  final String avgCost;



  @JsonKey(
    
    name: r'cost',
    required: true,
    includeIfNull: false,
  )


  final String cost;



  @JsonKey(
    
    name: r'price',
    required: true,
    includeIfNull: true,
  )


  final String? price;



  @JsonKey(
    
    name: r'price_date',
    required: true,
    includeIfNull: true,
  )


  final DateTime? priceDate;



  @JsonKey(
    
    name: r'price_source',
    required: true,
    includeIfNull: true,
  )


  final String? priceSource;



  @JsonKey(
    
    name: r'stale',
    required: true,
    includeIfNull: false,
  )


  final bool stale;



  @JsonKey(
    
    name: r'value',
    required: true,
    includeIfNull: false,
  )


  final String value;



  @JsonKey(
    
    name: r'pnl',
    required: true,
    includeIfNull: false,
  )


  final String pnl;



  @JsonKey(
    
    name: r'pnl_pct',
    required: true,
    includeIfNull: true,
  )


  final String? pnlPct;



  @JsonKey(
    
    name: r'pending',
    required: true,
    includeIfNull: false,
  )


  final String pending;



  @JsonKey(
    
    name: r'inner_weight',
    required: true,
    includeIfNull: false,
  )


  final String innerWeight;



  @JsonKey(
    
    name: r'inner_target',
    required: true,
    includeIfNull: true,
  )


  final String? innerTarget;



  @JsonKey(
    
    name: r'inner_status',
    required: true,
    includeIfNull: true,
  )


  final PositionOutInnerStatusEnum? innerStatus;





    @override
    bool operator ==(Object other) => identical(this, other) || other is PositionOut &&
      other.asset == asset &&
      other.units == units &&
      other.avgCost == avgCost &&
      other.cost == cost &&
      other.price == price &&
      other.priceDate == priceDate &&
      other.priceSource == priceSource &&
      other.stale == stale &&
      other.value == value &&
      other.pnl == pnl &&
      other.pnlPct == pnlPct &&
      other.pending == pending &&
      other.innerWeight == innerWeight &&
      other.innerTarget == innerTarget &&
      other.innerStatus == innerStatus;

    @override
    int get hashCode =>
        asset.hashCode +
        units.hashCode +
        avgCost.hashCode +
        cost.hashCode +
        (price == null ? 0 : price.hashCode) +
        (priceDate == null ? 0 : priceDate.hashCode) +
        (priceSource == null ? 0 : priceSource.hashCode) +
        stale.hashCode +
        value.hashCode +
        pnl.hashCode +
        (pnlPct == null ? 0 : pnlPct.hashCode) +
        pending.hashCode +
        innerWeight.hashCode +
        (innerTarget == null ? 0 : innerTarget.hashCode) +
        (innerStatus == null ? 0 : innerStatus.hashCode);

  factory PositionOut.fromJson(Map<String, dynamic> json) => _$PositionOutFromJson(json);

  Map<String, dynamic> toJson() => _$PositionOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum PositionOutInnerStatusEnum {
@JsonValue(r'comprar')
comprar(r'comprar'),
@JsonValue(r'no_comprar')
noComprar(r'no_comprar'),
@JsonValue(r'ok')
ok(r'ok');

const PositionOutInnerStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


