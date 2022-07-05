// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payload.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Payload _$PayloadFromJson(Map<String, dynamic> json) {
  return Payload(
    to: json['to'] as String,
    priority: json['priority'] as String,
    notification: PayloadNotification.fromJson(
        json['notification'] as Map<String, dynamic>),
    data: PayloadData.fromJson(json['data'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$PayloadToJson(Payload instance) => <String, dynamic>{
      'to': instance.to,
      'priority': instance.priority,
      'notification': instance.notification,
      'data': instance.data,
    };

PayloadNotification _$PayloadNotificationFromJson(Map<String, dynamic> json) {
  return PayloadNotification(
    title: json['title'] as String,
    body: json['body'] as String,
    image: json['image'] as String,
    sound: json['sound'] as String,
  );
}

Map<String, dynamic> _$PayloadNotificationToJson(
        PayloadNotification instance) =>
    <String, dynamic>{
      'title': instance.title,
      'body': instance.body,
      'image': instance.image,
      'sound': instance.sound,
    };

PayloadData _$PayloadDataFromJson(Map<String, dynamic> json) {
  return PayloadData(
    click_action: json['click_action'] as String,
    mangaId: json['mangaId'] as String,
    mangaName: json['mangaName'] as String,
    mangaCover: json['mangaCover'] as String,
  );
}

Map<String, dynamic> _$PayloadDataToJson(PayloadData instance) =>
    <String, dynamic>{
      'click_action': instance.click_action,
      'mangaId': instance.mangaId,
      'mangaName': instance.mangaName,
      'mangaCover': instance.mangaCover,
    };
