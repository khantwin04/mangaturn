import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/custom_widgets/notification_type.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NotificationHistory extends StatefulWidget {
  const NotificationHistory({Key? key}) : super(key: key);

  @override
  _NotificationHistoryState createState() => _NotificationHistoryState();
}

class _NotificationHistoryState extends State<NotificationHistory> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<FeedModel>('feedHistory').listenable(),
      builder: (context, Box<FeedModel> box, _) {
        if (box.values.isEmpty)
          return Container(
            height: 100,
            child: Center(child: Text("Your history is empty.")),
          );

        List<FeedModel> boxValues = box.values.toList();
        boxValues.sort((a, b) => a.timeStamp!.compareTo(b.timeStamp!));
        return ListView.builder(
          physics: BouncingScrollPhysics(),
          itemCount: boxValues.length,
          itemBuilder: (context, index) {
            FeedModel feed = box.getAt(boxValues.length - index - 1)!;
            if (feed.updateType == UpdateType.mangaInsert.toString()) {
              return MangaInsertNotiWidget(
                  feed, box, boxValues.length, index, context);
            } else if (feed.updateType == UpdateType.chapterInsert.toString()) {
              return ChapterInsertNotiWidget(
                  feed, box, boxValues.length, index, context);
            } else if (feed.updateType == UpdateType.chapterUpdate.toString()) {
              return ChapterUpdateNotiWidget(
                  feed, box, boxValues.length, index, context);
            } else {
              return PostNotiWidget(
                  feed, box, boxValues.length, index, context);
            }
          },
        );
      },
    );
  }
}
