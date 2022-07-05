import 'package:json_annotation/json_annotation.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
part 'latestChapter_model.g.dart';

@JsonSerializable()
class LatestChapterModel {
  final int id;
  final String chapterName;
  final int chapterNo;
  final String type;
  final int point;
  final int totalPages;
  final bool? isPurchase;
  final List pages;
  final MangaModel manga;

  LatestChapterModel({
    required this.id,
    required this.chapterName,
    required this.chapterNo,
    required this.type,
    required this.point,
    required this.totalPages,
    this.isPurchase,
    required this.pages,
    required this.manga,
  });

  factory LatestChapterModel.fromJson(Map<String, dynamic> json) =>
      _$LatestChapterModelFromJson(json);

  Map<String, dynamic> toJson() => _$LatestChapterModelToJson(this);
}
