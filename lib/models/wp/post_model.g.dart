// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RelatedPosts _$RelatedPostsFromJson(Map<String, dynamic> json) {
  return RelatedPosts(
    id: json['id'] as int?,
    url: json['url'] as String?,
    img: json['img'] as String?,
    date: json['date'] as String?,
    title: json['title'] as String?,
  );
}

Map<String, dynamic> _$RelatedPostsToJson(RelatedPosts instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'img': instance.img,
      'date': instance.date,
      'title': instance.title,
    };

PostModel _$PostModelFromJson(Map<String, dynamic> json) {
  return PostModel(
    id: json['id'] as int?,
    excerpt: json['excerpt'] as String?,
    title: json['title'] as String?,
    content: json['content'] as String?,
    jetpack_featured_media_url: json['jetpack_featured_media_url'] as String?,
    date: json['date'] as String?,
    link: json['link'] as String?,
  );
}

Map<String, dynamic> _$PostModelToJson(PostModel instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'excerpt': instance.excerpt,
      'jetpack_featured_media_url': instance.jetpack_featured_media_url,
      'date': instance.date,
      'link': instance.link,
    };
