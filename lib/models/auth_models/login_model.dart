import 'package:mangaturn/models/auth_models/sign_up_model.dart';

import '../manga_models/manga_user_model.dart';
import 'package:json_annotation/json_annotation.dart';

part 'login_model.g.dart';

@JsonSerializable()
class LoginModel {
  final String username;
  final String password;

  LoginModel({required this.username,required this.password});

  Map<String, dynamic> toJson() => _$LoginModelToJson(this);
}

@JsonSerializable()
class LoginResponseModel {
  final String token;
  User user;

  LoginResponseModel({required this.token, required this.user});

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseModelFromJson(json);
}
