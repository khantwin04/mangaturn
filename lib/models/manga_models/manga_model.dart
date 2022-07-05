import 'package:equatable/equatable.dart';

import 'genre_model.dart';
import 'manga_user_model.dart';
import 'package:json_annotation/json_annotation.dart';
part 'manga_model.g.dart';

@JsonSerializable()
class GetAllMangaModel extends Equatable {
  final List<MangaModel> mangaList;
  final int page;
  final int size;
  final int numberofElements;
  final int totalElements;
  final int totalPages;

  GetAllMangaModel(
      {required this.mangaList,
      required this.page,
      required this.size,
      required this.numberofElements,
      required this.totalElements,
      required this.totalPages});

  factory GetAllMangaModel.fromJson(Map<String, dynamic> json) =>
      _$GetAllMangaModelFromJson(json);

  @override
  List<Object> get props =>
      [mangaList, page, size, numberofElements, totalElements, totalPages];
}

@JsonSerializable()
class MangaModel extends Equatable {
  final int id;
  final String? name;
  final String? otherNames;
  final String? author;
  final String? description;
  final String? publishedDate;
  final String? status;
  final String? update;
  final bool? isAdult;
  final List<GenreModel>? genreList;
  final String? coverImagePath;
  final String? uploadedBy;
  final UploadedByUserModel? uploadedByUser;
  final int? updatedDateInMilliSeconds;
  final int? views;
  final bool? favourite;
  final int? totalChapters;
  final int? favouriteCount;

  MangaModel({
    required this.id,
    this.name,
    this.otherNames,
    this.author,
    this.description,
    this.publishedDate,
    this.status,
    this.update,
    this.isAdult,
    this.genreList,
    this.coverImagePath,
    this.uploadedBy,
    this.uploadedByUser,
    this.updatedDateInMilliSeconds,
    this.views,
    this.favourite,
    this.totalChapters,
    this.favouriteCount,
  });

  factory MangaModel.fromJson(Map<String, dynamic> json) =>
      _$MangaModelFromJson(json);

  Map<String, dynamic> toJson() => _$MangaModelToJson(this);
  @override
  // TODO: implement props
  List<Object> get props => [
        id,
        name!,
        otherNames ?? '',
        author!,
        description!,
        updatedDateInMilliSeconds!,
        update!,
        isAdult!,
        status!,
        uploadedBy!,
        views!,
        coverImagePath!,
        genreList!,
        uploadedByUser!,
        totalChapters!,
        favourite!
      ];
}
