//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'contribution_item_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class ContributionItemOut {
  /// Returns a new [ContributionItemOut] instance.
  ContributionItemOut({

    required  this.date,

    required  this.type,

    required  this.kind,

    required  this.destination,

    required  this.destinationLabel,

    required  this.amount,

    required  this.origin,

    required  this.status,

    required  this.txId,

    required  this.movementId,

    required  this.assetId,

    required  this.accountId,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'type',
    required: true,
    includeIfNull: false,
  )


  final ContributionItemOutTypeEnum type;



  @JsonKey(
    
    name: r'kind',
    required: true,
    includeIfNull: false,
  )


  final ContributionItemOutKindEnum kind;



  @JsonKey(
    
    name: r'destination',
    required: true,
    includeIfNull: false,
  )


  final String destination;



  @JsonKey(
    
    name: r'destination_label',
    required: true,
    includeIfNull: false,
  )


  final String destinationLabel;



  @JsonKey(
    
    name: r'amount',
    required: true,
    includeIfNull: false,
  )


  final String amount;



  @JsonKey(
    
    name: r'origin',
    required: true,
    includeIfNull: false,
  )


  final String origin;



  @JsonKey(
    
    name: r'status',
    required: true,
    includeIfNull: false,
  )


  final ContributionItemOutStatusEnum status;



  @JsonKey(
    
    name: r'tx_id',
    required: true,
    includeIfNull: true,
  )


  final String? txId;



  @JsonKey(
    
    name: r'movement_id',
    required: true,
    includeIfNull: true,
  )


  final String? movementId;



  @JsonKey(
    
    name: r'asset_id',
    required: true,
    includeIfNull: true,
  )


  final String? assetId;



  @JsonKey(
    
    name: r'account_id',
    required: true,
    includeIfNull: true,
  )


  final String? accountId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is ContributionItemOut &&
      other.date == date &&
      other.type == type &&
      other.kind == kind &&
      other.destination == destination &&
      other.destinationLabel == destinationLabel &&
      other.amount == amount &&
      other.origin == origin &&
      other.status == status &&
      other.txId == txId &&
      other.movementId == movementId &&
      other.assetId == assetId &&
      other.accountId == accountId;

    @override
    int get hashCode =>
        date.hashCode +
        type.hashCode +
        kind.hashCode +
        destination.hashCode +
        destinationLabel.hashCode +
        amount.hashCode +
        origin.hashCode +
        status.hashCode +
        (txId == null ? 0 : txId.hashCode) +
        (movementId == null ? 0 : movementId.hashCode) +
        (assetId == null ? 0 : assetId.hashCode) +
        (accountId == null ? 0 : accountId.hashCode);

  factory ContributionItemOut.fromJson(Map<String, dynamic> json) => _$ContributionItemOutFromJson(json);

  Map<String, dynamic> toJson() => _$ContributionItemOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}


enum ContributionItemOutTypeEnum {
@JsonValue(r'aportacion')
aportacion(r'aportacion'),
@JsonValue(r'retirada')
retirada(r'retirada'),
@JsonValue(r'traspaso')
traspaso(r'traspaso'),
@JsonValue(r'partida')
partida(r'partida');

const ContributionItemOutTypeEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ContributionItemOutKindEnum {
@JsonValue(r'inversion')
inversion(r'inversion'),
@JsonValue(r'ahorro')
ahorro(r'ahorro');

const ContributionItemOutKindEnum(this.value);

final String value;

@override
String toString() => value;
}



enum ContributionItemOutStatusEnum {
@JsonValue(r'confirmada')
confirmada(r'confirmada'),
@JsonValue(r'pendiente')
pendiente(r'pendiente');

const ContributionItemOutStatusEnum(this.value);

final String value;

@override
String toString() => value;
}


