// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'resume_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ResumeModelAdapter extends TypeAdapter<ResumeModel> {
  @override
  final int typeId = 0;

  @override
  ResumeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ResumeModel(
      currentChapterIndex: fields[9] as int,
      title: fields[0] as String,
      chapterName: fields[1] as String,
      chapterId: fields[2] as int,
      newChapterAvailable: fields[3] as bool,
      newChapterId: fields[4] as int,
      newChapterName: fields[5] as String,
      key: fields[6] as int,
      cover: fields[7] as String,
      timeStamp: fields[8] as DateTime,
      mangaId: fields[10] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ResumeModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.chapterName)
      ..writeByte(2)
      ..write(obj.chapterId)
      ..writeByte(3)
      ..write(obj.newChapterAvailable)
      ..writeByte(4)
      ..write(obj.newChapterId)
      ..writeByte(5)
      ..write(obj.newChapterName)
      ..writeByte(6)
      ..write(obj.key)
      ..writeByte(7)
      ..write(obj.cover)
      ..writeByte(8)
      ..write(obj.timeStamp)
      ..writeByte(9)
      ..write(obj.currentChapterIndex)
      ..writeByte(10)
      ..write(obj.mangaId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResumeModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
