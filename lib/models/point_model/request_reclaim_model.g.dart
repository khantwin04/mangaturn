// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_reclaim_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestReclaimModel _$RequestReclaimModelFromJson(Map<String, dynamic> json) {
  return RequestReclaimModel(
    point: json['point'] as int,
    remark: json['remark'] as String,
  );
}

Map<String, dynamic> _$RequestReclaimModelToJson(
        RequestReclaimModel instance) =>
    <String, dynamic>{
      'point': instance.point,
      'remark': instance.remark,
    };
