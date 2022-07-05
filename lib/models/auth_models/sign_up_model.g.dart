// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuthResponseModelAdapter extends TypeAdapter<AuthResponseModel> {
  @override
  final int typeId = 2;

  @override
  AuthResponseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuthResponseModel(
      accessToken: fields[0] as String,
      tokenType: fields[1] as String,
      refreshToken: fields[2] as String,
      user: fields[3] as User,
    );
  }

  @override
  void write(BinaryWriter writer, AuthResponseModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.accessToken)
      ..writeByte(1)
      ..write(obj.tokenType)
      ..writeByte(2)
      ..write(obj.refreshToken)
      ..writeByte(3)
      ..write(obj.user);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthResponseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 3;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as int,
      username: fields[1] as String,
      role: fields[2] as String,
      point: fields[3] as int,
      createdDateInMilliSeconds: fields[4] as int,
      updatedDateInMilliSeconds: fields[5] as int,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.point)
      ..writeByte(4)
      ..write(obj.createdDateInMilliSeconds)
      ..writeByte(5)
      ..write(obj.updatedDateInMilliSeconds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SignUpModel _$SignUpModelFromJson(Map<String, dynamic> json) {
  return SignUpModel(
    username: json['username'] as String,
    password: json['password'] as String,
    profile: json['profile'] as String?,
  );
}

Map<String, dynamic> _$SignUpModelToJson(SignUpModel instance) =>
    <String, dynamic>{
      'username': instance.username,
      'password': instance.password,
      'profile': instance.profile,
    };

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) {
  return AuthResponseModel(
    accessToken: json['accessToken'] as String,
    tokenType: json['tokenType'] as String,
    refreshToken: json['refreshToken'] as String,
    user: User.fromJson(json['user'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AuthResponseModelToJson(AuthResponseModel instance) =>
    <String, dynamic>{
      'accessToken': instance.accessToken,
      'tokenType': instance.tokenType,
      'refreshToken': instance.refreshToken,
      'user': instance.user,
    };

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    id: json['id'] as int,
    username: json['username'] as String,
    role: json['role'] as String,
    point: json['point'] as int,
    createdDateInMilliSeconds: json['createdDateInMilliSeconds'] as int,
    updatedDateInMilliSeconds: json['updatedDateInMilliSeconds'] as int,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'role': instance.role,
      'point': instance.point,
      'createdDateInMilliSeconds': instance.createdDateInMilliSeconds,
      'updatedDateInMilliSeconds': instance.updatedDateInMilliSeconds,
    };
