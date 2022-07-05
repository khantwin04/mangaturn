import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'genre_model.g.dart';

@JsonSerializable()
class GenreModel extends Equatable{
  final int id;
  final String name;

  GenreModel({required this.id,required this.name});

  factory GenreModel.fromJson(Map<String, dynamic> json) => _$GenreModelFromJson(json);

  @override
  // TODO: implement props
  List<Object> get props => [id, name];
}