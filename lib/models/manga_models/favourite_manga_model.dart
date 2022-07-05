import 'package:json_annotation/json_annotation.dart';
part 'favourite_manga_model.g.dart';

@JsonSerializable()
class FavMangaModel {
  final int mangaId;
  final String mangaName;
  final String mangaCover;

  FavMangaModel({required this.mangaId,
    required this.mangaName,
    required this.mangaCover});

  Map<String, dynamic> toJson() => _$FavMangaModelToJson(this);

  factory FavMangaModel.fromJson(Map<String, dynamic> json) =>
      _$FavMangaModelFromJson(json);
}