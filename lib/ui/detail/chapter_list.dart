import 'package:clipboard/clipboard.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/downloadAlertBox.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/custom_widgets/purchase_chapter_confirm.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_download_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/post/purchase_chapter_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/offline_reader.dart';
import 'package:mangaturn/ui/detail/reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

class ChapterList extends StatefulWidget {
  int mangaId;
  String manga_name;
  String manga_cover;

  ChapterList(
      {required this.mangaId,
      required this.manga_name,
      required this.manga_cover});

  @override
  _ChapterListState createState() => _ChapterListState();
}

class _ChapterListState extends State<ChapterList> {
  late List<ChapterModel> _chapterList;
  late List<ChapterModel> _allChapterList;
  late ScrollController _controller;
  String sortType = 'asc';
  int page = 0;
  int? downloadProgress;
  bool downloadStart = false;
  bool finish = true;
  String? error;
  String? downloadingChapter;
  int? downloadingTotalPage;
  bool allChaptersDownload = false;
  bool? _infiniteStop;
  List<ChapterModel> chooseChapter = [];
  List<ChapterModel> _selectAllChapters = [];
  bool selectAll = false;
  int size = 15;


  _scrollListener() {
    var isEnd = _controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange;
    if (isEnd) {
      setState(() {
        page += 1;
        BlocProvider.of<GetAllChapterCubit>(context, listen: false)
            .fetchChapters(widget.mangaId, "chapterNo", sortType, page, size);
      });
    }
  }

  void fetchData() {
    BlocProvider.of<GetAllChapterCubit>(context, listen: false)
        .fetchChapters(widget.mangaId, "chapterNo", sortType, page, size);
  }

