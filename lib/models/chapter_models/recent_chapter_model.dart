import 'package:json_annotation/json_annotation.dart';
part 'recent_chapter_model.g.dart';

@JsonSerializable()
class RecentChapterModel {
  final int? mangaId;
  final String? mangaName;
  final int? chapterId;
  final String? chapterName;
  final int? resumePageNo;
  final double? resumePosition;
  final int? totalPage;
  final double? maxScrollPosition;
  final String? resumeImage;

  RecentChapterModel(
      { this.mangaId,
         this.mangaName,
         this.chapterId,
         this.chapterName,
         this.resumePageNo,
         this.resumePosition,
         this.totalPage,
         this.maxScrollPosition,
         this.resumeImage});

  Map<String, dynamic> toJson() => _$RecentChapterModelToJson(this);

  factory RecentChapterModel.fromJson(Map<String, dynamic> json) => _$RecentChapterModelFromJson(json);

}
