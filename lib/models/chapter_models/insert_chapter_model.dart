import 'package:json_annotation/json_annotation.dart';
part 'insert_chapter_model.g.dart';

@JsonSerializable()
class InsertChapterModel {
  final String chapterName;
  final int chapterNo;
  final String type;
  final int point;
  final int mangaId;
  final List<InsertPageModel> pages;

  InsertChapterModel({
    required this.chapterName,
    required this.chapterNo,
    required this.type,
    required this.point,
    required this.mangaId,
    required this.pages,
  });

  Map<String, dynamic> toJson() => _$InsertChapterModelToJson(this);
}

@JsonSerializable()
class InsertPageModel {
  final int? id;
  final int pageNo;
  final String? content;

  InsertPageModel({ this.id, required this.pageNo, this.content});

  Map<String, dynamic> toJson() => _$InsertPageModelToJson(this);

  factory InsertPageModel.fromJson(Map<String, dynamic> json) =>
      _$InsertPageModelFromJson(json);
}

@JsonSerializable()
class InsertPageModelNoContent {
  final int id;
  final int pageNo;

  InsertPageModelNoContent({required this.id,required  this.pageNo});

  Map<String, dynamic> toJson() => _$InsertPageModelNoContentToJson(this);

  factory InsertPageModelNoContent.fromJson(Map<String, dynamic> json) =>
      _$InsertPageModelNoContentFromJson(json);
}
