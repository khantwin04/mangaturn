// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetUserModel _$GetUserModelFromJson(Map<String, dynamic> json) {
  return GetUserModel(
    id: json['id'] as int,
    username: json['username'] as String,
    role: json['role'] as String?,
    payment: json['payment'] as String?,
    profileUrl: json['profileUrl'] as String?,
    point: json['point'] as int,
    type: json['type'] as String?,
    description: json['description'] as String?,
    createdDateInMilliSeconds: json['createdDateInMilliSeconds'] as int,
    updatedDateInMilliSeconds: json['updatedDateInMilliSeconds'] as int,
  );
}

Map<String, dynamic> _$GetUserModelToJson(GetUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'role': instance.role,
      'payment': instance.payment,
      'profileUrl': instance.profileUrl,
      'point': instance.point,
      'type': instance.type,
      'description': instance.description,
      'createdDateInMilliSeconds': instance.createdDateInMilliSeconds,
      'updatedDateInMilliSeconds': instance.updatedDateInMilliSeconds,
    };
