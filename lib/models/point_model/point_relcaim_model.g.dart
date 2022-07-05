// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'point_relcaim_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllPointReclaimList _$GetAllPointReclaimListFromJson(
    Map<String, dynamic> json) {
  return GetAllPointReclaimList(
    pointReclaimList: (json['pointReclaimList'] as List<dynamic>)
        .map((e) => PointReclaimModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    page: json['page'] as int,
    size: json['size'] as int,
    numberofElements: json['numberofElements'] as int,
    totalElements: json['totalElements'] as int,
    totalPages: json['totalPages'] as int,
  );
}

Map<String, dynamic> _$GetAllPointReclaimListToJson(
        GetAllPointReclaimList instance) =>
    <String, dynamic>{
      'pointReclaimList': instance.pointReclaimList,
      'page': instance.page,
      'size': instance.size,
      'numberofElements': instance.numberofElements,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
    };

PointReclaimModel _$PointReclaimModelFromJson(Map<String, dynamic> json) {
  return PointReclaimModel(
    id: json['id'] as int,
    point: json['point'] as int,
    postDateInMilliSeconds: json['postDateInMilliSeconds'] as int,
    confirmDateInMilliSeconds: json['confirmDateInMilliSeconds'] as int?,
    status: json['status'] as String,
    remark: json['remark'] as String?,
    adminRemark: json['adminRemark'] as String?,
    userId: json['userId'] as int,
    username: json['username'] as String,
  );
}

Map<String, dynamic> _$PointReclaimModelToJson(PointReclaimModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'point': instance.point,
      'postDateInMilliSeconds': instance.postDateInMilliSeconds,
      'confirmDateInMilliSeconds': instance.confirmDateInMilliSeconds,
      'status': instance.status,
      'remark': instance.remark,
      'adminRemark': instance.adminRemark,
      'userId': instance.userId,
      'username': instance.username,
    };
