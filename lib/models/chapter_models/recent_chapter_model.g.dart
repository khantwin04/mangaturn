// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recent_chapter_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RecentChapterModel _$RecentChapterModelFromJson(Map<String, dynamic> json) {
  return RecentChapterModel(
    mangaId: json['mangaId'] as int?,
    mangaName: json['mangaName'] as String?,
    chapterId: json['chapterId'] as int?,
    chapterName: json['chapterName'] as String?,
    resumePageNo: json['resumePageNo'] as int?,
    resumePosition: (json['resumePosition'] as num?)?.toDouble(),
    totalPage: json['totalPage'] as int?,
    maxScrollPosition: (json['maxScrollPosition'] as num?)?.toDouble(),
    resumeImage: json['resumeImage'] as String?,
  );
}

Map<String, dynamic> _$RecentChapterModelToJson(RecentChapterModel instance) =>
    <String, dynamic>{
      'mangaId': instance.mangaId,
      'mangaName': instance.mangaName,
      'chapterId': instance.chapterId,
      'chapterName': instance.chapterName,
      'resumePageNo': instance.resumePageNo,
      'resumePosition': instance.resumePosition,
      'totalPage': instance.totalPage,
      'maxScrollPosition': instance.maxScrollPosition,
      'resumeImage': instance.resumeImage,
    };
