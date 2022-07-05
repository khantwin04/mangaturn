// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insert_manga_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsertMangaModel _$InsertMangaModelFromJson(Map<String, dynamic> json) {
  return InsertMangaModel(
    name: json['name'] as String,
    otherNames: json['otherNames'] as String,
    author: json['author'] as String,
    status: json['status'] as String,
    update: json['update'] as String,
    publishedDate: json['publishedDate'] as int?,
    description: json['description'] as String,
    genre: (json['genre'] as List<dynamic>).map((e) => e as int).toList(),
    coverImage: json['coverImage'] as String,
    isAdult: json['isAdult'] as bool,
  );
}

Map<String, dynamic> _$InsertMangaModelToJson(InsertMangaModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'otherNames': instance.otherNames,
      'author': instance.author,
      'status': instance.status,
      'update': instance.update,
      'publishedDate': instance.publishedDate,
      'description': instance.description,
      'genre': instance.genre,
      'isAdult': instance.isAdult,
      'coverImage': instance.coverImage,
    };
