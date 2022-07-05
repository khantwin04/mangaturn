import 'package:json_annotation/json_annotation.dart';
part 'requestPointModel.g.dart';

@JsonSerializable()
class RequestPointModel{
  String? remark;
  String? receipt;

  RequestPointModel({ this.receipt,  this.remark});

  Map<String, dynamic> toJson() => _$RequestPointModelToJson(this);
}