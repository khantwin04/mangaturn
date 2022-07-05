import 'package:json_annotation/json_annotation.dart';
part 'point_purchase_model.g.dart';

@JsonSerializable()
class GetAllPointPurchaseModel {
  final List<PointPurchaseModel> pointPurchaseList;
  final int page;
  final int size;
  final int numberofElements;
  final int totalElements;
  final int totalPages;

  GetAllPointPurchaseModel(
      {required this.pointPurchaseList,
        required this.page,
        required this.size,
        required this.numberofElements,
        required this.totalElements,
        required this.totalPages});

  factory GetAllPointPurchaseModel.fromJson(Map<String, dynamic> json) =>
      _$GetAllPointPurchaseModelFromJson(json);
}

@JsonSerializable()
class PointPurchaseModel {
  PointPurchaseModel({
    required this.id,
     this.point,
    required this.requestedDateInMilliSeconds,
    required this.status,
     this.remark,
     this.adminRemark,
    required this.userId,
    required this.username,
    required this.receiptUrl,
  });

  final int id;
  final int? point;
  final int requestedDateInMilliSeconds;
  final String status;
  final String? remark;
  final String? adminRemark;
  final int userId;
  final String username;
  final String receiptUrl;

  factory PointPurchaseModel.fromJson(Map<String, dynamic> json) => _$PointPurchaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$PointPurchaseModelToJson(this);
}
