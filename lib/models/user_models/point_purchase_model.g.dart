// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_purchase_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllPointPurchaseModel _$GetAllPointPurchaseModelFromJson(
    Map<String, dynamic> json) {
  return GetAllPointPurchaseModel(
    pointPurchaseList: (json['pointPurchaseList'] as List<dynamic>)
        .map((e) => PointPurchaseModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    page: json['page'] as int,
    size: json['size'] as int,
    numberofElements: json['numberofElements'] as int,
    totalElements: json['totalElements'] as int,
    totalPages: json['totalPages'] as int,
  );
}

Map<String, dynamic> _$GetAllPointPurchaseModelToJson(
        GetAllPointPurchaseModel instance) =>
    <String, dynamic>{
      'pointPurchaseList': instance.pointPurchaseList,
      'page': instance.page,
      'size': instance.size,
      'numberofElements': instance.numberofElements,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
    };

PointPurchaseModel _$PointPurchaseModelFromJson(Map<String, dynamic> json) {
  return PointPurchaseModel(
    id: json['id'] as int,
    point: json['point'] as int?,
    requestedDateInMilliSeconds: json['requestedDateInMilliSeconds'] as int,
    status: json['status'] as String,
    remark: json['remark'] as String?,
    adminRemark: json['adminRemark'] as String?,
    userId: json['userId'] as int,
    username: json['username'] as String,
    receiptUrl: json['receiptUrl'] as String,
  );
}

Map<String, dynamic> _$PointPurchaseModelToJson(PointPurchaseModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'point': instance.point,
      'requestedDateInMilliSeconds': instance.requestedDateInMilliSeconds,
      'status': instance.status,
      'remark': instance.remark,
      'adminRemark': instance.adminRemark,
      'userId': instance.userId,
      'username': instance.username,
      'receiptUrl': instance.receiptUrl,
    };
