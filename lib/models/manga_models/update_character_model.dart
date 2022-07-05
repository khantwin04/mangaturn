import 'package:json_annotation/json_annotation.dart';
part 'update_character_model.g.dart';

@JsonSerializable()
class UpdateCharacterModel {
  final int id;
  final String name;
  final int mangaId;
  final String profileImage;

  UpdateCharacterModel({required this.id,required  this.name,required  this.mangaId, required this.profileImage});

  Map<String, dynamic> toJson() => _$UpdateCharacterModelToJson(this);
}
