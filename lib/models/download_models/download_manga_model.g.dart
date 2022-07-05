// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_manga_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DownloadManga _$DownloadMangaFromJson(Map<String, dynamic> json) {
  return DownloadManga(
    mangaId: json['mangaId'] as int?,
    mangaName: json['mangaName'] as String?,
    mangaCover: json['mangaCover'] as String?,
  );
}

Map<String, dynamic> _$DownloadMangaToJson(DownloadManga instance) =>
    <String, dynamic>{
      'mangaId': instance.mangaId,
      'mangaName': instance.mangaName,
      'mangaCover': instance.mangaCover,
    };

DownloadChapter _$DownloadChapterFromJson(Map<String, dynamic> json) {
  return DownloadChapter(
    mangaId: json['mangaId'] as int?,
    chapterId: json['chapterId'] as int?,
    chapterName: json['chapterName'] as String?,
    totalPage: json['totalPage'] as int?,
  );
}

Map<String, dynamic> _$DownloadChapterToJson(DownloadChapter instance) =>
    <String, dynamic>{
      'mangaId': instance.mangaId,
      'chapterId': instance.chapterId,
      'chapterName': instance.chapterName,
      'totalPage': instance.totalPage,
    };

DownloadPage _$DownloadPageFromJson(Map<String, dynamic> json) {
  return DownloadPage(
    chapterId: json['chapterId'] as int?,
    mangaId: json['mangaId'] as int?,
    pageId: json['pageId'] as int?,
    contentPage: json['contentPage'] as String?,
  );
}

Map<String, dynamic> _$DownloadPageToJson(DownloadPage instance) =>
    <String, dynamic>{
      'chapterId': instance.chapterId,
      'mangaId': instance.mangaId,
      'pageId': instance.pageId,
      'contentPage': instance.contentPage,
    };
