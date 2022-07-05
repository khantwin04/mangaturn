// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'version_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VersionModel _$VersionModelFromJson(Map<String, dynamic> json) {
  return VersionModel(
    update: json['update'] as String?,
    appLink: json['appLink'] as String?,
    isForce: json['isForce'] as bool?,
  );
}

Map<String, dynamic> _$VersionModelToJson(VersionModel instance) =>
    <String, dynamic>{
      'update': instance.update,
      'appLink': instance.appLink,
      'isForce': instance.isForce,
    };
