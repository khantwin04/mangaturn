import 'package:json_annotation/json_annotation.dart';
part 'get_unread_comment_by_admin.g.dart';

@JsonSerializable()
class GetUnreadCommentByAdmin {
  final int mangaId;
  final String mangaName;
  final String mangaCoverUrl;
  final int count;

  GetUnreadCommentByAdmin(
      {required this.mangaId,
      required this.mangaName,
      required this.mangaCoverUrl,
      required this.count});

  factory GetUnreadCommentByAdmin.fromJson(Map<String, dynamic> json) =>
      _$GetUnreadCommentByAdminFromJson(json);
}
