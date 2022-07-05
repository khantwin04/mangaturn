// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChapterModel _$ChapterModelFromJson(Map<String, dynamic> json) {
  return ChapterModel(
    read: json['read'] as bool?,
    id: json['id'] as int,
    chapterName: json['chapterName'] as String,
    chapterNo: json['chapterNo'] as int,
    type: json['type'] as String,
    point: json['point'] as int,
    totalPages: json['totalPages'] as int,
    isPurchase: json['isPurchase'] as bool?,
    pages: json['pages'] as List<dynamic>?,
  );
}

Map<String, dynamic> _$ChapterModelToJson(ChapterModel instance) =>
    <String, dynamic>{
      'read': instance.read,
      'id': instance.id,
      'chapterName': instance.chapterName,
      'chapterNo': instance.chapterNo,
      'type': instance.type,
      'point': instance.point,
      'totalPages': instance.totalPages,
      'isPurchase': instance.isPurchase,
      'pages': instance.pages,
    };
