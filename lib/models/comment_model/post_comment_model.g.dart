// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PostCommentModel _$PostCommentModelFromJson(Map<String, dynamic> json) {
  return PostCommentModel(
    mangaId: json['mangaId'] as int,
    chapterId: json['chapterId'] as int?,
    type: json['type'] as String?,
    mentionedUserId: json['mentionedUserId'] as int?,
    content: json['content'] as String,
  );
}

Map<String, dynamic> _$PostCommentModelToJson(PostCommentModel instance) =>
    <String, dynamic>{
      'mangaId': instance.mangaId,
      'chapterId': instance.chapterId,
      'type': instance.type,
      'mentionedUserId': instance.mentionedUserId,
      'content': instance.content,
    };
