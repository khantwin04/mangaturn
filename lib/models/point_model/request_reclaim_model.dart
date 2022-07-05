import 'package:json_annotation/json_annotation.dart';
part 'request_reclaim_model.g.dart';

@JsonSerializable()
class RequestReclaimModel {
  final int point;
  final String remark;

  RequestReclaimModel({required this.point,required  this.remark});

  Map<String, dynamic> toJson() => _$RequestReclaimModelToJson(this);
}