  void fetchAllChapters() async {
    BlocProvider.of<GetAllChapterCubit>(context, listen: false).clear();
    await BlocProvider.of<GetAllChapterCubit>(context, listen: false)
        .fetchAllChapters(widget.mangaId, "chapterNo", sortType, page, 10000);
    fetchData();
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
    fetchAllChapters();
    BlocProvider.of<DownloadCubit>(context, listen: false).clear();
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller.addListener(_scrollListener);
    _infiniteStop = false;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void update() async {
    downloadingTotalPage = BlocProvider.of<DownloadCubit>(context).getTotalPage;
    _chapterList = BlocProvider.of<GetAllChapterCubit>(context).getChapters();
    _allChapterList =
        BlocProvider.of<GetAllChapterCubit>(context).getAllChapters();
    //  BlocProvider.of<GetLatestChaptersCubit>(context, listen: false).clear();
    //BlocProvider.of<GetLatestChaptersCubit>(context, listen: false).getLatestChapters(token);
  }

  void refresh() {
    setState(() {});
  }

  bool checkContainData(List<ChapterModel> chapters, int data) {
    for (ChapterModel chapter in chapters) {
      if (chapter.id == data) return true;
    }
    return false;
  }

  Future<bool> back() async {
    print(downloadStart);
    print(finish);
    if (downloadStart == false && finish == true) {
      Navigator.of(context).pop();
      return true;
    } else {
      _showToast('You can\'t quit while downloading..');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    update();

    return WillPopScope(
      onWillPop: back,
      child: Scaffold(
        appBar: PreferredSize(
          child: SafeArea(
            child: Card(
              child: ListTile(
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                title: allChaptersDownload
                    ? selectAll
                        ? InkWell(
                            onTap: () {
                              setState(() {
                                selectAll = false;
                                chooseChapter.clear();
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Deselect All'),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              print(_selectAllChapters);
                              setState(() {
                                selectAll = true;
                                chooseChapter.clear();
                                chooseChapter.addAll(_selectAllChapters);
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text('Select All'),
                            ))
                    : Text('Available Chapters'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                        icon: sortType == "asc"
                            ? FaIcon(FontAwesomeIcons.sortNumericUp)
                            : FaIcon(FontAwesomeIcons.sortNumericDown),
                        onPressed: () {
                          BlocProvider.of<DownloadCubit>(context).clear();
                          if (sortType == "desc") {
                            if (mounted) {
                              setState(() {
                                sortType = 'asc';
                                page = 0;
                              });
                              fetchData();
                              fetchAllChapters();
                            }
                          } else {
                            if (mounted) {
                              setState(() {
                                sortType = 'desc';
                                page = 0;
                              });
                              fetchData();
                              fetchAllChapters();
                            }
                          }
                        }),
                    IconButton(
                        icon: allChaptersDownload
                            ? Icon(Icons.cancel_outlined)
                            : FaIcon(FontAwesomeIcons.download),
                        onPressed: () {
                          setState(() {
                            _selectAllChapters.clear();
                            chooseChapter.clear();
                            selectAll = false;
                            allChaptersDownload = !allChaptersDownload;
                          });
                        }),
                  ],
                ),
              ),
            ),
          ),
          preferredSize: Size.fromHeight(80),
        ),
        body: Column(
          children: [
            BlocConsumer<GetAllChapterCubit, GetAllChapterState>(
              listener: (context, state) {
                if (state is GetAllChapterSuccess) {
                  if (mounted) {
                    setState(() {
                      _infiniteStop = false;
                    });
                  }
                } else if (state is GetAllChapterLoading) {
                  if (mounted) {
                    setState(() {
                      _infiniteStop = true;
                    });
                  }
                }
              },
              builder: (context, state) {
                if (state is GetAllChapterLoading && _chapterList.length == 0) {
                  return Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (state is GetAllChapterFail) {
                  return Expanded(
                    child: Center(
                      child: Text(state.error),
                    ),
                  );
                }
                return Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          controller: _controller,
                          itemCount: _chapterList.length,
                          itemBuilder: (context, index) {
                            if (_chapterList.length == 0) {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (allChaptersDownload) {
                              if (_chapterList[index].pages!.isEmpty) {
                                if (_chapterList[index].isPurchase == true ||
                                    _chapterList[index].type == "FREE") {
                                  if (checkContainData(_selectAllChapters,
                                          _chapterList[index].id) ==
                                      false) {
                                    _selectAllChapters.add(_chapterList[index]);
                                  }
                                  return Card(
                                    child: ListTile(
                                      onTap: () async {
                                        setState(() {
                                          checkContainData(chooseChapter,
                                                  _chapterList[index].id)
                                              ? chooseChapter
                                                  .remove(_chapterList[index])
                                              : chooseChapter
                                                  .add(_chapterList[index]);
                                        });
                                      },
                                      leading: Checkbox(
                                        value: checkContainData(chooseChapter,
                                            _chapterList[index].id),
                                        onChanged: (value) {
                                          setState(() {
                                            checkContainData(chooseChapter,
                                                    _chapterList[index].id)
                                                ? chooseChapter
                                                    .remove(_chapterList[index])
                                                : chooseChapter
                                                    .add(_chapterList[index]);
                                          });
                                        },
                                        //checkColor: Colors.black,
                                      ),
                                      title:
                                          Text(_chapterList[index].chapterName),
                                      subtitle: _chapterList[index]
                                                  .pages!
                                                  .length !=
                                              0
                                          ? Text("Downloaded")
                                          : _chapterList[index].type == "FREE"
                                              ? Text(
                                                  "FREE  |  ${_chapterList[index].totalPages} Pages")
                                              : _chapterList[index]
                                                          .isPurchase ==
                                                      true
                                                  ? Text(
                                                      'Purchased | Download Available')
                                                  : Text(
                                                      _chapterList[index].type +
                                                          "  -  ${_chapterList[index].point} Points   |  ${_chapterList[index].totalPages} Pages",
                                                      style: TextStyle(
                                                        color: Colors.indigo,
                                                      ),
                                                    ),
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return Container();
                              }
                            } else {
                              return Card(
                                child: ListTile(
                                  // trailing: IconButton(
                                  //   onPressed: () async {
                                  //     print('ok tap');
                                  //     Loading(context);
                                  //     ChapterModel createChapterModel = ChapterModel(
                                  //       id: _chapterList[index].id,
                                  //       chapterName: _chapterList[index].chapterName,
                                  //       type: _chapterList[index].type,
                                  //       chapterNo: _chapterList[index].chapterNo,
                                  //       point: _chapterList[index].point,
                                  //       totalPages: _chapterList[index].totalPages,
                                  //       isPurchase: _chapterList[index].isPurchase,
                                  //     );
                                  //     String link = await Utility.createChapterLink(
                                  //       chapterModel: createChapterModel,
                                  //       cover: widget.manga_cover,
                                  //     );
                                  //     print(link);
                                  //     Navigator.pop(context);
                                  //     showDialog(
                                  //       context: context,
                                  //       builder: (context) => AlertDialog(
                                  //         title: Text('Share it or copy it.'),
                                  //         content: Text(link),
                                  //         actions: [
                                  //           IconButton(
                                  //               icon: Icon(Icons.copy),
                                  //               onPressed: () async {
                                  //                 await FlutterClipboard.copy(link);
                                  //                 _showToast("Copied the link");
                                  //               }),
                                  //           IconButton(
                                  //               icon: Icon(Icons.share),
                                  //               onPressed: () {
                                  //                 Share.share(link);
                                  //               }),
                                  //         ],
                                  //       ),
                                  //     );
                                  //   },
                                  //   icon: FaIcon(
                                  //     FontAwesomeIcons.share,
                                  //     size: 13,
                                  //   ),
                                  // ),
                                  onTap: () async {
                                    if (_chapterList[index].pages!.length !=
                                        0) {
                                      DownloadChapter chapter = DownloadChapter(
                                        chapterId: _chapterList[index].id,
                                        chapterName:
                                            _chapterList[index].chapterName,
                                        mangaId: widget.mangaId,
                                        totalPage:
                                            _chapterList[index].totalPages,
                                      );
                                      Navigator.pushNamed(
                                          context, OfflineReader.routeName,
                                          arguments: [
                                            _chapterList[index].id,
                                            _chapterList[index].chapterName,
                                            widget.manga_name,
                                            widget.mangaId,
                                            [chapter],
                                            0,
                                          ]);
                                    } else {
                                      if (_chapterList[index].type == "PAID") {
                                        if (_chapterList[index].isPurchase ==
                                            true) {
                                          Navigator.pushNamed(
                                              context, Reader.routeName,
                                              arguments: [
                                                _chapterList[index],
                                                _allChapterList,
                                                index,
                                                sortType,
                                                widget.mangaId,
                                                widget.manga_cover,
                                              ]);
                                        } else {
                                          var result =
                                              await confirmPurchase(context);
                                          if (result == true) {
                                          

                                            BlocProvider.of<
                                                        PurchaseChapterCubit>(
                                                    context)
                                                .purchaseChapter(
                                                    _chapterList[index].id,
                                                    context);
                                            bool success =
                                                await PurchaseChapter(
                                                    context,
                                                    _chapterList[index]
                                                        .chapterName);
                                            if (success) {
                                              setState(() {
                                                page = 0;
                                              });
                                              fetchData();
                                              
                                            }
                                          }
                                        }
                                      } else {
                                        Navigator.pushNamed(
                                            context, Reader.routeName,
                                            arguments: [
                                              _chapterList[index],
                                              _allChapterList,
                                              index,
                                              sortType,
                                              widget.mangaId,
                                              widget.manga_cover,
                                            ]);
                                      }
                                    }
                                  },
                                  leading: allChaptersDownload
                                      ? Checkbox(
                                          value: false, onChanged: (data) {})
                                      : _chapterList[index].pages!.length != 0
                                          ? IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () async {
                                                DBHelper db = DBHelper();
                                                await db.deleteChapter(
                                                    _chapterList[index].id,
                                                    widget.mangaId,
                                                    false);
                                                BlocProvider.of<
                                                            GetRecentChapterCubit>(
                                                        context)
                                                    .deleteChapterById(
                                                        _chapterList[index].id);
                                                setState(() {
                                                  page = 0;
                                                });
                                                fetchData();
                                              },
                                            )
                                          : _chapterList[index].type == "PAID"
                                              ? _chapterList[index]
                                                          .isPurchase ==
                                                      true
                                                  ? IconButton(
                                                      icon: Icon(
                                                          Icons.download_sharp),
                                                      onPressed: () async {
                                                        await Permission.storage
                                                            .request();
                                                        confirmDownload(context)
                                                            .then(
                                                                (value) async {
                                                          if (value == true) {
                                                            await BlocProvider
                                                                    .of<DownloadCubit>(
                                                                        context)
                                                                .downloadIndividualChapter(
                                                                    _chapterList[
                                                                        index],
                                                                    widget
                                                                        .mangaId,
                                                                    widget
                                                                        .manga_cover,
                                                                    widget
                                                                        .manga_name);
                                                          }
                                                        });
                                                      },
                                                    )
                                                  : IconButton(
                                                      icon:
                                                          Icon(Icons.payments),
                                                      onPressed: () {},
                                                    )
                                              : IconButton(
                                                  icon: Icon(
                                                      Icons.download_sharp),
                                                  onPressed: () async {
                                                    Utility.requestPermission();
                                                    confirmDownload(context)
                                                        .then((value) async {
                                                      if (value == true) {
                                                        await BlocProvider.of<
                                                                    DownloadCubit>(
                                                                context)
                                                            .downloadIndividualChapter(
                                                                _chapterList[
                                                                    index],
                                                                widget.mangaId,
                                                                widget
                                                                    .manga_cover,
                                                                widget
                                                                    .manga_name);
                                                      }
                                                    });
                                                  },
                                                ),
                                  title: Text(_chapterList[index].chapterName),
                                  subtitle: _chapterList[index].pages!.length !=
                                          0
                                      ? Text("Downloaded")
                                      : _chapterList[index].type == "FREE"
                                          ? Text(
                                              "FREE  |  ${_chapterList[index].totalPages} Pages")
                                          : _chapterList[index].isPurchase ==
                                                  true
                                              ? Text(
                                                  'Purchased | Download Available')
                                              : Text(
                                                  _chapterList[index].type +
                                                      "  -  ${_chapterList[index].point} Points   |  ${_chapterList[index].totalPages} Pages",
                                                  style: TextStyle(
                                                    color: Colors.indigo,
                                                  ),
                                                ),
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Container(
                        child: Center(
                          child: LinearProgressIndicator(),
                        ),
                        height: _infiniteStop! ? 20 : 0,
                      ),
                    ],
                  ),
                );
              },
            ),
            BlocConsumer<DownloadCubit, DownloadState>(
              builder: (context, state) {
                if (state is DownloadLoading) {
                  return Card(
                    child: ListTile(
                      title: Text('Downloading ${state.downloadingChapter}'),
                      subtitle: Row(
                        children: [
                          Expanded(child: LinearProgressIndicator()),
                          SizedBox(
                            width: 10,
                          ),
                          Text("$downloadProgress/$downloadingTotalPage")
                        ],
                      ),
                    ),
                  );
                } else if (state is DownloadProgress) {
                  return Card(
                    child: ListTile(
                      title: Text('Downloading ${state.downloadingChapter}'),
                      subtitle: Row(
                        children: [
                          Expanded(child: LinearProgressIndicator()),
                          SizedBox(
                            width: 10,
                          ),
                          downloadProgress == null
                              ? Text("0/$downloadingTotalPage")
                              : Text("$downloadProgress/$downloadingTotalPage")
                        ],
                      ),
                    ),
                  );
                } else if (state is DownloadFail) {
                  return Card(
                    child: ListTile(
                      title:
                          Text('Download Fail | ${state.downloadingChapter}'),
                      subtitle: Text(state.error),
                    ),
                  );
                } else if (state is DownloadSuccess) {
                  return Card(
                    child: ListTile(
                      title: Text('Downloaded ${state.downloadingChapter}'),
                      subtitle: Text('You can read now.'),
                    ),
                  );
                }
                return Container();
              },
              listener: (context, state) {
                if (state is DownloadLoading) {
                  setState(() {
                    downloadStart = true;
                    finish = false;
                  });
                } else if (state is DownloadSuccess) {
                  BlocProvider.of<GetDownloadMangaCubit>(context, listen: false)
                      .getMangaList();
                  setState(() {
                    page = 0;
                    downloadStart = false;
                    finish = true;
                  });
                  fetchData();
                } else if (state is DownloadProgress) {
                  setState(() {
                    setState(() {
                      downloadProgress = state.progress;
                    });
                  });
                } else {
                  setState(() {
                    downloadStart = false;
                    finish = false;
                  });
                }
              },
            ),
          ],
        ),
        floatingActionButton: allChaptersDownload
            ? FloatingActionButton(
                onPressed: () async {
                  setState(() {
                    allChaptersDownload = !allChaptersDownload;
                  });
                  await BlocProvider.of<DownloadCubit>(context)
                      .downloadAllChapter(chooseChapter, widget.mangaId,
                          widget.manga_cover, widget.manga_name);
                },
                child: FaIcon(FontAwesomeIcons.download),
              )
            : null,
      ),
    );
  }
}
