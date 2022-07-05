import 'package:json_annotation/json_annotation.dart';
import 'package:hive/hive.dart';
part 'sign_up_model.g.dart';

@JsonSerializable()
class SignUpModel {
  final String username;
  final String password;
  final String? profile;

  SignUpModel({required this.username, required this.password, this.profile});

  Map<String, dynamic> toJson() => _$SignUpModelToJson(this);
}



@HiveType(typeId: 2)
@JsonSerializable()
class AuthResponseModel {
  AuthResponseModel({
    required this.accessToken,
    required this.tokenType,
    required this.refreshToken,
    required this.user,
  });

  @HiveField(0)
  final String accessToken;
  @HiveField(1)
  final String tokenType;
  @HiveField(2)
  final String refreshToken;
  @HiveField(3)
  final User user;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

@HiveType(typeId: 3)
@JsonSerializable()
class User {
  User({
    required this.id,
    required this.username,
    required this.role,
    required this.point,
    required this.createdDateInMilliSeconds,
    required this.updatedDateInMilliSeconds,
  });

  @HiveField(0)
  final int id;
  @HiveField(1)
  final String username;
  @HiveField(2)
  final String role;
  @HiveField(3)
  final int point;
  @HiveField(4)
  final int createdDateInMilliSeconds;
  @HiveField(5)
  final int updatedDateInMilliSeconds;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  Map<String, dynamic> toJson() => _$UserToJson(this);
}
