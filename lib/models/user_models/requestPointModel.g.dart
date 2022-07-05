// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'requestPointModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RequestPointModel _$RequestPointModelFromJson(Map<String, dynamic> json) {
  return RequestPointModel(
    receipt: json['receipt'] as String?,
    remark: json['remark'] as String?,
  );
}

Map<String, dynamic> _$RequestPointModelToJson(RequestPointModel instance) =>
    <String, dynamic>{
      'remark': instance.remark,
      'receipt': instance.receipt,
    };
