// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favourite_manga_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FavMangaModel _$FavMangaModelFromJson(Map<String, dynamic> json) {
  return FavMangaModel(
    mangaId: json['mangaId'] as int,
    mangaName: json['mangaName'] as String,
    mangaCover: json['mangaCover'] as String,
  );
}

Map<String, dynamic> _$FavMangaModelToJson(FavMangaModel instance) =>
    <String, dynamic>{
      'mangaId': instance.mangaId,
      'mangaName': instance.mangaName,
      'mangaCover': instance.mangaCover,
    };
