import 'dart:io';

import 'package:mangaturn/custom_widgets/bottom_sheet/recent_chapter_btn_sheet.dart';
import 'package:mangaturn/models/chapter_models/recent_chapter_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/ui/detail/offline_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RecentReading extends StatefulWidget {
  @override
  _RecentReadingState createState() => _RecentReadingState();
}

class _RecentReadingState extends State<RecentReading> {
  List<RecentChapterModel> recentList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resume Reading List'),
      ),
      body: BlocConsumer<GetRecentChapterCubit, GetRecentChapterState>(
        listener: (context, state) {
          if (state is GetRecentChapterSuccess) {
            setState(() {
              recentList.clear();
              recentList = state.recentList;
            });
          }
        },
        builder: (context, state) {
          if (state is GetRecentChapterSuccess) {
            return ListView.builder(
                itemCount: state.recentList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    margin: EdgeInsets.all(10.0),
                    child: Container(
                      height: 200,
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: state.recentList[index].resumeImage == null
                                ? Container(
                                    height: 100,
                                    color: Colors.grey,
                                  )
                                : Image.file(
                                    File(state.recentList[index].resumeImage!),
                                    width: 120,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.recentList[index].chapterName!,
                                    style: TextStyle(fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    state.recentList[index].mangaName!,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    state.recentList[index].resumePageNo
                                            .toString() +
                                        "/" +
                                        state.recentList[index].totalPage
                                            .toString(),
                                    style: TextStyle(
                                      color: Colors.black,
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
                                                DownloadChapter chapter =
                                                    DownloadChapter(
                                                  chapterId: state
                                                      .recentList[index]
                                                      .chapterId,
                                                  chapterName: state
                                                      .recentList[index]
                                                      .chapterName,
                                                  mangaId: state
                                                      .recentList[index]
                                                      .mangaId,
                                                  totalPage: state
                                                      .recentList[index]
                                                      .totalPage,
                                                );
                                                Navigator.pushNamed(context,
                                                    OfflineReader.routeName,
                                                    arguments: [
                                                      state.recentList[index]
                                                          .chapterId,
                                                      state.recentList[index]
                                                          .chapterName,
                                                      state.recentList[index]
                                                          .mangaName,
                                                      state.recentList[index]
                                                          .mangaId,
                                                      [chapter],
                                                      0,
                                                    ]);
                                              },
                                              child: FittedBox(
                                                child: Text(
                                                  'Read',
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
                                          Expanded(
                                            child: ElevatedButton(
                                                onPressed: () {
                                                  MoreRecentChapter(
                                                      context,
                                                      state.recentList[index]
                                                          .mangaId!,
                                                      state.recentList[index]
                                                          .mangaName!,
                                                      state.recentList[index]
                                                          .chapterId!);
                                                },
                                                child: Text('More')),
                                          ),
                                        ],
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          } else if (state is GetRecentChapterFail) {
            return Center(
              child: Text(state.error),
            );
          }
          return ListView.builder(
              itemCount: recentList.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  margin: EdgeInsets.all(10.0),
                  child: Container(
                    height: 200,
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: recentList[index].resumeImage == null
                              ? Container(
                                  height: 100,
                                  color: Colors.grey,
                                )
                              : Image.file(
                                  File(recentList[index].resumeImage!),
                                  width: 120,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recentList[index].chapterName!,
                                  style: TextStyle(fontSize: 18),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                Text(
                                  recentList[index].mangaName!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  recentList[index].resumePageNo.toString() +
                                      "/" +
                                      recentList[index].totalPage.toString(),
                                  style: TextStyle(
                                    color: Colors.black,
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
                                              Navigator.pushNamed(context,
                                                  OfflineReader.routeName,
                                                  arguments: [
                                                    recentList[index].chapterId,
                                                    recentList[index]
                                                        .chapterName,
                                                    recentList[index].mangaName,
                                                    recentList[index].mangaId,
                                                  ]);
                                            },
                                            child: FittedBox(
                                              child: Text(
                                                'Read',
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
                                        Expanded(
                                          child: ElevatedButton(
                                              onPressed: () {
                                                MoreRecentChapter(
                                                    context,
                                                    recentList[index].mangaId!,
                                                    recentList[index]
                                                        .mangaName!,
                                                    recentList[index]
                                                        .chapterId!);
                                              },
                                              child: Text('More')),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
        },
      ),
    );
  }
}
