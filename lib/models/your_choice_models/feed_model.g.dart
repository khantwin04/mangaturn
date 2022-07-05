// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FeedModelAdapter extends TypeAdapter<FeedModel> {
  @override
  final int typeId = 1;

  @override
  FeedModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FeedModel(
      uploaderName: fields[0] as String,
      uploaderCover: fields[1] as String,
      mangaId: fields[2] as int,
      mangaName: fields[3] as String,
      mangaCover: fields[4] as String,
      mangaDescription: fields[5] as String,
      chapterId: fields[6] as int,
      chapterName: fields[7] as String,
      isFree: fields[8] as bool,
      point: fields[9] as int,
      isPurchase: fields[10] as bool,
      updateType: fields[11] as String,
      timeStamp: fields[12] as DateTime?,
      title: fields[13] as String,
      body: fields[14] as String,
      chapterNo: fields[15] as int,
      totalPages: fields[16] as int,
    );
  }

  @override
  void write(BinaryWriter writer, FeedModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.uploaderName)
      ..writeByte(1)
      ..write(obj.uploaderCover)
      ..writeByte(2)
      ..write(obj.mangaId)
      ..writeByte(3)
      ..write(obj.mangaName)
      ..writeByte(4)
      ..write(obj.mangaCover)
      ..writeByte(5)
      ..write(obj.mangaDescription)
      ..writeByte(6)
      ..write(obj.chapterId)
      ..writeByte(7)
      ..write(obj.chapterName)
      ..writeByte(8)
      ..write(obj.isFree)
      ..writeByte(9)
      ..write(obj.point)
      ..writeByte(10)
      ..write(obj.isPurchase)
      ..writeByte(11)
      ..write(obj.updateType)
      ..writeByte(12)
      ..write(obj.timeStamp)
      ..writeByte(13)
      ..write(obj.title)
      ..writeByte(14)
      ..write(obj.body)
      ..writeByte(15)
      ..write(obj.chapterNo)
      ..writeByte(16)
      ..write(obj.totalPages);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FeedModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FeedModel _$FeedModelFromJson(Map<String, dynamic> json) {
  return FeedModel(
    uploaderName: json['uploaderName'] as String,
    uploaderCover: json['uploaderCover'] as String,
    mangaId: json['mangaId'] as int,
    mangaName: json['mangaName'] as String,
    mangaCover: json['mangaCover'] as String,
    mangaDescription: json['mangaDescription'] as String,
    chapterId: json['chapterId'] as int,
    chapterName: json['chapterName'] as String,
    isFree: json['isFree'] as bool,
    point: json['point'] as int,
    isPurchase: json['isPurchase'] as bool,
    updateType: json['updateType'] as String,
    timeStamp: json['timeStamp'] == null
        ? null
        : DateTime.parse(json['timeStamp'] as String),
    title: json['title'] as String,
    body: json['body'] as String,
    chapterNo: json['chapterNo'] as int,
    totalPages: json['totalPages'] as int,
  );
}

Map<String, dynamic> _$FeedModelToJson(FeedModel instance) => <String, dynamic>{
      'uploaderName': instance.uploaderName,
      'uploaderCover': instance.uploaderCover,
      'mangaId': instance.mangaId,
      'mangaName': instance.mangaName,
      'mangaCover': instance.mangaCover,
      'mangaDescription': instance.mangaDescription,
      'chapterId': instance.chapterId,
      'chapterName': instance.chapterName,
      'isFree': instance.isFree,
      'point': instance.point,
      'isPurchase': instance.isPurchase,
      'updateType': instance.updateType,
      'timeStamp': instance.timeStamp?.toIso8601String(),
      'title': instance.title,
      'body': instance.body,
      'chapterNo': instance.chapterNo,
      'totalPages': instance.totalPages,
    };
