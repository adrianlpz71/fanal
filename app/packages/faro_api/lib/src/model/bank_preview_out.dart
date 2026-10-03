//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:faro_api/src/model/bank_line_out.dart';
import 'package:json_annotation/json_annotation.dart';

part 'bank_preview_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class BankPreviewOut {
  /// Returns a new [BankPreviewOut] instance.
  BankPreviewOut({

    required  this.headers,

    required  this.mapping,

    required  this.counts,

    required  this.errors,

    required  this.lines,

    required  this.fileBalance,

    required  this.balanceAfter,
  });

  @JsonKey(
    
    name: r'headers',
    required: true,
    includeIfNull: false,
  )


  final List<String> headers;



  @JsonKey(
    
    name: r'mapping',
    required: true,
    includeIfNull: false,
  )


  final Map<String, Object> mapping;



  @JsonKey(
    
    name: r'counts',
    required: true,
    includeIfNull: false,
  )


  final Map<String, int> counts;



  @JsonKey(
    
    name: r'errors',
    required: true,
    includeIfNull: false,
  )


  final List<String> errors;



  @JsonKey(
    
    name: r'lines',
    required: true,
    includeIfNull: false,
  )


  final List<BankLineOut> lines;



  @JsonKey(
    
    name: r'file_balance',
    required: true,
    includeIfNull: true,
  )


  final String? fileBalance;



  @JsonKey(
    
    name: r'balance_after',
    required: true,
    includeIfNull: false,
  )


  final String balanceAfter;





    @override
    bool operator ==(Object other) => identical(this, other) || other is BankPreviewOut &&
      other.headers == headers &&
      other.mapping == mapping &&
      other.counts == counts &&
      other.errors == errors &&
      other.lines == lines &&
      other.fileBalance == fileBalance &&
      other.balanceAfter == balanceAfter;

    @override
    int get hashCode =>
        headers.hashCode +
        mapping.hashCode +
        counts.hashCode +
        errors.hashCode +
        lines.hashCode +
        (fileBalance == null ? 0 : fileBalance.hashCode) +
        balanceAfter.hashCode;

  factory BankPreviewOut.fromJson(Map<String, dynamic> json) => _$BankPreviewOutFromJson(json);

  Map<String, dynamic> toJson() => _$BankPreviewOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

