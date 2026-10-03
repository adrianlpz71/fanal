//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'net_worth_point_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class NetWorthPointOut {
  /// Returns a new [NetWorthPointOut] instance.
  NetWorthPointOut({

    required  this.date,

    required  this.accounts,

    required  this.investments,
  });

  @JsonKey(
    
    name: r'date',
    required: true,
    includeIfNull: false,
  )


  final DateTime date;



  @JsonKey(
    
    name: r'accounts',
    required: true,
    includeIfNull: false,
  )


  final String accounts;



  @JsonKey(
    
    name: r'investments',
    required: true,
    includeIfNull: false,
  )


  final String investments;





    @override
    bool operator ==(Object other) => identical(this, other) || other is NetWorthPointOut &&
      other.date == date &&
      other.accounts == accounts &&
      other.investments == investments;

    @override
    int get hashCode =>
        date.hashCode +
        accounts.hashCode +
        investments.hashCode;

  factory NetWorthPointOut.fromJson(Map<String, dynamic> json) => _$NetWorthPointOutFromJson(json);

  Map<String, dynamic> toJson() => _$NetWorthPointOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

