import 'package:json_annotation/json_annotation.dart';
part 'update_manga_model.g.dart';

@JsonSerializable()
class UpdateMangaModel {
  final int id;
  final String name;
  final String otherNames;
  final String author;
  final String description;
  final String status;
  final String update;
  final int? publishedDate;
  final List<int> genre;
  final String coverImage;
  final bool isAdult;

  UpdateMangaModel(
      {required this.id,
      required this.name,
      required this.otherNames,
      required this.author,
      required this.description,
      required this.status,
      required this.update,
      this.publishedDate,
      required this.genre,
      required this.coverImage,
      required this.isAdult,
      });

  Map<String, dynamic> toJson() => _$UpdateMangaModelToJson(this);
}
