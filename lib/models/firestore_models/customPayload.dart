import 'package:json_annotation/json_annotation.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
part 'customPayload.g.dart';

@JsonSerializable()
class CustomPayload {
  final String to;
  final String priority;
  final PayloadNotification notification;
  final PayloadData data;

  CustomPayload({required this.to,required this.priority,required this.notification,required this.data});

  Map<String, dynamic> toJson() => _$CustomPayloadToJson(this);
}

@JsonSerializable()
class PayloadNotification {
  final String title;
  final String body;
  final String image;
  final String sound;

  PayloadNotification({required this.title,required this.body,required this.image,required this.sound});

  Map<String, dynamic> toJson() => _$PayloadNotificationToJson(this);

  factory PayloadNotification.fromJson(Map<String, dynamic> json) =>
      _$PayloadNotificationFromJson(json);
}

@JsonSerializable()
class PayloadData {
  final String click_action;
  final FeedModel feedModel;

  PayloadData(
      {required this.click_action, required this.feedModel});

  Map<String, dynamic> toJson() => _$PayloadDataToJson(this);
  factory PayloadData.fromJson(Map<String, dynamic> json) =>
      _$PayloadDataFromJson(json);
}
