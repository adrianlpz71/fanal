//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'transfer_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TransferOut {
  /// Returns a new [TransferOut] instance.
  TransferOut({

    required  this.asset,

    required  this.date,

    required  this.units,
  });

  @JsonKey(
    
    name: r'asset',
    required: true,
    includeIfNull: false,
  )


  final String asset;



  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'units',
    required: true,
    includeIfNull: false,
  )


  final String units;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TransferOut &&
      other.asset == asset &&
      other.date == date &&
      other.units == units;

    @override
    int get hashCode =>
        asset.hashCode +
        date.hashCode +
        units.hashCode;

  factory TransferOut.fromJson(Map<String, dynamic> json) => _$TransferOutFromJson(json);

  Map<String, dynamic> toJson() => _$TransferOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

