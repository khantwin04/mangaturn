// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCommentModel _$UpdateCommentModelFromJson(Map<String, dynamic> json) {
  return UpdateCommentModel(
    id: json['id'] as int,
    content: json['content'] as String,
  );
}

Map<String, dynamic> _$UpdateCommentModelToJson(UpdateCommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'content': instance.content,
    };
