// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetCommentModel _$GetCommentModelFromJson(Map<String, dynamic> json) {
  return GetCommentModel(
    id: json['id'] as int,
    content: json['content'] as String,
    mangaId: json['mangaId'] as int,
    mangaName: json['mangaName'] as String,
    createdUserId: json['createdUserId'] as int,
    createdUsername: json['createdUsername'] as String,
    createdUserProfileUrl: json['createdUserProfileUrl'] as String,
    createdDateInMilliSeconds: json['createdDateInMilliSeconds'] as int,
    updatedDateInMilliSeconds: json['updatedDateInMilliSeconds'] as int,
    uploaderId: json['uploaderId'] as int,
    uploaderReadStatus: json['uploaderReadStatus'] as bool,
    type: json['type'] as String,
    mentionedUserReadStatus: json['mentionedUserReadStatus'] as bool,
    mentionedUserId: json['mentionedUserId'] as int?,
    mentionedUsername: json['mentionedUsername'] as String?,
    replied: json['replied'] as bool?,
  );
}

Map<String, dynamic> _$GetCommentModelToJson(GetCommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
      'mangaId': instance.mangaId,
      'mangaName': instance.mangaName,
      'createdUserId': instance.createdUserId,
      'createdUsername': instance.createdUsername,
      'createdUserProfileUrl': instance.createdUserProfileUrl,
      'createdDateInMilliSeconds': instance.createdDateInMilliSeconds,
      'updatedDateInMilliSeconds': instance.updatedDateInMilliSeconds,
      'uploaderId': instance.uploaderId,
      'uploaderReadStatus': instance.uploaderReadStatus,
      'type': instance.type,
      'mentionedUserReadStatus': instance.mentionedUserReadStatus,
      'mentionedUserId': instance.mentionedUserId,
      'mentionedUsername': instance.mentionedUsername,
      'replied': instance.replied,
    };
