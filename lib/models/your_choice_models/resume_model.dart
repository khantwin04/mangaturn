import 'package:hive/hive.dart';
part 'resume_model.g.dart';

@HiveType(typeId: 0)
class ResumeModel {
  @HiveField(0)
  final String title;

  @HiveField(1)
  final String chapterName;

  @HiveField(2)
  final int chapterId;

  @HiveField(3)
  final bool newChapterAvailable;

  @HiveField(4)
  final int newChapterId;

  @HiveField(5)
  final String newChapterName;

  @HiveField(6)
  final int key;

  @HiveField(7)
  final String cover;

  @HiveField(8)
  final DateTime timeStamp;

  @HiveField(9)
  final int currentChapterIndex;

  @HiveField(10)
  final int mangaId;

  ResumeModel({
    required this.currentChapterIndex,
    required this.title,
    required this.chapterName,
    required this.chapterId,
    required this.newChapterAvailable,
    required this.newChapterId,
    required this.newChapterName,
    required this.key,
    required this.cover,
    required this.timeStamp,
    required this.mangaId,
  });
}
