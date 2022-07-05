import 'package:json_annotation/json_annotation.dart';
part 'noti_model.g.dart';

@JsonSerializable()
class NotiModel {
  final int? id;
  final int mangaId;
  final String mangaName;
  final String mangaCover;
  final String title;
  final String body;
  final String see;
  NotiModel({this.id,required this.mangaId,required this.mangaName,required this.mangaCover,required this.title,required this.body,required this.see});

  factory NotiModel.fromJson(Map<String, dynamic> json) => _$NotiModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotiModelToJson(this);

}