import 'dart:typed_data';
import 'package:json_annotation/json_annotation.dart';
part 'download_manga_model.g.dart';

@JsonSerializable()
class DownloadManga {
  int? mangaId;
  String? mangaName;
  String? mangaCover;

  DownloadManga({ this.mangaId,  this.mangaName, this.mangaCover});

  factory DownloadManga.fromMap(Map<String, dynamic> json) => _$DownloadMangaFromJson(json);

  Map<String, dynamic> toMap() => _$DownloadMangaToJson(this);
}

@JsonSerializable()
class DownloadChapter {
  int? mangaId;
  int? chapterId;
  String? chapterName;
  int? totalPage;

  DownloadChapter({ this.mangaId, this.chapterId, this.chapterName, this.totalPage});

  factory DownloadChapter.fromMap(Map<String, dynamic> json) => _$DownloadChapterFromJson(json);

  Map<String, dynamic> toMap() => _$DownloadChapterToJson(this);
}

@JsonSerializable()
class DownloadPage {
  int? chapterId;
  int? mangaId;
  int? pageId;
  String? contentPage;

  DownloadPage({ this.chapterId, this.mangaId, this.pageId, this.contentPage});

  factory DownloadPage.fromMap(Map<String, dynamic> json) => _$DownloadPageFromJson(json);

  Map<String ,dynamic> toMap() => _$DownloadPageToJson(this);

}




