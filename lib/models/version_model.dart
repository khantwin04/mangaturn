import 'package:json_annotation/json_annotation.dart';
part 'version_model.g.dart';

@JsonSerializable()
class VersionModel {
  final String? update;
  final String? appLink;
  final bool? isForce;

  VersionModel(
      {required this.update, required this.appLink, required this.isForce});

  factory VersionModel.fromJson(Map<String, dynamic> json) =>
      _$VersionModelFromJson(json);

  
}
