import 'package:json_annotation/json_annotation.dart';
part 'insert_manga_model.g.dart';

@JsonSerializable()
class InsertMangaModel {
  final String name;
  final String otherNames;
  final String author;
  final String status;
  final String update;
  final int? publishedDate;
  final String description;
  final List<int> genre;
  final bool isAdult;
  final String coverImage;

  InsertMangaModel({
    required this.name,
    required this.otherNames,
    required this.author,
    required this.status,
    required this.update,
    this.publishedDate,
    required this.description,
    required this.genre,
    required this.coverImage,
    required this.isAdult,
  });

  Map<String, dynamic> toJson() => _$InsertMangaModelToJson(this);
}
