// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_manga_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateMangaModel _$UpdateMangaModelFromJson(Map<String, dynamic> json) {
  return UpdateMangaModel(
    id: json['id'] as int,
    name: json['name'] as String,
    otherNames: json['otherNames'] as String,
    author: json['author'] as String,
    description: json['description'] as String,
    status: json['status'] as String,
    update: json['update'] as String,
    publishedDate: json['publishedDate'] as int?,
    genre: (json['genre'] as List<dynamic>).map((e) => e as int).toList(),
    coverImage: json['coverImage'] as String,
    isAdult: json['isAdult'] as bool,
  );
}

Map<String, dynamic> _$UpdateMangaModelToJson(UpdateMangaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'otherNames': instance.otherNames,
      'author': instance.author,
      'description': instance.description,
      'status': instance.status,
      'update': instance.update,
      'publishedDate': instance.publishedDate,
      'genre': instance.genre,
      'coverImage': instance.coverImage,
      'isAdult': instance.isAdult,
    };
