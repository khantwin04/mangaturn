// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'insert_character_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InsertCharacterModel _$InsertCharacterModelFromJson(Map<String, dynamic> json) {
  return InsertCharacterModel(
    name: json['name'] as String,
    mangaId: json['mangaId'] as int,
    profileImage: json['profileImage'] as String,
  );
}

Map<String, dynamic> _$InsertCharacterModelToJson(
        InsertCharacterModel instance) =>
    <String, dynamic>{
      'name': instance.name,
      'mangaId': instance.mangaId,
      'profileImage': instance.profileImage,
    };
