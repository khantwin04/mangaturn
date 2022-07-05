import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mangaturn/custom_widgets/bottom_sheet/recent_chapter_btn_sheet.dart';
import 'package:mangaturn/custom_widgets/header.dart';
import 'package:mangaturn/landing_screen.dart';
import 'package:mangaturn/models/chapter_models/recent_chapter_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/services/bloc/firestore/get_follow_cubit.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'dart:io';
import 'package:mangaturn/services/bloc/get/get_download_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/ui/detail/offline_reader.dart';
import 'package:mangaturn/ui/my_list/detail/recent_reading_list.dart';
import 'package:mangaturn/ui/my_list/download_list.dart';
import 'package:mangaturn/ui/my_list/favourite_list.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangaturn/ui/my_list/followed_list.dart';

class MyListView extends StatefulWidget {
  final bool noInternet;

  MyListView({this.noInternet = false});

  @override
  _MyListViewState createState() => _MyListViewState();
}

class _MyListViewState extends State<MyListView> {
  DBHelper _dbHelper = new DBHelper();
  List<RecentChapterModel> recentList = [];
  bool loading = false;

  @override
  void initState() {
    BlocProvider.of<GetDownloadMangaCubit>(context).getMangaList();
    BlocProvider.of<GetFollowCubit>(context).getFollowList();
    BlocProvider.of<DownloadCubit>(context).emit(DownloadInitial());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My List',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: AnimationLimiter(
          child: Column(
            children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                      horizontalOffset: 50.0,
                      child: FadeInAnimation(
                        child: widget,
                      ),
                    ),
                children: [
                  widget.noInternet
                      ? Container(
                          width: double.infinity,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => LandingScreen(),
                                    ),
                                    (route) => false);
                              },
                              child: Text('No Internet Connection : Retry')),
                        )
                      : Container(),
                  BlocConsumer<GetRecentChapterCubit, GetRecentChapterState>(
                    listener: (context, state) {
                      if (state is GetRecentChapterSuccess) {
                        setState(() {
                          recentList.clear();
                          recentList = state.recentList;
                        });
                      }
                    },
                    builder: (context, state) {
                      if (state is GetRecentChapterFail) {
                        return Text(state.error);
                      } else if (state is GetRecentChapterSuccess) {
                        return state.recentList.length == 0
                            ? Container()
                            : Column(
                                children: [
                                  Header(context, 'Resume Reading',
                                      seeMore: true),
                                  Card(
                                    margin: EdgeInsets.all(10.0),
                                    child: Container(
                                      height: 200,
                                      padding: EdgeInsets.all(10.0),
                                      child: SingleChildScrollView(
                                        child: Row(
                                          children: state.recentList
                                              .map((e) => Container(
                                                    height: 200,
                                                    width: 350,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceAround,
                                                      children: [
                                                        ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                          child:
                                                              e.resumeImage ==
                                                                      null
                                                                  ? Container(
                                                                      height:
                                                                          100,
                                                                      color: Colors
                                                                          .grey,
                                                                    )
                                                                  : Image.file(
                                                                      File(e
                                                                          .resumeImage!),
                                                                      width:
                                                                          120,
                                                                      height:
                                                                          200,
                                                                      fit: BoxFit
                                                                          .cover,
                                                                    ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(10.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Text(
                                                                  e.chapterName!,
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          18),
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                  maxLines: 2,
                                                                ),
                                                                Text(
                                                                  e.mangaName!,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                                SizedBox(
                                                                  height: 2,
                                                                ),
                                                                Text(
                                                                  e.resumePageNo
                                                                          .toString() +
                                                                      "/" +
                                                                      e.totalPage
                                                                          .toString(),
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .black,
                                                                  ),
                                                                ),
                                                                Spacer(),
                                                                Container(
                                                                    width: double
                                                                        .infinity,
                                                                    child: Row(
                                                                      children: [
                                                                        Expanded(
                                                                          child:
                                                                              ElevatedButton(
                                                                            onPressed:
                                                                                () {
                                                                              DownloadChapter chapter = DownloadChapter(
                                                                                chapterId: e.chapterId,
                                                                                chapterName: e.chapterName,
                                                                                mangaId: e.mangaId,
                                                                                totalPage: e.totalPage,
                                                                              );
                                                                              Navigator.pushNamed(context, OfflineReader.routeName, arguments: [
                                                                                e.chapterId,
                                                                                e.chapterName,
                                                                                e.mangaName,
                                                                                e.mangaId,
                                                                                [
                                                                                  chapter
                                                                                ],
                                                                                0,
                                                                              ]);
                                                                            },
                                                                            child:
                                                                                FittedBox(
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
                                                                          width:
                                                                              10,
                                                                        ),
                                                                        Expanded(
                                                                          child: ElevatedButton(
                                                                              onPressed: () {
                                                                                MoreRecentChapter(context, e.mangaId!, e.mangaName!, e.chapterId!);
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
                                                  ))
                                              .toList(),
                                        ),
                                        scrollDirection: Axis.horizontal,
                                      ),
                                    ),
                                  ),
                                ],
                              );
                      } else {
                        return recentList.length == 0
                            ? Container()
                            : Column(
                                children: [
                                  Header(context, 'Resume Reading',
                                      seeMore: true),
                                  Card(
                                    margin: EdgeInsets.all(10.0),
                                    child: Container(
                                      height: 200,
                                      padding: EdgeInsets.all(10.0),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: recentList
                                              .map((e) => Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10.0),
                                                        child: e.resumeImage ==
                                                                null
                                                            ? Container(
                                                                height: 100,
                                                                color:
                                                                    Colors.grey,
                                                              )
                                                            : Image.file(
                                                                File(e
                                                                    .resumeImage!),
                                                                width: 120,
                                                                height: 200,
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(10.0),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Text(
                                                                e.chapterName!,
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                                maxLines: 2,
                                                              ),
                                                              Text(
                                                                e.mangaName!,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis,
                                                              ),
                                                              SizedBox(
                                                                height: 2,
                                                              ),
                                                              Text(
                                                                e.resumePageNo
                                                                        .toString() +
                                                                    "/" +
                                                                    e.totalPage
                                                                        .toString(),
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              Container(
                                                                  width: double
                                                                      .infinity,
                                                                  child: Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            ElevatedButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pushNamed(context, OfflineReader.routeName, arguments: [
                                                                              e.chapterId,
                                                                              e.chapterName,
                                                                              e.mangaName,
                                                                              e.mangaId,
                                                                            ]);
                                                                          },
                                                                          child:
                                                                              FittedBox(
                                                                            child:
                                                                                Text(
                                                                              'Read',
                                                                              style: TextStyle(
                                                                                color: Colors.white,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Expanded(
                                                                        child: ElevatedButton(
                                                                            onPressed: () {
                                                                              MoreRecentChapter(context, e.mangaId!, e.mangaName!, e.chapterId!);
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
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                      }
                    },
                  ),
                  Header(context, 'Library'),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => RecentReading(),
                      ));
                    },
                    leading: FaIcon(
                      FontAwesomeIcons.save,
                      color: Colors.brown,
                    ),
                    title: Text('Resume Reading List'),
                    subtitle: Text(
                        'Resume Reading only work on downloaded chapters.'),
                    trailing: IconButton(
                      icon: Icon(Icons.navigate_next_rounded),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => RecentReading(),
                        ));
                      },
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => DownloadList(),
                      ));
                    },
                    leading: FaIcon(
                      FontAwesomeIcons.download,
                      color: Colors.teal,
                    ),
                    title: Text('Downloaded'),
                    subtitle: Text(BlocProvider.of<GetDownloadMangaCubit>(
                                context,
                                listen: true)
                            .downloadMangaList
                            .toString() +
                        " manga"),
                    trailing: IconButton(
                      icon: Icon(Icons.navigate_next_rounded),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => DownloadList(),
                        ));
                      },
                    ),
                  ),
                  // ListTile(
                  //   onTap: () {
                  //     Navigator.of(context).push(MaterialPageRoute(
                  //       builder: (context) => FavList(),
                  //     ));
                  //   },
                  //   leading: Icon(
                  //     Icons.favorite,
                  //     color: Colors.redAccent,
                  //   ),
                  //   title: Text('Favourite'),
                  //   subtitle: Text(
                  //       BlocProvider.of<GetFavMangaCubit>(context, listen: true)
                  //               .getFavMangaCount
                  //               .toString() +
                  //           ' Manga'),
                  //   trailing: IconButton(
                  //     icon: Icon(Icons.navigate_next_rounded),
                  //     onPressed: () {
                  //       Navigator.of(context).push(MaterialPageRoute(
                  //         builder: (context) => FavList(),
                  //       ));
                  //     },
                  //   ),
                  // ),
                  // ListTile(
                  //   leading: FaIcon(
                  //     FontAwesomeIcons.solidThumbsUp,
                  //     color: Colors.indigo,
                  //   ),
                  //   title: Text('Liked Manga'),
                  //   subtitle: Text('12 Manga'),
                  //   trailing: IconButton(
                  //     icon: Icon(Icons.navigate_next_rounded),
                  //     onPressed: () {},
                  //   ),
                  // ),
                  ListTile(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => FollowedList(),
                      ));
                    },
                    leading: FaIcon(
                      FontAwesomeIcons.bell,
                      color: Colors.black,
                    ),
                    title: Text('Followed Uploaders'),
                    subtitle: Text(
                        BlocProvider.of<GetFollowCubit>(context, listen: true)
                                .getFollowCount
                                .toString() +
                            ' Uploaders'),
                    trailing: IconButton(
                      icon: Icon(Icons.navigate_next_rounded),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FollowedList(),
                        ));
                      },
                    ),
                  ),
                  // ListTile(
                  //   leading: FaIcon(
                  //     FontAwesomeIcons.bell,
                  //     color: Colors.green,
                  //   ),
                  //   title: Text('Followed Manga'),
                  //   subtitle: Text('8 Manga'),
                  //   trailing: IconButton(
                  //     icon: Icon(Icons.navigate_next_rounded),
                  //     onPressed: () {},
                  //   ),
                  // ),
                ]),
          ),
        ),
      ),
    );
  }
}
