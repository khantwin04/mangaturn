// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'page_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PageModel _$PageModelFromJson(Map<String, dynamic> json) {
  return PageModel(
    id: json['id'] as int,
    pageNo: json['pageNo'] as int,
    contentPath: json['contentPath'] as String,
    chapterName: json['chapterName'] as String,
  );
}

Map<String, dynamic> _$PageModelToJson(PageModel instance) => <String, dynamic>{
      'id': instance.id,
      'pageNo': instance.pageNo,
      'contentPath': instance.contentPath,
      'chapterName': instance.chapterName,
    };
