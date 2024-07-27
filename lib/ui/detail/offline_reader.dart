import 'dart:io';
import 'dart:typed_data';
import 'package:mangaturn/models/chapter_models/recent_chapter_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineReader extends StatefulWidget {
  static const routeName = '/offline-reader';
  final List<Uint8List>? assets;
  final int? goto;
  final String? title;

  OfflineReader({this.assets, this.goto, this.title});

  @override
  _OfflineReaderState createState() => _OfflineReaderState();
}

class _OfflineReaderState extends State<OfflineReader> {
  bool hide = false;
  late ScrollController _scrollController;
  DBHelper _dbHelper = new DBHelper();
  int page = -1;
  bool scrollLoading = false;
  bool isLoading = false;
  bool noChapter = false;
  late PageController _pageController;
  List<Uint8List> assets = [];
  int goto = 0;
  List<DownloadPage> loadPageList = [];
  int? chapterId;
  String? chapterName;
  String? mangaName;
  int? mangaId;
  int resumePageNo = 0;
  double resumePosition = 0.0;
  double maxScrollPosition = 0.0;
  String? resumeImage;
  String? title;
  late List<DownloadChapter> chapterList;
  late int chapterIndex;

  void saveRecentReading() async {
    _showToast('Saved for resumed reading');
    RecentChapterModel recentChapter = RecentChapterModel(
      mangaId: mangaId,
      mangaName: mangaName,
      chapterId: chapterId,
      chapterName: chapterName,
      resumePageNo: resumePageNo,
      resumePosition:
          viewer == 'manga' ? 0.0 : _scrollController.position.pixels,
      totalPage: loadPageList.length,
      maxScrollPosition:
          viewer == 'manga' ? 0.0 : _scrollController.position.maxScrollExtent,
      resumeImage: resumeImage,
    );
    await _dbHelper.saveRecentChapter(recentChapter);
    BlocProvider.of<GetRecentChapterCubit>(context).getAllRecentChapterList();
  }

