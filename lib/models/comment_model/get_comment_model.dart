import 'package:json_annotation/json_annotation.dart';
part 'get_comment_model.g.dart';

@JsonSerializable()
class GetCommentModel {
  final int id;
  final String content;
  final int mangaId;
  final String mangaName;
  final int createdUserId;
  final String createdUsername;
  final String createdUserProfileUrl;
  final int createdDateInMilliSeconds;
  final int updatedDateInMilliSeconds;
  final int uploaderId;
  final bool uploaderReadStatus;
  final String type;
  final bool mentionedUserReadStatus;
  final int? mentionedUserId;
  final String? mentionedUsername;
  final bool? replied;

  GetCommentModel({
    required this.id,
    required this.content,
    required this.mangaId,
    required this.mangaName,
    required this.createdUserId,
    required this.createdUsername,
    required this.createdUserProfileUrl,
    required this.createdDateInMilliSeconds,
    required this.updatedDateInMilliSeconds,
    required this.uploaderId,
    required this.uploaderReadStatus,
    required this.type,
    required this.mentionedUserReadStatus,
    this.mentionedUserId,
    this.mentionedUsername,
    this.replied,
  });

  factory GetCommentModel.fromJson(Map<String, dynamic> json) =>
      _$GetCommentModelFromJson(json);
}
