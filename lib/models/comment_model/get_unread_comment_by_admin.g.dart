// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'get_unread_comment_by_admin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GetUnreadCommentByAdmin _$GetUnreadCommentByAdminFromJson(
    Map<String, dynamic> json) {
  return GetUnreadCommentByAdmin(
    mangaId: json['mangaId'] as int,
    mangaName: json['mangaName'] as String,
    mangaCoverUrl: json['mangaCoverUrl'] as String,
    count: json['count'] as int,
  );
}

Map<String, dynamic> _$GetUnreadCommentByAdminToJson(
        GetUnreadCommentByAdmin instance) =>
    <String, dynamic>{
      'mangaId': instance.mangaId,
      'mangaName': instance.mangaName,
      'mangaCoverUrl': instance.mangaCoverUrl,
      'count': instance.count,
    };
