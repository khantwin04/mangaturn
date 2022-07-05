// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'manga_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetAllMangaModel _$GetAllMangaModelFromJson(Map<String, dynamic> json) {
  return GetAllMangaModel(
    mangaList: (json['mangaList'] as List<dynamic>)
        .map((e) => MangaModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    page: json['page'] as int,
    size: json['size'] as int,
    numberofElements: json['numberofElements'] as int,
    totalElements: json['totalElements'] as int,
    totalPages: json['totalPages'] as int,
  );
}

Map<String, dynamic> _$GetAllMangaModelToJson(GetAllMangaModel instance) =>
    <String, dynamic>{
      'mangaList': instance.mangaList,
      'page': instance.page,
      'size': instance.size,
      'numberofElements': instance.numberofElements,
      'totalElements': instance.totalElements,
      'totalPages': instance.totalPages,
    };

MangaModel _$MangaModelFromJson(Map<String, dynamic> json) {
  return MangaModel(
    id: json['id'] as int,
    name: json['name'] as String?,
    otherNames: json['otherNames'] as String?,
    author: json['author'] as String?,
    description: json['description'] as String?,
    publishedDate: json['publishedDate'] as String?,
    status: json['status'] as String?,
    update: json['update'] as String?,
    isAdult: json['isAdult'] as bool?,
    genreList: (json['genreList'] as List<dynamic>?)
        ?.map((e) => GenreModel.fromJson(e as Map<String, dynamic>))
        .toList(),
    coverImagePath: json['coverImagePath'] as String?,
    uploadedBy: json['uploadedBy'] as String?,
    uploadedByUser: json['uploadedByUser'] == null
        ? null
        : UploadedByUserModel.fromJson(
            json['uploadedByUser'] as Map<String, dynamic>),
    updatedDateInMilliSeconds: json['updatedDateInMilliSeconds'] as int?,
    views: json['views'] as int?,
    favourite: json['favourite'] as bool?,
    totalChapters: json['totalChapters'] as int?,
    favouriteCount: json['favouriteCount'] as int?,
  );
}

Map<String, dynamic> _$MangaModelToJson(MangaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'otherNames': instance.otherNames,
      'author': instance.author,
      'description': instance.description,
      'publishedDate': instance.publishedDate,
      'status': instance.status,
      'update': instance.update,
      'isAdult': instance.isAdult,
      'genreList': instance.genreList,
      'coverImagePath': instance.coverImagePath,
      'uploadedBy': instance.uploadedBy,
      'uploadedByUser': instance.uploadedByUser,
      'updatedDateInMilliSeconds': instance.updatedDateInMilliSeconds,
      'views': instance.views,
      'favourite': instance.favourite,
      'totalChapters': instance.totalChapters,
      'favouriteCount': instance.favouriteCount,
    };
