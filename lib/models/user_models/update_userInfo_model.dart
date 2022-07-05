import 'package:json_annotation/json_annotation.dart';

part 'update_userInfo_model.g.dart';

@JsonSerializable()
class UpdateUserInfoModel {
  final int id;
  final String username;
  final String? payment;
  final String? description;
  final String? type;
  final String? profile;

  UpdateUserInfoModel(
      {
        required this.id,
        required this.username,
      this.payment,
      this.description,
      this.type,
      this.profile});

  Map<String, dynamic> toJson() => _$UpdateUserInfoModelToJson(this);
}

@JsonSerializable()
class UpdateUserPassword {
  String oldPassword;
  String newPassword;

  UpdateUserPassword({required this.oldPassword, required this.newPassword});

  Map<String, dynamic> toJson() => _$UpdateUserPasswordToJson(this);
}
