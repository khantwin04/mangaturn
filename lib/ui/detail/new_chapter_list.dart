import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/custom_widgets/purchase_chapter_confirm.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/models/your_choice_models/resume_model.dart';
import 'package:mangaturn/services/bloc/choice/resume_cubit.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:mangaturn/services/bloc/post/purchase_chapter_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/download_chapters.dart';
import 'package:mangaturn/ui/detail/offline_reader.dart';
import 'package:mangaturn/ui/detail/reader.dart';
import 'package:share/share.dart';
import 'package:mangaturn/config/local_storage.dart';

class NewChapterList extends StatefulWidget {
  final int mangaId;
  final String mangaName;
  final String mangaCover;

  NewChapterList(
      {required this.mangaId,
      required this.mangaName,
      required this.mangaCover});

  @override
  _NewChapterListState createState() => _NewChapterListState();
}

class _NewChapterListState extends State<NewChapterList> {
  late int mangaId;
  late String mangaName;
  late String mangaCover;
  late ApiRepository _apiRepository;
  DBHelper dbHelper = DBHelper();
  String? token;
  String sortType = 'asc';
  static const _pageSize = 10;
  bool hideControls = false;
  int size = 15;
  List<DownloadChapter> downloadedChapters = [];
  List<ChapterModel> allChapters = [];
  PagingController<int, ChapterModel> _pagingController =
      PagingController(firstPageKey: 0);

  void getToken() async {
    List<DownloadChapter> dChapters = await dbHelper.getChapterLists(mangaId);
    String data = AuthFunction.getToken()!;
    setState(() {
      token = data;
      downloadedChapters = dChapters;
    });
    _fetchAllChapters();
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

  Future<List<ChapterModel>> checkChapters(List<ChapterModel> chapters) async {
    List<ChapterModel> checkChapterList = [];
    for (int i = 0; i < chapters.length; i++) {
      if (downloadedChapters
              .where((e) => e.chapterId == chapters[i].id)
              .length ==
          1) {
        if (await LocalStorage.getReadChapterId(chapters[i].id) != null) {
          setState(() {
            checkChapterList.add(ChapterModel(
              read: true,
              id: chapters[i].id,
              isPurchase: chapters[i].isPurchase,
              chapterName: chapters[i].chapterName,
              pages: [DownloadPage()],
              type: chapters[i].type,
              totalPages: chapters[i].totalPages,
              point: chapters[i].point,
              chapterNo: chapters[i].chapterNo,
            ));
          });
        } else {
          setState(() {
            checkChapterList.add(ChapterModel(
              id: chapters[i].id,
              isPurchase: chapters[i].isPurchase,
              chapterName: chapters[i].chapterName,
              pages: [
                DownloadPage(),
              ],
              type: chapters[i].type,
              totalPages: chapters[i].totalPages,
              point: chapters[i].point,
              chapterNo: chapters[i].chapterNo,
            ));
          });
        }
      } else {
        if (await LocalStorage.getReadChapterId(chapters[i].id) != null) {
          setState(() {
            checkChapterList.add(ChapterModel(
              read: true,
              id: chapters[i].id,
              isPurchase: chapters[i].isPurchase,
              chapterName: chapters[i].chapterName,
              type: chapters[i].type,
              pages: [],
              totalPages: chapters[i].totalPages,
              point: chapters[i].point,
              chapterNo: chapters[i].chapterNo,
            ));
          });
        } else {
          checkChapterList.add(chapters[i]);
        }
      }
    }
    return checkChapterList;
  }

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    mangaId = widget.mangaId;
    mangaName = widget.mangaName;
    mangaCover = widget.mangaCover;
    _apiRepository = new ApiRepository(getIt.call());
    getToken();
    _pagingController.addPageRequestListener((pageKey) {
      print(pageKey.toString() + " Page Key");
      _fetchChapter(pageKey);
    });
    super.initState();
  }

