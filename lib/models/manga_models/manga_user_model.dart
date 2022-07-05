import 'package:json_annotation/json_annotation.dart';
part 'manga_user_model.g.dart';

@JsonSerializable()
class UploadedByUserModel {
  final int id;
  final String username;
  final String? profileUrl;
  final String? description;

  UploadedByUserModel({
    required this.id,
    required this.username,
    this.profileUrl,
    this.description,
  
  });

  factory UploadedByUserModel.fromJson(Map<String, dynamic> json) =>
      _$UploadedByUserModelFromJson(json);
}
