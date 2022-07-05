import 'package:json_annotation/json_annotation.dart';
part 'insert_character_model.g.dart';

@JsonSerializable()
class InsertCharacterModel {
  final String name;
  final int mangaId;
  final String profileImage;

  InsertCharacterModel({required this.name,required  this.mangaId,required  this.profileImage});

  Map<String, dynamic> toJson() => _$InsertCharacterModelToJson(this);
}
