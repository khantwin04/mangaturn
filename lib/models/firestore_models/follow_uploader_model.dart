import 'package:json_annotation/json_annotation.dart';
part 'follow_uploader_model.g.dart';

@JsonSerializable()
class FollowModel {
  final int userId;
  final String userName;
  final String userCover;
  final String userMessenger;

  FollowModel({required this.userId,required this.userName,required this.userCover,required this.userMessenger});

  factory FollowModel.fromJson(Map<String, dynamic> json) => _$FollowModelFromJson(json);

  Map<String, dynamic> toJson() => _$FollowModelToJson(this);
}