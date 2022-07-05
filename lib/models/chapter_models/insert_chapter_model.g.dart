// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insert_chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsertChapterModel _$InsertChapterModelFromJson(Map<String, dynamic> json) {
  return InsertChapterModel(
    chapterName: json['chapterName'] as String,
    chapterNo: json['chapterNo'] as int,
    type: json['type'] as String,
    point: json['point'] as int,
    mangaId: json['mangaId'] as int,
    pages: (json['pages'] as List<dynamic>)
        .map((e) => InsertPageModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$InsertChapterModelToJson(InsertChapterModel instance) =>
    <String, dynamic>{
      'chapterName': instance.chapterName,
      'chapterNo': instance.chapterNo,
      'type': instance.type,
      'point': instance.point,
      'mangaId': instance.mangaId,
      'pages': instance.pages,
    };

InsertPageModel _$InsertPageModelFromJson(Map<String, dynamic> json) {
  return InsertPageModel(
    id: json['id'] as int?,
    pageNo: json['pageNo'] as int,
    content: json['content'] as String?,
  );
}

Map<String, dynamic> _$InsertPageModelToJson(InsertPageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageNo': instance.pageNo,
      'content': instance.content,
    };

InsertPageModelNoContent _$InsertPageModelNoContentFromJson(
    Map<String, dynamic> json) {
  return InsertPageModelNoContent(
    id: json['id'] as int,
    pageNo: json['pageNo'] as int,
  );
}

Map<String, dynamic> _$InsertPageModelNoContentToJson(
        InsertPageModelNoContent instance) =>
    <String, dynamic>{
      'id': instance.id,
      'pageNo': instance.pageNo,
    };