  void getPages() {
    _dbHelper.getPages(chapterList[chapterIndex].chapterId!).then((value) {
      setState(() {
        loadPageList = value;
        resumeImage = value[0].contentPage;
      });
      _dbHelper
          .getRecentChapterById(chapterList[chapterIndex].chapterId!)
          .then((value) {
        if (value.chapterId != null) {
          setState(() {
            resumePageNo = value.resumePageNo!;
            resumePosition = value.resumePosition!;
            maxScrollPosition = value.maxScrollPosition!;
            resumeImage = value.resumeImage;
          });
          _pageController = PageController(
            viewportFraction: 1,
            keepPage: false,
            initialPage: resumePageNo,
          );
          //_controller.animateToPage(pref.getInt('pageNo'), duration: Duration(seconds: 1), curve: Curves.bounceIn);
          _scrollController =
              ScrollController(initialScrollOffset: resumePosition);
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    List<dynamic> args = ModalRoute.of(context)!.settings.arguments as List;
    if (args == null || args.length == 0) {
      assets = widget.assets!;
      goto = widget.goto!;
      title = widget.title;
      _pageController = PageController(
        viewportFraction: 1,
        keepPage: false,
        initialPage: goto,
      );
    } else {
      chapterId = args[0];
      chapterName = args[1];
      mangaName = args[2];
      mangaId = args[3];
      chapterList = args[4] as List<DownloadChapter>;
      chapterIndex = args[5];
      getPages();
    }
    super.didChangeDependencies();
  }

  String viewer = 'manga';
  String res = 'FilterQuality.low';
  String direction = 'Axis.vertical';
  bool fav = false;

  Future<void> getViewerSetting() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString('viewer') != null) {
      setState(() {
        viewer = pref.getString('viewer')!;
      });
    }
    if (pref.getString('res') != null) {
      setState(() {
        res = pref.getString('res')!;
      });
    }
    if (pref.getString('direction') != null) {
      setState(() {
        direction = pref.getString('direction')!;
      });
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewer == 'manga'
                                ? Colors.white70
                                : Colors.black54,
                          ),
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: viewer == 'webtoon'
                                ? Colors.white70
                                : Colors.black54,
                          ),
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
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: direction == 'Axis.vertical'
                                ? Colors.white70
                                : Colors.black54,
                          ),
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
                      viewer == 'webtoon'
                          ? Container()
                          : Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      direction == 'Axis.horizontal'
                                          ? Colors.white70
                                          : Colors.black54,
                                ),
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

  void changeRes(String change) {
    setState(() {
      res = change;
    });
    saveReaderSetting();
  }

  void changeDir(String change) {
    setState(() {
      direction = change;
    });
    saveReaderSetting();
  }

  FilterQuality getRes() {
    if (res == 'FilterQuality.high') {
      print('high');
      return FilterQuality.high;
    } else if (res == 'FilterQuality.medium') {
      print('medium');
      return FilterQuality.medium;
    } else {
      print('low');
      return FilterQuality.low;
    }
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
    pref.setString("viewer", viewer);
    pref.setString("res", res);
    pref.setString("direction", direction);
  }

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

  late FToast fToast;

  _showToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey[100],
      ),
      child: Text(text),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
    );
  }

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    _pageController = PageController(
      viewportFraction: 1,
      keepPage: false,
    );
    //_controller.animateToPage(pref.getInt('pageNo'), duration: Duration(seconds: 1), curve: Curves.bounceIn);
    _scrollController = ScrollController();
    getViewerSetting();
    scaleStateController = PhotoViewScaleStateController();
    super.initState();
  }

  @override
  void dispose() {
    scaleStateController.dispose();
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget appBar() {
    return AppBar(
      actions: [
        IconButton(
          icon: Icon(
            Icons.settings,
            color: Colors.white,
          ),
          onPressed: () {
            changeSetting();
          },
        ),
        assets.length != 0
            ? Container()
            : IconButton(
                icon: Icon(
                  Icons.save,
                  color: Colors.white,
                ),
                onPressed: () {
                  saveRecentReading();
                },
              )
      ],
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.black87,
      title: Text(
        (title == null ? chapterList[chapterIndex].chapterName : title)!,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  late PhotoViewScaleStateController scaleStateController;

  ScrollPhysics scrollPhy = BouncingScrollPhysics();

  bool init = true;
  String? cover;

  String? pageContentImg;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          loadPageList.length == 0 && assets.length == 0
              ? Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child: Center(child: CircularProgressIndicator()),
                )
              : viewer == 'manga'
                  ? GestureDetector(
                      onTap: () {
                        setState(() {
                          hide = !hide;
                        });
                      },
                      child: PageView.builder(
                        reverse: direction == "Axis.horizontal" ? true : false,
                        controller: _pageController,
                        physics: scrollPhy,
                        pageSnapping: true,
                        clipBehavior: Clip.hardEdge,
                        scrollDirection: getDir(),
                        itemCount: assets.isNotEmpty
                            ? assets.length
                            : loadPageList.length,
                        onPageChanged: (pageNo) {
                          print("Resume $resumePageNo");
                          print(loadPageList.length);
                          if (assets.isEmpty) {
                            setState(() {
                              resumePageNo = pageNo;
                              resumeImage = loadPageList[pageNo].contentPage;
                            });
                          }
                        },
                        itemBuilder: (context, page) {
                          if (assets.isNotEmpty) {
                            return PhotoView(
                              scaleStateController: scaleStateController,
                              loadingBuilder: (_, img) => img == null
                                  ? Center(child: CircularProgressIndicator())
                                  : Center(
                                      child: CircularProgressIndicator(
                                        value: img.expectedTotalBytes != null
                                            ? img.cumulativeBytesLoaded /
                                                img.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                              scaleStateChangedCallback: (v) {
                                if (scaleStateController.scaleState ==
                                    PhotoViewScaleState.initial) {
                                  setState(() {
                                    scrollPhy = BouncingScrollPhysics();
                                  });
                                } else {
                                  setState(() {
                                    scrollPhy = NeverScrollableScrollPhysics();
                                  });
                                }
                              },
                              tightMode: false,
                              filterQuality: getRes(),
                              imageProvider: MemoryImage(assets[page]),
                              gaplessPlayback: true,
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 2,
                              initialScale: PhotoViewComputedScale.contained,
                            );
                          } else {
                            return PhotoView(
                              scaleStateController: scaleStateController,
                              loadingBuilder: (_, img) => img == null
                                  ? Center(child: CircularProgressIndicator())
                                  : Center(
                                      child: CircularProgressIndicator(
                                        value: img.expectedTotalBytes != null
                                            ? img.cumulativeBytesLoaded /
                                                img.expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                              scaleStateChangedCallback: (v) {
                                if (scaleStateController.scaleState ==
                                    PhotoViewScaleState.initial) {
                                  setState(() {
                                    scrollPhy = BouncingScrollPhysics();
                                  });
                                } else {
                                  setState(() {
                                    scrollPhy = NeverScrollableScrollPhysics();
                                  });
                                }
                              },
                              tightMode: false,
                              filterQuality: getRes(),
                              imageProvider: FileImage(
                                  File(loadPageList[page].contentPage!)),
                              gaplessPlayback: true,
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 2,
                              initialScale: PhotoViewComputedScale.contained,
                            );
                          }
                        },
                      ),
                    )
                  : GestureDetector(
                      onTap: () {
                        setState(() {
                          hide = !hide;
                        });
                      },
                      child: Column(children: [
                        Expanded(
                          child: InteractiveViewer(
                            minScale: 1.0,
                            maxScale: 5.0,
                            child: ListView.builder(
                              cacheExtent: 20,
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              itemCount: assets.isNotEmpty
                                  ? assets.length
                                  : loadPageList.length,
                              itemBuilder: (context, page) {
                                if (assets.isNotEmpty) {
                                  return Image(
                                    filterQuality: getRes(),
                                    image: MemoryImage(assets[page]),
                                    gaplessPlayback: true,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                } else {
                                  return Image(
                                    filterQuality: getRes(),
                                    image: FileImage(
                                        File(loadPageList[page].contentPage!)),
                                    gaplessPlayback: true,
                                    loadingBuilder: (BuildContext context,
                                        Widget child,
                                        ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.5,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                                ? loadingProgress
                                                        .cumulativeBytesLoaded /
                                                    loadingProgress
                                                        .expectedTotalBytes!
                                                : null,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                        Container(
                          height: scrollLoading ? 50.0 : 0,
                          color: Colors.transparent,
                          child: Center(
                            child: new CircularProgressIndicator(),
                          ),
                        ),
                      ]),
                    ),
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
                  child: Container(
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
                                      OfflineReader.routeName,
                                      arguments: [
                                        chapterId,
                                        chapterName,
                                        mangaName,
                                        mangaId,
                                        chapterList,
                                        chapterIndex - 1,
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
                                    Navigator.popAndPushNamed(
                                      context,
                                      OfflineReader.routeName,
                                      arguments: [
                                        chapterId,
                                        chapterName,
                                        mangaName,
                                        mangaId,
                                        chapterList,
                                        chapterIndex + 1,
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
}
