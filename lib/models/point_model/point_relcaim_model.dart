import 'package:json_annotation/json_annotation.dart';
part 'point_relcaim_model.g.dart';

@JsonSerializable()
class GetAllPointReclaimList {
  final List<PointReclaimModel> pointReclaimList;
  final int page;
  final int size;
  final int numberofElements;
  final int totalElements;
  final int totalPages;

  GetAllPointReclaimList(
      {required this.pointReclaimList,
        required this.page,
        required this.size,
        required this.numberofElements,
        required this.totalElements,
        required this.totalPages});

  factory GetAllPointReclaimList.fromJson(Map<String, dynamic> json) =>
      _$GetAllPointReclaimListFromJson(json);
}

@JsonSerializable()
class PointReclaimModel {
  final int id;
  final int point;
  final int postDateInMilliSeconds;
  final int? confirmDateInMilliSeconds;
  final String status;
  final String? remark;
  final String? adminRemark;
  final int userId;
  final String username;

  PointReclaimModel(
      {required this.id,
        required this.point,
        required this.postDateInMilliSeconds,
         this.confirmDateInMilliSeconds,
        required this.status,
         this.remark,
         this.adminRemark,
        required this.userId,
        required this.username});

  factory PointReclaimModel.fromJson(Map<String, dynamic> json) =>
      _$PointReclaimModelFromJson(json);
}
