// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'noti_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotiModel _$NotiModelFromJson(Map<String, dynamic> json) {
  return NotiModel(
    id: json['id'] as int?,
    mangaId: json['mangaId'] as int,
    mangaName: json['mangaName'] as String,
    mangaCover: json['mangaCover'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    see: json['see'] as String,
  );
}

Map<String, dynamic> _$NotiModelToJson(NotiModel instance) => <String, dynamic>{
      'id': instance.id,
      'mangaId': instance.mangaId,
      'mangaName': instance.mangaName,
      'mangaCover': instance.mangaCover,
      'title': instance.title,
      'body': instance.body,
      'see': instance.see,
    };
