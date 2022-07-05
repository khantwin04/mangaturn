import 'package:json_annotation/json_annotation.dart';
part 'post_comment_model.g.dart';

@JsonSerializable()
class PostCommentModel {
  int mangaId;
  int? chapterId;
  String? type;
  int? mentionedUserId;
  String content;

  PostCommentModel(
      {required this.mangaId,
      this.chapterId,
      this.type = "DEFAULT",
      this.mentionedUserId,
      required this.content});

  Map<String, dynamic> toJson() => _$PostCommentModelToJson(this);
}