  void _fetchAllChapters() async {
    setState(() {
      allChapters.clear();
    });
    try {
      List<ChapterModel> data = await _apiRepository.getAllChapters(
          mangaId, 'chapterNo', sortType, 0, 10000, token!);
      setState(() {
        allChapters = data;
      });
      print(allChapters.length);
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _fetchChapter(int pageKey) async {
    print('fetching');
    try {
      final newItems = await _apiRepository.getAllChapters(
          mangaId, 'chapterNo', sortType, pageKey, size, token!);
      final isLastPage = newItems.length < _pageSize;
      List<ChapterModel> resultChapterList = await checkChapters(newItems);
      if (isLastPage) {
        _pagingController.appendLastPage(resultChapterList);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(resultChapterList, nextPageKey);
      }
    } catch (error) {
      print(error);
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          mangaName,
        ),
        actions: [
          IconButton(
              icon: sortType == "asc"
                  ? FaIcon(FontAwesomeIcons.sortNumericUp)
                  : FaIcon(FontAwesomeIcons.sortNumericDown),
              onPressed: () {
                if (sortType == "desc") {
                  if (mounted) {
                    setState(() {
                      sortType = 'asc';
                    });
                    _fetchAllChapters();
                    _pagingController.refresh();
                  }
                } else {
                  if (mounted) {
                    setState(() {
                      sortType = 'desc';
                    });
                    _fetchAllChapters();
                    _pagingController.refresh();
                  }
                }
              }),
          IconButton(
            icon: Icon(
              Icons.download_sharp,
              size: 30,
            ),
            onPressed: () {
              BlocProvider.of<DownloadCubit>(context).emit(DownloadInitial());
              Navigator.of(context).push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => DownloadChapters(
                    mangaId: mangaId,
                    mangaName: mangaName,
                    mangaCover: mangaCover),
              ));
            },
          ),
        ],
      ),
      body: token == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: () async {
                _pagingController.refresh();
                _fetchAllChapters();
              },
              child: Column(
                children: [
                  Expanded(
                    child: PagedListView<int, ChapterModel>(
                      physics: BouncingScrollPhysics(),
                      pagingController: _pagingController,
                      builderDelegate: PagedChildBuilderDelegate<ChapterModel>(
                          itemBuilder: (context, item, index) {
                        return Container(
                          color: item.read != null && item.read!
                              ? Colors.grey[200]
                              : Colors.white,
                          child: ListTile(
                            trailing: IconButton(
                              onPressed: () async {
                                Loading(context);
                                ChapterModel createChapterModel = ChapterModel(
                                  id: item.id,
                                  chapterName: item.chapterName,
                                  type: item.type,
                                  chapterNo: item.chapterNo,
                                  point: item.point,
                                  totalPages: item.totalPages,
                                  isPurchase: item.isPurchase,
                                );
                                String link = await Utility.createChapterLink(
                                  chapterModel: createChapterModel,
                                  cover: mangaCover,
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
                                            await FlutterClipboard.copy(link);
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
                            onTap: () async {
                              if (item.pages!.length != 0) {
                                await LocalStorage.saveReadChapterId(item.id);
                                ResumeModel resume = ResumeModel(
                                    mangaId: mangaId,
                                    currentChapterIndex: index,
                                    title: widget.mangaName,
                                    chapterName: item.chapterName,
                                    chapterId: item.id,
                                    newChapterAvailable: false,
                                    newChapterId: 0,
                                    newChapterName: '',
                                    key: widget.mangaId,
                                    cover: widget.mangaCover,
                                    timeStamp: DateTime.now());

                                BlocProvider.of<ResumeCubit>(context)
                                    .saveResume(resume);

                                DownloadChapter chapter = DownloadChapter(
                                  chapterId: item.id,
                                  chapterName: item.chapterName,
                                  mangaId: widget.mangaId,
                                  totalPage: item.totalPages,
                                );

                                Navigator.pushNamed(
                                    context, OfflineReader.routeName,
                                    arguments: [
                                      item.id,
                                      item.chapterName,
                                      mangaName,
                                      widget.mangaId,
                                      [chapter],
                                      0,
                                    ]);
                              } else {
                                if (item.type == "PAID") {
                                  if (item.isPurchase == true) {
                                    await LocalStorage.saveReadChapterId(
                                        item.id);
                                    ResumeModel resume = ResumeModel(
                                        mangaId: mangaId,
                                        currentChapterIndex: index,
                                        title: widget.mangaName,
                                        chapterName: item.chapterName,
                                        chapterId: item.id,
                                        newChapterAvailable: false,
                                        newChapterId: 0,
                                        newChapterName: '',
                                        key: widget.mangaId,
                                        cover: widget.mangaCover,
                                        timeStamp: DateTime.now());

                                    BlocProvider.of<ResumeCubit>(context)
                                        .saveResume(resume);
                                    Navigator.pushNamed(
                                        context, Reader.routeName,
                                        arguments: [
                                          item,
                                          allChapters,
                                          index,
                                          sortType,
                                          widget.mangaId,
                                          widget.mangaCover,
                                        ]);
                                  } else {
                                    var result = await confirmPurchase(context);
                                    if (result == true) {
                                      BlocProvider.of<PurchaseChapterCubit>(
                                              context)
                                          .purchaseChapter(item.id, context);
                                      bool success = await PurchaseChapter(
                                          context, item.chapterName);
                                      if (success) {
                                        _pagingController.refresh();
                                        _fetchAllChapters();
                                      }
                                    }
                                  }
                                } else {
                                  await LocalStorage.saveReadChapterId(item.id);
                                  ResumeModel resume = ResumeModel(
                                      mangaId: mangaId,
                                      currentChapterIndex: index,
                                      title: widget.mangaName,
                                      chapterName: item.chapterName,
                                      chapterId: item.id,
                                      newChapterAvailable: false,
                                      newChapterId: 0,
                                      newChapterName: '',
                                      key: widget.mangaId,
                                      cover: widget.mangaCover,
                                      timeStamp: DateTime.now());

                                  BlocProvider.of<ResumeCubit>(context)
                                      .saveResume(resume);
                                  Navigator.pushNamed(context, Reader.routeName,
                                      arguments: [
                                        item,
                                        allChapters,
                                        index,
                                        sortType,
                                        widget.mangaId,
                                        widget.mangaCover,
                                      ]);
                                }
                              }
                            },
                            leading: item.type == "PAID"
                                ? item.isPurchase == true
                                    ? Icon(Icons.bookmarks)
                                    : Icon(
                                        Icons.account_balance_wallet_outlined)
                                : Icon(Icons.bookmarks),
                            title: Text(item.chapterName),
                            subtitle: item.pages!.length != 0
                                ? Text("Downloaded")
                                : item.type == "FREE"
                                    ? Text("FREE  |  ${item.totalPages} Pages")
                                    : item.isPurchase == true
                                        ? Text('Purchased | Download Available')
                                        : Text(
                                            item.type +
                                                "  -  ${item.point} Points   |  ${item.totalPages} Pages",
                                            style: TextStyle(
                                              color: Colors.indigo,
                                            ),
                                          ),
                          ),
                        );
                      }),
                    ),
                  ),
                  BlocBuilder<ResumeCubit, ResumeState>(
                    builder: (context, state) {
                      if (state is ResumeLoading) {
                        return Expanded(
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            child: Center(
                              child: Text(
                                'Loading',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        );
                      } else if (state is ResumeSuccess) {
                        if (state.resumeList
                            .containsKey(widget.mangaId.toString())) {
                          ResumeModel getResume =
                              state.resumeList[widget.mangaId.toString()]!;
                          return Container(
                            height: 40,
                            margin: EdgeInsets.symmetric(horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(15.0),
                              border: Border.all(),
                            ),
                            child: Center(
                              child: Text(
                                "Last Read : " + getResume.chapterName,
                                softWrap: true,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
