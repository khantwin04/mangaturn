import 'package:json_annotation/json_annotation.dart';
part 'update_comment_model.g.dart';

@JsonSerializable()
class UpdateCommentModel {
  final int id;
  final String content;

  UpdateCommentModel({required this.id, required this.content});

  Map<String, dynamic> toJson() => _$UpdateCommentModelToJson(this);
}
