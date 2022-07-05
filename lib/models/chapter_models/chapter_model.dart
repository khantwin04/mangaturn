import 'package:json_annotation/json_annotation.dart';
part 'chapter_model.g.dart';

@JsonSerializable()
class ChapterModel {
  final bool? read;
  final int id;
  final String chapterName;
  final int chapterNo;
  final String type;
  final int point;
  final int totalPages;
  final bool? isPurchase;
  final List? pages;

  ChapterModel(
      {this.read,
        required this.id,
      required this.chapterName,
      required this.chapterNo,
      required this.type,
      required this.point,
      required this.totalPages,
      this.isPurchase,
      this.pages});

  factory ChapterModel.fromJson(Map<String, dynamic> json) =>
      _$ChapterModelFromJson(json);

  Map<String, dynamic> toJson() => _$ChapterModelToJson(this);
}
