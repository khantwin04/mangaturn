import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
part 'feed_model.g.dart';

enum UpdateType {
  mangaUpdate,
  mangaInsert,
  chapterUpdate,
  chapterInsert,
  profileUpdate,
  post,
}

@HiveType(typeId: 1)
@JsonSerializable()
class FeedModel {
  @HiveField(0)
  final String uploaderName;
  @HiveField(1)
  final String uploaderCover;
  @HiveField(2)
  final int mangaId;
  @HiveField(3)
  final String mangaName;
  @HiveField(4)
  final String mangaCover;
  @HiveField(5)
  final String mangaDescription;
  @HiveField(6)
  final int chapterId;
  @HiveField(7)
  final String chapterName;
  @HiveField(8)
  final bool isFree;
  @HiveField(9)
  final int point;
  @HiveField(10)
  final bool isPurchase;
  @HiveField(11)
  final String updateType;
  @HiveField(12)
  DateTime? timeStamp;
  @HiveField(13)
  final String title;
  @HiveField(14)
  final String body;
  @HiveField(15)
  final int chapterNo;
  @HiveField(16)
  final int totalPages;

  FeedModel({
    required this.uploaderName,
    required this.uploaderCover,
    required this.mangaId,
    required this.mangaName,
    required this.mangaCover,
    required this.mangaDescription,
    required this.chapterId,
    required this.chapterName,
    required this.isFree,
    required this.point,
    required this.isPurchase,
    required this.updateType,
    this.timeStamp,
    required this.title,
    required this.body,
    required this.chapterNo,
    required this.totalPages,
  });

  Map<String, dynamic> toJson() => _$FeedModelToJson(this);
  factory FeedModel.fromJson(Map<String, dynamic> json) =>
      _$FeedModelFromJson(json);
}
