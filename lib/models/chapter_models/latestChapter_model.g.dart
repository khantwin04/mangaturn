// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'latestChapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LatestChapterModel _$LatestChapterModelFromJson(Map<String, dynamic> json) {
  return LatestChapterModel(
    id: json['id'] as int,
    chapterName: json['chapterName'] as String,
    chapterNo: json['chapterNo'] as int,
    type: json['type'] as String,
    point: json['point'] as int,
    totalPages: json['totalPages'] as int,
    isPurchase: json['isPurchase'] as bool?,
    pages: json['pages'] as List<dynamic>,
    manga: MangaModel.fromJson(json['manga'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$LatestChapterModelToJson(LatestChapterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chapterName': instance.chapterName,
      'chapterNo': instance.chapterNo,
      'type': instance.type,
      'point': instance.point,
      'totalPages': instance.totalPages,
      'isPurchase': instance.isPurchase,
      'pages': instance.pages,
      'manga': instance.manga,
    };
