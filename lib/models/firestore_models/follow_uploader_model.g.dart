// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'follow_uploader_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FollowModel _$FollowModelFromJson(Map<String, dynamic> json) {
  return FollowModel(
    userId: json['userId'] as int,
    userName: json['userName'] as String,
    userCover: json['userCover'] as String,
    userMessenger: json['userMessenger'] as String,
  );
}

Map<String, dynamic> _$FollowModelToJson(FollowModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'userName': instance.userName,
      'userCover': instance.userCover,
      'userMessenger': instance.userMessenger,
    };
