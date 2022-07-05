// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_character_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UpdateCharacterModel _$UpdateCharacterModelFromJson(Map<String, dynamic> json) {
  return UpdateCharacterModel(
    id: json['id'] as int,
    name: json['name'] as String,
    mangaId: json['mangaId'] as int,
    profileImage: json['profileImage'] as String,
  );
}

Map<String, dynamic> _$UpdateCharacterModelToJson(
        UpdateCharacterModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'mangaId': instance.mangaId,
      'profileImage': instance.profileImage,
    };
