import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:mangaturn/models/your_choice_models/resume_model.dart';
import 'package:mangaturn/services/bloc/choice/resume_cubit.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:readmore/readmore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/ui/detail/reader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'bottom_sheet/latest_chapters_bt_sheet.dart';

Future<void> _onOpen(LinkableElement link) async {
  if (await canLaunch(link.url)) {
    await launch(link.url, forceSafariVC: false);
  } else {
    throw 'Could not launch $link';
  }
}

Widget ChapterInsertNotiWidget(FeedModel feed, Box<FeedModel> box,
    int boxLength, int index, BuildContext context) {
  return Card(
    shape: BeveledRectangleBorder(),
    margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(feed.uploaderCover),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feed.uploaderName),
                  Text("${timeago.format(
                    feed.timeStamp!,
                  )}"),
                ],
              ),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    box.deleteAt(boxLength - index - 1);
                  }),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: ReadMoreText(
              feed.body,
              trimLines: 4,
              colorClickableText: Colors.pink,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Show more',
              trimExpandedText: '',
              moreStyle: TextStyle(fontSize: 14, color: Colors.blue),
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: feed.mangaCover,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        feed.chapterName,
                        style: TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        feed.mangaName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      feed.isFree
                          ? Text("FREE  |  ${feed.totalPages} Pages")
                          : feed.isPurchase == true
                              ? Text('Purchased | Download Available')
                              : Text(
                                  "PAID" +
                                      "  -  ${feed.point} Points   |  ${feed.totalPages} Pages",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                  ),
                                ),
                      Spacer(),
                      Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    ResumeModel resume = ResumeModel(
                                        mangaId: feed.mangaId,
                                        currentChapterIndex: 0,
                                        title: feed.title,
                                        chapterName: feed.chapterName,
                                        chapterId: feed.chapterId,
                                        newChapterAvailable: false,
                                        newChapterId: 0,
                                        newChapterName: '',
                                        key: feed.mangaId,
                                        cover: feed.mangaCover,
                                        timeStamp: DateTime.now());

                                    BlocProvider.of<ResumeCubit>(context)
                                        .saveResume(resume);
                                    ChapterModel chapter = ChapterModel(
                                        id: feed.chapterId,
                                        chapterName: feed.chapterName,
                                        chapterNo: feed.chapterNo,
                                        type: feed.isFree ? "FREE" : "PAID",
                                        point: feed.point,
                                        isPurchase: feed.isPurchase,
                                        totalPages: feed.totalPages);
                                    Navigator.pushNamed(
                                        context, Reader.routeName,
                                        arguments: [
                                          chapter,
                                          <ChapterModel>[],
                                          boxLength - index - 1,
                                          'feed',
                                          feed.mangaId,
                                          feed.mangaCover,
                                        ]);
                                  },
                                  child: FittedBox(
                                    child: feed.isFree
                                        ? Text("READ")
                                        : feed.isPurchase == true
                                            ? Text('READ')
                                            : Text(
                                                'READ',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                  onPressed: () {
                                    ChapterModel chapterModel = ChapterModel(
                                      id: feed.chapterId,
                                      chapterNo: feed.chapterNo,
                                      totalPages: feed.totalPages,
                                      point: feed.point,
                                      chapterName: feed.chapterName,
                                      type: feed.isFree ? "FREE" : "PAID",
                                      isPurchase: feed.isPurchase,
                                      pages: [],
                                    );
                                    LatestChapterInfo(
                                      context,
                                      chapterModel,
                                      feed.mangaId,
                                      feed.mangaName,
                                      feed.mangaCover,
                                      downloaded: false,
                                    );
                                  },
                                  icon: Icon(Icons.more_vert_rounded)),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget ChapterUpdateNotiWidget(FeedModel feed, Box<FeedModel> box,
    int boxLength, int index, BuildContext context) {
  return Card(
    shape: BeveledRectangleBorder(),
    margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(feed.uploaderCover),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feed.uploaderName),
                  Text("${timeago.format(
                    feed.timeStamp!,
                  )}"),
                ],
              ),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    box.deleteAt(boxLength - index - 1);
                  }),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: ReadMoreText(
              feed.body,
              trimLines: 4,
              colorClickableText: Colors.pink,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Show more',
              trimExpandedText: '',
              moreStyle: TextStyle(fontSize: 14, color: Colors.blue),
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: feed.mangaCover,
                height: 150,
                width: 150,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 150,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        feed.chapterName,
                        style: TextStyle(fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                      Text(
                        feed.mangaName,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      feed.isFree
                          ? Text("FREE  |  ${feed.totalPages} Pages")
                          : feed.isPurchase == true
                              ? Text('Purchased | Download Available')
                              : Text(
                                  "PAID" +
                                      "  -  ${feed.point} Points   |  ${feed.totalPages} Pages",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                  ),
                                ),
                      Spacer(),
                      Container(
                          width: double.infinity,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  child: FittedBox(
                                    child: feed.isFree
                                        ? Text("READ")
                                        : feed.isPurchase == true
                                            ? Text('READ')
                                            : Text(
                                                'Purchase',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              IconButton(
                                  onPressed: () {
                                    ChapterModel chapterModel = ChapterModel(
                                      id: feed.chapterId,
                                      chapterNo: feed.chapterNo,
                                      totalPages: feed.totalPages,
                                      point: feed.point,
                                      chapterName: feed.chapterName,
                                      type: feed.isFree ? "FREE" : "PAID",
                                      isPurchase: feed.isPurchase,
                                      pages: [],
                                    );
                                    LatestChapterInfo(
                                      context,
                                      chapterModel,
                                      feed.mangaId,
                                      feed.mangaName,
                                      feed.mangaCover,
                                      downloaded: false,
                                    );
                                  },
                                  icon: Icon(Icons.more_vert_rounded)),
                            ],
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget MangaInsertNotiWidget(
  FeedModel feed,
  Box<FeedModel> box,
  int boxLength,
  int index,
  BuildContext context,
) {
  return Card(
    shape: BeveledRectangleBorder(),
    margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(feed.uploaderCover),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feed.uploaderName),
                  Text("${timeago.format(
                    feed.timeStamp!,
                  )}"),
                ],
              ),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    box.deleteAt(boxLength - index - 1);
                  }),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: ReadMoreText(
              feed.body,
              trimLines: 4,
              colorClickableText: Colors.pink,
              trimMode: TrimMode.Line,
              trimCollapsedText: 'Show more',
              trimExpandedText: '',
              moreStyle: TextStyle(fontSize: 14, color: Colors.blue),
              style: TextStyle(color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CachedNetworkImage(
                imageUrl: feed.mangaCover,
                height: 220,
                width: 180,
                fit: BoxFit.cover,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 220,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        feed.mangaName,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.indigo),
                      ),
                      Text(
                        feed.mangaDescription,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      Spacer(),
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 10.0),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                ComicDetail.routeName,
                                arguments: [null, feed.mangaId]);
                          },
                          child: Text('View'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget PostNotiWidget(FeedModel feed, Box<FeedModel> box, int boxLength,
    int index, BuildContext context) {
  return Card(
    shape: BeveledRectangleBorder(),
    margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 2.0),
    clipBehavior: Clip.antiAlias,
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(feed.uploaderCover),
              ),
              SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(feed.uploaderName),
                  Text("${timeago.format(
                    feed.timeStamp!,
                  )}"),
                ],
              ),
              Spacer(),
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    box.deleteAt(boxLength - index - 1);
                  }),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: double.infinity,
            child: Linkify(
              text: feed.body,
              onOpen: _onOpen,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    ),
  );
}
