import 'package:clipboard/clipboard.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/confirm_sending_notification.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/ui/detail/reader.dart';
import 'package:mangaturn/ui/workspace/edit_chapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangaturn/ui/workspace/send_notification.dart';
import 'package:share/share.dart';

class ChapterListAdminView extends StatefulWidget {
  final int mangaId;
  final String manga_name;
  final String manga_cover;

  ChapterListAdminView(this.mangaId, this.manga_name, this.manga_cover);

  @override
  _ChapterListAdminViewState createState() => _ChapterListAdminViewState();
}

class _ChapterListAdminViewState extends State<ChapterListAdminView> {
  late List<ChapterModel> _chapterList;
  late ScrollController _controller;
  String sortType = 'desc';
  int page = 0;
  bool _infiniteStop = false;
  List<ChapterModel> chooseChapter = [];
  List<ChapterModel> _selectAllChapters = [];
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

  Future<void> fetchData() async {
    BlocProvider.of<GetAllChapterCubit>(context, listen: false).clear();
    await BlocProvider.of<GetAllChapterCubit>(context, listen: false)
        .fetchChapters(widget.mangaId, "chapterNo", sortType, page, size);
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
    fetchData();
    BlocProvider.of<DownloadCubit>(context, listen: false).clear();
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void update() async {
    _chapterList = BlocProvider.of<GetAllChapterCubit>(context).getChapters();
    //  BlocProvider.of<GetLatestChaptersCubit>(context, listen: false).clear();
    //BlocProvider.of<GetLatestChaptersCubit>(context, listen: false).getLatestChapters(token);
  }

  Future<void> refresh() async {
    if (mounted) {
      setState(() {
        sortType = 'desc';
        page = 0;
      });
      await fetchData();
      BlocProvider.of<GetLatestChaptersCubit>(context, listen: false)
          .getLatestChapters();
    }
  }

  bool checkContainData(List<ChapterModel> chapters, int data) {
    for (ChapterModel chapter in chapters) {
      if (chapter.id == data) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    update();

    return Scaffold(
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
              title: Text('Available Chapters'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      refresh();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.drive_folder_upload),
                    onPressed: () async {
                      final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditChapter(
                                    newChapter: true,
                                    mangaId: widget.mangaId,
                                    chapterModel: null,
                                  )));
                      if (result[0] == 'success') {
                        print('okay');
                        refresh();
                        bool? notiConfirm = await confirmSendNoti(context);
                        if (notiConfirm != null && notiConfirm) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SendNotification(
                                mangaId: widget.mangaId,
                                mangaName: widget.manga_name,
                                mangaCover: widget.manga_cover,
                                mangaDescription: 'No Description',
                                chaperModel: result[1],
                                updateType: UpdateType.chapterInsert.toString(),
                              ),
                              fullscreenDialog: true,
                            ),
                          );
                        }
                      }
                    },
                  ),
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
                          }
                        } else {
                          if (mounted) {
                            setState(() {
                              sortType = 'desc';
                              page = 0;
                            });
                            fetchData();
                          }
                        }
                      }),
                ],
              ),
            ),
          ),
        ),
        preferredSize: Size.fromHeight(80),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: BlocConsumer<GetAllChapterCubit, GetAllChapterState>(
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
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GetAllChapterFail) {
              return Center(
                child: Text(state.error),
              );
            }
            return Column(
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
                      } else {
                        return Card(
                          child: ListTile(
                            onTap: () async {
                              Navigator.pushNamed(context, Reader.routeName,
                                  arguments: [
                                    _chapterList[index],
                                    _chapterList,
                                    index,
                                    sortType,
                                    widget.mangaId,
                                    widget.manga_cover,
                                  ]);
                            },
                            leading: Text(
                              "No. ${_chapterList[index].chapterNo}",
                            ),
                            title: Text(_chapterList[index].chapterName),
                            subtitle: _chapterList[index].pages!.length != 0
                                ? Text("Downloaded")
                                : _chapterList[index].type == "FREE"
                                    ? Text(
                                        "FREE  |  ${_chapterList[index].totalPages} Pages")
                                    : _chapterList[index].isPurchase == true
                                        ? Text('Purchased | Download Available')
                                        : Text(
                                            _chapterList[index].type +
                                                "  -  ${_chapterList[index].point} Points   |  ${_chapterList[index].totalPages} Pages",
                                            style: TextStyle(
                                              color: Colors.indigo,
                                            ),
                                          ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    Loading(context);
                                    ChapterModel createChapterModel =
                                        ChapterModel(
                                      id: _chapterList[index].id,
                                      chapterName:
                                          _chapterList[index].chapterName,
                                      type: _chapterList[index].type,
                                      chapterNo: _chapterList[index].chapterNo,
                                      point: _chapterList[index].point,
                                      totalPages:
                                          _chapterList[index].totalPages,
                                      isPurchase:
                                          _chapterList[index].isPurchase,
                                    );
                                    String link =
                                        await Utility.createChapterLink(
                                      chapterModel: createChapterModel,
                                      cover: widget.manga_cover,
                                    );

                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Share it or copy it.'),
                                        content: Text(link),
                                        actions: [
                                          IconButton(
                                              icon: Icon(Icons.copy),
                                              onPressed: () async {
                                                await FlutterClipboard.copy(
                                                    link);
                                                _showToast("Copied the link");
                                              }),
                                          IconButton(
                                              icon: Icon(Icons.share),
                                              onPressed: () {
                                                Share.share(link);
                                              }),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.share_outlined),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditChapter(
                                          mangaId: widget.mangaId,
                                          newChapter: false,
                                          chapterModel: _chapterList[index],
                                        ),
                                      ),
                                    );
                                    if (result == 'success') {
                                      if (mounted) {
                                        setState(() {
                                          sortType = 'desc';
                                          page = 0;
                                        });
                                        fetchData();
                                      }
                                    }
                                  },
                                ),
                              ],
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
                  height: _infiniteStop ? 20 : 0,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
