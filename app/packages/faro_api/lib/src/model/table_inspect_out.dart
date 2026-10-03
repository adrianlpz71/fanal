//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:json_annotation/json_annotation.dart';

part 'table_inspect_out.g.dart';


@JsonSerializable(
  checked: true,
  createToJson: true,
  disallowUnrecognizedKeys: false,
  explicitToJson: true,
)
class TableInspectOut {
  /// Returns a new [TableInspectOut] instance.
  TableInspectOut({

    required  this.rows,

    required  this.suggested,

    required  this.message,
  });

  @JsonKey(
    
    name: r'rows',
    required: true,
    includeIfNull: false,
  )


  final List<List<String>> rows;



  @JsonKey(
    
    name: r'suggested',
    required: true,
    includeIfNull: true,
  )


  final Map<String, Object>? suggested;



  @JsonKey(
    
    name: r'message',
    required: true,
    includeIfNull: true,
  )


  final String? message;





    @override
    bool operator ==(Object other) => identical(this, other) || other is TableInspectOut &&
      other.rows == rows &&
      other.suggested == suggested &&
      other.message == message;

    @override
    int get hashCode =>
        rows.hashCode +
        (suggested == null ? 0 : suggested.hashCode) +
        (message == null ? 0 : message.hashCode);

  factory TableInspectOut.fromJson(Map<String, dynamic> json) => _$TableInspectOutFromJson(json);

  Map<String, dynamic> toJson() => _$TableInspectOutToJson(this);

  @override
  String toString() {
    return toJson().toString();
  }

}

