import 'package:mangaturn/models/chapter_models/insert_chapter_model.dart';
import 'package:mangaturn/models/chapter_models/page_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'update_chapter_model.g.dart';

@JsonSerializable()
class UpdateChapterModel {
  final int id;
  final String chapterName;
  final int chapterNo;
  final int mangaId;
  final String type;
  final int point;
  final List<InsertPageModel> pages;

  UpdateChapterModel(
      {required this.id,
      required this.chapterName,
      required this.chapterNo,
      required this.mangaId,
      required this.type,
      required this.point,
      required this.pages});

  Map<String, dynamic> toJson() => _$UpdateChapterModelToJson(this);
}
