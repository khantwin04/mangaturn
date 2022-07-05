// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadedByUserModel _$UploadedByUserModelFromJson(Map<String, dynamic> json) {
  return UploadedByUserModel(
    id: json['id'] as int,
    username: json['username'] as String,
    profileUrl: json['profileUrl'] as String?,
    description: json['description'] as String?,
  );
}

Map<String, dynamic> _$UploadedByUserModelToJson(
        UploadedByUserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'profileUrl': instance.profileUrl,
      'description': instance.description,
    };
