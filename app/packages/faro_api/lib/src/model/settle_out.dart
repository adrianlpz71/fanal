//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/share_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'settle_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class SettleOut {
  /// Returns a new [SettleOut] instance.
  SettleOut({

    required  this.share,

    required  this.movementId,
  });

  @JsonKey(
    
    name: r'share',
    required: true,
    includeIfNull: false,
  )


  final ShareOut share;



  @JsonKey(
    
    name: r'movement_id',
    required: true,
    includeIfNull: true,
  )


  final String? movementId;





    @override
    bool operator ==(Object other) => identical(this, other) || other is SettleOut &&
      other.share == share &&
      other.movementId == movementId;

    @override
    int get hashCode =>
        share.hashCode +
        (movementId == null ? 0 : movementId.hashCode);

  factory SettleOut.fromJson(Map<String, dynamic> json) => _$SettleOutFromJson(json);

  Map<String, dynamic> toJson() => _$SettleOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

