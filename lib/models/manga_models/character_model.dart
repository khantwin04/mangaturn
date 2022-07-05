import 'package:json_annotation/json_annotation.dart';
part 'character_model.g.dart';

@JsonSerializable()
class CharacterModel {
  final int id;
  final String name;
  final String mangaName;
  final String profileImagePath;

  CharacterModel({required this.id,required this.name,required this.mangaName,required this.profileImagePath});

  factory CharacterModel.fromJson(Map<String, dynamic> json) =>
      _$CharacterModelFromJson(json);
}
