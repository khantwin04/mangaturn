import 'package:json_annotation/json_annotation.dart';
part 'category_model.g.dart';


@JsonSerializable()
class CategoryModel{
  final int? id;
  final int? count;
  final String? name;
  final String? description;

  CategoryModel({this.id, this.count, this.name, this.description});

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);

}