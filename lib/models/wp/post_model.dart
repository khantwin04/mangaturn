import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';
part 'post_model.g.dart';

@JsonSerializable()
class RelatedPosts{
  final int? id;
  final String? url;
  final String? img;
  final String? date;
  final String? title;

  RelatedPosts({this.id, this.url, this.img, this.date, this.title});

  factory RelatedPosts.fromJson(Map<String, dynamic> json) => _$RelatedPostsFromJson(json);

}

@JsonSerializable()
class PostModel {
  final int? id;
  final String? title;
  final String? content;
  final String? excerpt;
  final String? jetpack_featured_media_url;
  final String? date;
  final String? link;

  PostModel({this.id,
    this.excerpt,
    this.title,
    this.content,
    this.jetpack_featured_media_url,
    this.date,
    this.link,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);


  factory PostModel.fromDatabaseJson(Map<String, dynamic> data) => PostModel(
    id: data['id'],
    title: data['title'],
    content: data['content'],
    jetpack_featured_media_url: data['image'],
    date: data['date'],
    link: data['link'],
  );

  Map<String, dynamic> toDatabaseJson() => {
    'id': this.id,
    'title': this.title,
    'content': this.content,
    'image': this.jetpack_featured_media_url,
    'date': this.date,
    'link': this.link,
  };

}
