// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'character_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CharacterModel _$CharacterModelFromJson(Map<String, dynamic> json) {
  return CharacterModel(
    id: json['id'] as int,
    name: json['name'] as String,
    mangaName: json['mangaName'] as String,
    profileImagePath: json['profileImagePath'] as String,
  );
}

Map<String, dynamic> _$CharacterModelToJson(CharacterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mangaName': instance.mangaName,
      'profileImagePath': instance.profileImagePath,
    };
