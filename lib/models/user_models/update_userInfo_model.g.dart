// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_userInfo_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateUserInfoModel _$UpdateUserInfoModelFromJson(Map<String, dynamic> json) {
  return UpdateUserInfoModel(
    id: json['id'] as int,
    username: json['username'] as String,
    payment: json['payment'] as String?,
    description: json['description'] as String?,
    type: json['type'] as String?,
    profile: json['profile'] as String?,
  );
}

Map<String, dynamic> _$UpdateUserInfoModelToJson(
        UpdateUserInfoModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'payment': instance.payment,
      'description': instance.description,
      'type': instance.type,
      'profile': instance.profile,
    };

UpdateUserPassword _$UpdateUserPasswordFromJson(Map<String, dynamic> json) {
  return UpdateUserPassword(
    oldPassword: json['oldPassword'] as String,
    newPassword: json['newPassword'] as String,
  );
}

Map<String, dynamic> _$UpdateUserPasswordToJson(UpdateUserPassword instance) =>
    <String, dynamic>{
      'oldPassword': instance.oldPassword,
      'newPassword': instance.newPassword,
    };
