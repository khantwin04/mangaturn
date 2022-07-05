import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/custom_widgets/purchase_chapter_confirm.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/chapter_models/page_model.dart';
import 'package:mangaturn/models/your_choice_models/resume_model.dart';
import 'package:mangaturn/services/bloc/ads/popup_cubit.dart';
import 'package:mangaturn/services/bloc/choice/resume_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/bloc/post/purchase_chapter_cubit.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mangaturn/ui/detail/manga_viewer.dart';
import 'package:mangaturn/ui/detail/webtoon_viewer.dart';
import 'package:mangaturn/ui/more/purchase_method.dart';
import 'dart:async';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Reader extends StatefulWidget {
  static const routeName = '/Online-Reader';

  @override
  _ReaderState createState() => _ReaderState();
}

class _ReaderState extends State<Reader> {
  late int index;
  bool hide = false;
  late ChapterModel chapterModel;
  late List<ChapterModel> chapterList;
  late int chapterIndex;
  late String sortType;
  String? token;

  String? viewer;
  String direction = 'Axis.vertical';
  bool fav = false;
  bool leftToRight = true;

  bool hasPreviousChapter() {
    try {
      print(chapterList[chapterIndex + 1]);
      print("has previous chapter.");
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  bool hasNextChapter() {
    try {
      print(chapterList[chapterIndex - 1]);
      print("has next chapter");
      return true;
    } catch (e) {
      print(e.toString());
      return false;
    }
  }

  Future<void> getViewerSetting() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      token = AuthFunction.getToken()!;
    });
    if (pref.getString('viewer') != null) {
      setState(() {
        viewer = pref.getString('viewer')!;
      });
    } else {
      setState(() {
        viewer = 'webtoon';
      });
    }
    if (pref.getString('direction') != null) {
      direction = pref.getString('direction')!;
    }
    if (pref.getBool('swipe') != null) {
      leftToRight = pref.getBool('swipe')!;
    }
  }

  void changeSetting() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.black54,
              title: Text(
                'Setting',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: RaisedButton(
                          color: viewer == 'manga'
                              ? Colors.white70
                              : Colors.black54,
                          child: Text(
                            'Manga',
                            style: TextStyle(
                              color: viewer == 'manga'
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          onPressed: () {
                            changeViewer('manga');
                            setState(() {});
                          },
                        ),
                      ),
                      Expanded(
                        child: RaisedButton(
                          color: viewer == 'webtoon'
                              ? Colors.white70
                              : Colors.black54,
                          child: Text(
                            'Webtoon',
                            style: TextStyle(
                              color: viewer == 'webtoon'
                                  ? Colors.black
                                  : Colors.white,
                            ),
                          ),
                          onPressed: () {
                            changeViewer('webtoon');
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  ),
                  viewer == 'webtoon'
                      ? Container()
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: double.infinity,
                              child: Text(
                                'Scroll Direction',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: RaisedButton(
                                    color: direction == 'Axis.vertical'
                                        ? Colors.white70
                                        : Colors.black54,
                                    child: Icon(
                                      Icons.swap_vertical_circle_outlined,
                                      color: direction == 'Axis.vertical'
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      changeDir('Axis.vertical');
                                      setState(() {});
                                    },
                                  ),
                                ),
                                Expanded(
                                  child: RaisedButton(
                                    color: direction == 'Axis.horizontal'
                                        ? Colors.white70
                                        : Colors.black54,
                                    child: Icon(
                                      Icons.swap_horizontal_circle_outlined,
                                      color: direction == 'Axis.horizontal'
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                    onPressed: () {
                                      changeDir('Axis.horizontal');
                                      setState(() {});
                                    },
                                  ),
                                ),
                              ],
                            ),
                            direction == 'Axis.vertical'
                                ? Container()
                                : Column(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        child: Text(
                                          'Swipe',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: RaisedButton(
                                              color: leftToRight == true
                                                  ? Colors.white70
                                                  : Colors.black54,
                                              child: Text(
                                                'Left->Right',
                                                style: TextStyle(
                                                  color: leftToRight == true
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                              onPressed: () {
                                                changeSwipe();
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: RaisedButton(
                                              color: leftToRight == false
                                                  ? Colors.white70
                                                  : Colors.black54,
                                              child: Text(
                                                'Right->Left',
                                                style: TextStyle(
                                                  color: leftToRight == false
                                                      ? Colors.black
                                                      : Colors.white,
                                                ),
                                              ),
                                              onPressed: () {
                                                changeSwipe();
                                                setState(() {});
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  )
                          ],
                        ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void changeViewer(String change) {
    setState(() {
      viewer = change;
    });
    saveReaderSetting();
  }

  void changeDir(String change) {
    setState(() {
      direction = change;
    });
    saveReaderSetting();
  }

  void changeSwipe() {
    setState(() {
      leftToRight = !leftToRight;
    });
    saveReaderSetting();
  }

  Axis getDir() {
    if (direction == 'Axis.vertical') {
      return Axis.vertical;
    } else {
      return Axis.horizontal;
    }
  }

  Future<void> saveReaderSetting() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString("viewer", viewer!);
    pref.setString("direction", direction);
    pref.setBool('swipe', leftToRight);
  }

  @override
  void initState() {
    super.initState();
  }

  late bool isPaidChapter;
  late int mangaId;
  late String mangaCover;

  @override
  void didChangeDependencies() {
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args != null) {
      List data = args as List;
      chapterModel = data[0];
      chapterList = data[1] as List<ChapterModel>;
      chapterIndex = data[2];
      sortType = data[3] == null ? 'desc' : data[3];
      mangaId = data[4];
      mangaCover = data[5];
    }

    print(chapterModel.isPurchase);

    print(
        "check chapter ${chapterModel.isPurchase == true || chapterModel.isPurchase == null || chapterModel.type == "FREE"}");
    if (chapterModel.type == "PAID") {
      if (chapterModel.isPurchase == true) {
        getViewerSetting();
        isPaidChapter = false;
      } else {
        isPaidChapter = true;
      }
    } else {
      getViewerSetting();
      isPaidChapter = false;
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget appBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      actions: [
        IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              changeSetting();
            }),
      ],
      backgroundColor: Colors.black87,
      title: Text(
        chapterModel.chapterName,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          isPaidChapter
              ? BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
                  builder: (context, state) {
                    if (state is GetUserProfileSuccess) {
                      if (state.user.role == "ADMIN" ||
                          state.user.role == "ORGANIZER") {
                        getViewerSetting();
                        isPaidChapter = false;
                      }
                      return Center(
                        child: Container(
                          padding: EdgeInsets.all(30.0),
                          // decoration: BoxDecoration(
                          //     color: Colors.black38,
                          //     borderRadius: BorderRadius.circular(5.0),
                          //     boxShadow: [
                          //       BoxShadow(
                          //           color: Colors.white10,
                          //           offset: Offset(0, 1))
                          //     ],
                          //     border: Border.all(
                          //       color: Colors.white,
                          //       style: BorderStyle.solid,
                          //     )),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'This chapter is paid chapter.\n You have to buy this chapter to read.',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Divider(
                                color: Colors.white,
                              ),
                              Text(
                                "You have ${state.user.point} point",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Container(
                                width: 200,
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PurchaseMethod(
                                                    user: state.user),
                                          ));
                                    },
                                    child: Text('Buy Point')),
                              ),
                              Text(
                                "Point : ${chapterModel.point}",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.redAccent),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                chapterModel.chapterName,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                "Total page : ${chapterModel.totalPages}",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                              Container(
                                width: 200,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      bool result =
                                          await confirmPurchase(context);
                                      if (result) {
                                        BlocProvider.of<PurchaseChapterCubit>(
                                                context)
                                            .purchaseChapter(
                                                chapterModel.id, context);
                                        bool success = await PurchaseChapter(
                                            context, chapterModel.chapterName);
                                        if (success) {
                                          setState(() {
                                            isPaidChapter = false;
                                          });
                                          getViewerSetting();
                                          if (sortType == 'feed') {
                                            var box =
                                                Hive.box<FeedModel>('feed');
                                            FeedModel feed =
                                                box.getAt(chapterIndex)!;
                                            FeedModel updateFeed = FeedModel(
                                              uploaderName: feed.uploaderName,
                                              uploaderCover: feed.uploaderCover,
                                              mangaId: mangaId,
                                              mangaName: feed.mangaName,
                                              mangaCover: feed.mangaCover,
                                              mangaDescription:
                                                  feed.mangaDescription,
                                              chapterId: feed.chapterId,
                                              chapterName: feed.chapterName,
                                              isFree: feed.isFree,
                                              point: feed.point,
                                              isPurchase: true,
                                              updateType: feed.updateType,
                                              title: feed.title,
                                              body: feed.body,
                                              chapterNo: feed.chapterNo,
                                              totalPages: feed.totalPages,
                                              timeStamp: DateTime.now(),
                                            );
                                            box.putAt(chapterIndex, updateFeed);
                                          }
                                        }
                                      }
                                    },
                                    child: Text('Purchase this chapter')),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  'Not Now',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      return Center(
                          child: Text(
                        'Loading',
                        style: TextStyle(color: Colors.white),
                      ));
                    }
                  },
                )
              : token == null
                  ? loading()
                  : viewer == 'manga'
                          ? MangaViewer(
                              chapterModel: chapterModel,
                              token: token!,
                              scrollDirection: getDir(),
                              direction: direction,
                              hide: (data) {
                                print(data);
                                setState(() {
                                  hide = data;
                                });
                              },
                              leftToRight: leftToRight,
                            )
                          : WebtoonViewer(
                              chapterModel: chapterModel,
                              token: token!,
                              hide: (data) {
                                print(data);
                                setState(() {
                                  hide = data;
                                });
                              }),
                    
          hide
              ? Container()
              : Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: appBar(),
                ),
          hide
              ? Container()
              : Positioned(
                  bottom: 0,
                  height: 50,
                  left: 0,
                  right: 0,
                  child: sortType == "asc"
                      ? Container(
                          width: double.infinity,
                          color: Colors.black87,
                          child: Row(
                            children: [
                              Expanded(
                                child: hasNextChapter()
                                    ? TextButton.icon(
                                        onPressed: () {
                                          Navigator.popAndPushNamed(
                                            context,
                                            Reader.routeName,
                                            arguments: [
                                              chapterList[chapterIndex - 1],
                                              chapterList,
                                              chapterIndex - 1,
                                              sortType,
                                              mangaId,
                                              mangaCover,
                                            ],
                                          );
                                        },
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Previous Chapter',
                                          style: TextStyle(color: Colors.white),
                                        ))
                                    : Container(),
                              ),
                              Expanded(
                                child: hasPreviousChapter()
                                    ? TextButton.icon(
                                        onPressed: () {
                                          ResumeModel resume = ResumeModel(
                                              mangaId: mangaId,
                                              currentChapterIndex: chapterIndex,
                                              title: '',
                                              chapterName:
                                                  chapterList[chapterIndex + 1]
                                                      .chapterName,
                                              chapterId:
                                                  chapterList[chapterIndex + 1]
                                                      .id,
                                              newChapterAvailable: false,
                                              newChapterId: 0,
                                              newChapterName: '',
                                              key: mangaId,
                                              cover: mangaCover,
                                              timeStamp: DateTime.now());

                                          BlocProvider.of<ResumeCubit>(context)
                                              .saveResume(resume);

                                          Navigator.popAndPushNamed(
                                            context,
                                            Reader.routeName,
                                            arguments: [
                                              chapterList[chapterIndex + 1],
                                              chapterList,
                                              chapterIndex + 1,
                                              sortType,
                                              mangaId,
                                              mangaCover,
                                            ],
                                          );
                                        },
                                        icon: Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Next Chapter',
                                          style: TextStyle(color: Colors.white),
                                        ))
                                    : Container(),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          width: double.infinity,
                          color: Colors.black87,
                          child: Row(
                            children: [
                              Expanded(
                                child: hasPreviousChapter()
                                    ? TextButton.icon(
                                        onPressed: () {
                                          Navigator.popAndPushNamed(
                                            context,
                                            Reader.routeName,
                                            arguments: [
                                              chapterList[chapterIndex + 1],
                                              chapterList,
                                              chapterIndex + 1,
                                              sortType,
                                              mangaId,
                                              mangaCover,
                                            ],
                                          );
                                        },
                                        icon: Icon(
                                          Icons.arrow_back,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Previous Chapter',
                                          style: TextStyle(color: Colors.white),
                                        ))
                                    : Container(),
                              ),
                              Expanded(
                                child: hasNextChapter()
                                    ? TextButton.icon(
                                        onPressed: () {
                                          ResumeModel resume = ResumeModel(
                                              mangaId: mangaId,
                                              currentChapterIndex: chapterIndex,
                                              title: '',
                                              chapterName:
                                                  chapterList[chapterIndex + 1]
                                                      .chapterName,
                                              chapterId:
                                                  chapterList[chapterIndex + 1]
                                                      .id,
                                              newChapterAvailable: false,
                                              newChapterId: 0,
                                              newChapterName: '',
                                              key: mangaId,
                                              cover: mangaCover,
                                              timeStamp: DateTime.now());

                                          BlocProvider.of<ResumeCubit>(context)
                                              .saveResume(resume);

                                          Navigator.popAndPushNamed(
                                            context,
                                            Reader.routeName,
                                            arguments: [
                                              chapterList[chapterIndex - 1],
                                              chapterList,
                                              chapterIndex - 1,
                                              sortType,
                                              mangaId,
                                              mangaCover,
                                            ],
                                          );
                                        },
                                        icon: Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          'Next Chapter',
                                          style: TextStyle(color: Colors.white),
                                        ))
                                    : Container(),
                              ),
                            ],
                          ),
                        ),
                ),
        ],
      ),
    );
  }

  Widget loading() {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height,
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
