//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/compound_year_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'compound_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class CompoundOut {
  /// Returns a new [CompoundOut] instance.
  CompoundOut({

    required  this.rows,

    required  this.total,

    required  this.contributed,

    required  this.interest,

    required  this.realTotal,

    required  this.taxIfWithdrawn,

    required  this.netIfWithdrawn,

    required  this.conventionNote,
  });

  @JsonKey(
    
    name: r'rows',
    required: true,
    includeIfNull: false,
  )


  final List<CompoundYearOut> rows;



  @JsonKey(
    
    name: r'total',
    required: true,
    includeIfNull: false,
  )


  final String total;



  @JsonKey(
    
    name: r'contributed',
    required: true,
    includeIfNull: false,
  )


  final String contributed;



  @JsonKey(
    
    name: r'interest',
    required: true,
    includeIfNull: false,
  )


  final String interest;



  @JsonKey(
    
    name: r'real_total',
    required: true,
    includeIfNull: false,
  )


  final String realTotal;



  @JsonKey(
    
    name: r'tax_if_withdrawn',
    required: true,
    includeIfNull: true,
  )


  final String? taxIfWithdrawn;



  @JsonKey(
    
    name: r'net_if_withdrawn',
    required: true,
    includeIfNull: true,
  )


  final String? netIfWithdrawn;



  @JsonKey(
    
    name: r'convention_note',
    required: true,
    includeIfNull: false,
  )


  final String conventionNote;





    @override
    bool operator ==(Object other) => identical(this, other) || other is CompoundOut &&
      other.rows == rows &&
      other.total == total &&
      other.contributed == contributed &&
      other.interest == interest &&
      other.realTotal == realTotal &&
      other.taxIfWithdrawn == taxIfWithdrawn &&
      other.netIfWithdrawn == netIfWithdrawn &&
      other.conventionNote == conventionNote;

    @override
    int get hashCode =>
        rows.hashCode +
        total.hashCode +
        contributed.hashCode +
        interest.hashCode +
        realTotal.hashCode +
        (taxIfWithdrawn == null ? 0 : taxIfWithdrawn.hashCode) +
        (netIfWithdrawn == null ? 0 : netIfWithdrawn.hashCode) +
        conventionNote.hashCode;

  factory CompoundOut.fromJson(Map<String, dynamic> json) => _$CompoundOutFromJson(json);

  Map<String, dynamic> toJson() => _$CompoundOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

