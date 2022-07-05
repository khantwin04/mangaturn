import 'package:json_annotation/json_annotation.dart';
part 'page_model.g.dart';

@JsonSerializable()
class PageModel{
  final int id;
  final int pageNo;
  final String contentPath;
  final String chapterName;
  PageModel({required this.id,required this.pageNo,required this.contentPath,required this.chapterName});

  factory PageModel.fromJson(Map<String, dynamic> json) => _$PageModelFromJson(json);

  Map<String, dynamic> toJson() => _$PageModelToJson(this);
}