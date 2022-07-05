// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateChapterModel _$UpdateChapterModelFromJson(Map<String, dynamic> json) {
  return UpdateChapterModel(
    id: json['id'] as int,
    chapterName: json['chapterName'] as String,
    chapterNo: json['chapterNo'] as int,
    mangaId: json['mangaId'] as int,
    type: json['type'] as String,
    point: json['point'] as int,
    pages: (json['pages'] as List<dynamic>)
        .map((e) => InsertPageModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$UpdateChapterModelToJson(UpdateChapterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chapterName': instance.chapterName,
      'chapterNo': instance.chapterNo,
      'mangaId': instance.mangaId,
      'type': instance.type,
      'point': instance.point,
      'pages': instance.pages,
    };
