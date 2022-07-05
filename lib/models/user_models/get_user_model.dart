import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_user_model.g.dart';

@JsonSerializable()
class GetUserModel extends Equatable {
  int id;
  String username;
  String? role;
  String? payment;
  String? profileUrl;
  int point;
  String? type;
  String? description;
  int createdDateInMilliSeconds;
  int updatedDateInMilliSeconds;

  GetUserModel(
      {required this.id,
      required this.username,
      this.role,
      this.payment,
      this.profileUrl,
      required this.point,
      this.type,
         this.description,
        required this.createdDateInMilliSeconds,
        required this.updatedDateInMilliSeconds});

  factory GetUserModel.fromJson(Map<String, dynamic> json) => _$GetUserModelFromJson(json);

  @override
  List<Object> get props => [id, username, profileUrl??'profile', payment??"payment", point, role??'role', type??"type", description??'description', updatedDateInMilliSeconds, createdDateInMilliSeconds];
}
