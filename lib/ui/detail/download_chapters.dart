import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mangaturn/config/constants.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/custom_widgets/customText.dart';
import 'package:mangaturn/custom_widgets/reward_alertBox.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/services/bloc/ads/free_point_cubit.dart';
import 'package:mangaturn/services/bloc/ads/popup_cubit.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';

class DownloadChapters extends StatefulWidget {
  final int mangaId;
  final String mangaName;
  final String mangaCover;

  DownloadChapters(
      {required this.mangaId,
      required this.mangaName,
      required this.mangaCover});

  @override
  _DownloadChaptersState createState() => _DownloadChaptersState();
}

class _DownloadChaptersState extends State<DownloadChapters> {
  DBHelper dbHelper = DBHelper();
  List<DownloadChapter> downloadedChapters = [];
  late int mangaId;
  late String mangaName;
  late String mangaCover;
  late ApiRepository _apiRepository;
  String? token;
  String sortType = 'asc';
  static const _pageSize = 10;
  bool hideControls = false;
  int size = 15;
  PagingController<int, ChapterModel> _pagingController =
      PagingController(firstPageKey: 0);
  List<ChapterModel> chooseChapter = [];
  bool selectAll = false;
  bool downloadTaskFinished = true;
  bool downloadStart = false;

  bool checkContainData(List<ChapterModel> chapters, int data) {
    for (ChapterModel chapter in chapters) {
      if (chapter.id == data) return true;
    }
    return false;
  }

  void getToken() async {
    List<DownloadChapter> dChapters = await dbHelper.getChapterLists(mangaId);
    String data = AuthFunction.getToken()!;
    setState(() {
      token = data;
      downloadedChapters = dChapters;
    });
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

  static final AdRequest request = AdRequest(
    keywords: <String>['foo', 'bar'],
    contentUrl: 'http://foo.com/bar.html',
    nonPersonalizedAds: true,
  );

  BannerAd? _anchoredBanner;

  bool _loadingAnchoredBanner = false;

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    final BannerAd banner = BannerAd(
      size: size,
      request: AdRequest(),
      adUnitId: Constant.bannerId,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
          setState(() {
            _anchoredBanner = ad as BannerAd?;
          });
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
          ad.dispose();
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    return banner.load();
  }

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    mangaId = widget.mangaId;
    mangaName = widget.mangaName;
    mangaCover = widget.mangaCover;
    getToken();
    _apiRepository = new ApiRepository(getIt.call());
    _pagingController.addPageRequestListener((pageKey) {
      print(pageKey.toString() + " Page Key");
      _fetchChapter(pageKey);
    });
    super.initState();
  }

  List<ChapterModel> checkChapters(List<ChapterModel> chapters) {
    List<ChapterModel> checkChapterList = [];
    for (int i = 0; i < chapters.length; i++) {
      if (downloadedChapters
              .where((e) => e.chapterId == chapters[i].id)
              .length ==
          1) {
        setState(() {
          checkChapterList.add(ChapterModel(
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
      } else if (chapters[i].isPurchase == null ||
          chapters[i].type == 'PAID' && chapters[i].isPurchase == true) {
        checkChapterList.add(chapters[i]);
      }
    }
    return checkChapterList;
  }

  Future<void> _fetchChapter(int pageKey) async {
    print('fetching');
    try {
      final newItems = await _apiRepository.getAllChapters(
          mangaId, 'chapterNo', sortType, pageKey, size, token!);
      final isLastPage = newItems.length < _pageSize;
      List<ChapterModel> resultChapterList = checkChapters(newItems);
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
    setState(() {});
  }

  @override
  void dispose() {
    _anchoredBanner?.dispose();
    _pagingController.dispose();
    super.dispose();
  }

  void removeData(int id) {
    print('removing');
    for (int i = 0; i < chooseChapter.length; i++) {
      if (chooseChapter[i].id == id) {
        setState(() {
          chooseChapter.removeAt(i);
        });
        break;
      }
    }
  }

  bool selectAllDone = true;
  List<int>? checkDownloadedChapters;
  int? downloadProgress;
  int? downloadingTotalPage;

  void selectAllChapters() {
    print("Select All $selectAll");
    if (selectAll && selectAllDone) {
      if (_pagingController.itemList != null) {
        setState(() {
          chooseChapter = [..._pagingController.itemList!];
          selectAllDone = !selectAllDone;
        });
      }
    }
  }

  Future<bool> check() async {
    if (!downloadStart && downloadTaskFinished) {
      return true;
    } else {
      _showToast('You can\'t quit while downloading..');
      return false;
    }
  }

  Future<void> alertToWatchAds() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('အသိပေးချက်'),
          content: Text(
              'ဒေါင်းလုဒ်ဆွဲရန်အတွက် ကြော်ငြာကိုပြီးအောင်ကြည့်ရပါမယ်ဗျ။ ပြီးအောင်ကြည့်ပြီးရင် အလိုအလျောက်ဒေါင်းလုဒ်စဆွဲပါလိမ့်မယ်ဗျ။'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ပြန်ထွက်မယ်')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  BlocProvider.of<PopupCubit>(context).createInterstitialAd();
                  downloadAlertBox(context);
                },
                child: Text('ဒေါင်းလုဒ်ဆွဲမယ်'))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    selectAllChapters();
    downloadingTotalPage = BlocProvider.of<DownloadCubit>(context).getTotalPage;
    checkDownloadedChapters =
        BlocProvider.of<DownloadCubit>(context).getDownloadedChapters;

    return WillPopScope(
      onWillPop: check,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.cancel),
            onPressed: () {
              if (!downloadStart && downloadTaskFinished) {
                Navigator.of(context).pop();
              } else {
                _showToast('ဒေါင်းလုဒ်ဆွဲနေတုန်း ထွက်လို့မရသေးပါ');
              }
            },
          ),
          title: chooseChapter.isEmpty
              ? Text('Choose Chapters')
              : downloadStart && !downloadTaskFinished
                  ? Text("${chooseChapter.length} Downloading")
                  : downloadTaskFinished
                      ? Text('${chooseChapter.length} downloaded')
                      : Text("${chooseChapter.length} selected"),
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
                      _pagingController.refresh();
                    }
                  } else {
                    if (mounted) {
                      setState(() {
                        sortType = 'desc';
                      });
                      _pagingController.refresh();
                    }
                  }
                }),
          ],
        ),
        body: Builder(
          builder: (context) {
            if (!_loadingAnchoredBanner) {
              _loadingAnchoredBanner = true;
              _createAnchoredBanner(context);
            }
            return Column(
              children: [
                Expanded(
                  child: BlocConsumer<PopupCubit, PopupState>(
                      builder: (context, state) {
                    return token == null
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : BlocConsumer<DownloadCubit, DownloadState>(
                            builder: (context, state) {
                              if (state is DownloadLoading) {
                                return ListView.builder(
                                  itemCount: chooseChapter.length,
                                  itemBuilder: (context, index) {
                                    ChapterModel downloadChapter =
                                        chooseChapter[index];
                                    return ListTile(
                                      title: Text(downloadChapter.chapterName),
                                      subtitle: LinearProgressIndicator(),
                                    );
                                  },
                                );
                              } else if (state is DownloadProgress) {
                                return ListView.builder(
                                  itemCount: chooseChapter.length,
                                  itemBuilder: (context, index) {
                                    ChapterModel downloadChapter =
                                        chooseChapter[index];
                                    if (!checkDownloadedChapters!
                                        .contains(downloadChapter.id)) {
                                      if (downloadChapter.chapterName ==
                                          state.downloadingChapter) {
                                        return ListTile(
                                          title:
                                              Text(downloadChapter.chapterName),
                                          subtitle: Row(
                                            children: [
                                              Expanded(
                                                  child:
                                                      LinearProgressIndicator()),
                                              SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                  "${state.progress}/$downloadingTotalPage")
                                            ],
                                          ),
                                        );
                                      }
                                      return ListTile(
                                        title:
                                            Text(downloadChapter.chapterName),
                                        subtitle: LinearProgressIndicator(),
                                      );
                                    } else {
                                      return ListTile(
                                          title:
                                              Text(downloadChapter.chapterName),
                                          subtitle: Text('Downloaded'));
                                    }
                                  },
                                );
                              } else if (state is DownloadSuccess) {
                                return Center(
                                    child: Text('Successfully downloaded'));
                              } else if (state is DownloadFail) {
                                return Center(
                                  child: Text(state.error),
                                );
                              } else {
                                return Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20.0, 10.0, 20.0, 10.0),
                                      child: CustomTextBox(
                                          text:
                                              'Tap to select and deselect chapters\nOnly free chapters & purchased chapters \ncan be downloaded.',
                                          color1: Colors.black,
                                          color2: Colors.white,
                                          align: TextAlign.center,
                                          fontSize: 15),
                                    ),
                                    Expanded(
                                      child: PagedListView<int, ChapterModel>(
                                        pagingController: _pagingController,
                                        builderDelegate:
                                            PagedChildBuilderDelegate<
                                                    ChapterModel>(
                                                itemBuilder:
                                                    (context, item, index) {
                                          if (item.pages!.length != 0) {
                                            return Container();
                                          } else if (item.type == "PAID") {
                                            if (item.isPurchase == true) {
                                              return ListTile(
                                                trailing: Checkbox(
                                                  value: checkContainData(
                                                      chooseChapter, item.id),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      checkContainData(
                                                              chooseChapter,
                                                              item.id)
                                                          ? removeData(item.id)
                                                          : chooseChapter
                                                              .add(item);
                                                    });
                                                  },
                                                  //checkColor: Colors.black,
                                                ),
                                                onTap: () async {
                                                  print(_pagingController
                                                      .itemList!.length);
                                                  setState(() {
                                                    checkContainData(
                                                            chooseChapter,
                                                            item.id)
                                                        ? removeData(item.id)
                                                        : chooseChapter
                                                            .add(item);
                                                  });
                                                },
                                                leading: item.type == "PAID"
                                                    ? item.isPurchase == true
                                                        ? Icon(Icons.bookmarks)
                                                        : Icon(Icons.bookmarks)
                                                    : Icon(Icons.bookmarks),
                                                title: Text(item.chapterName),
                                                subtitle: item.pages!.length !=
                                                        0
                                                    ? Text("Downloaded")
                                                    : item.type == "FREE"
                                                        ? Text(
                                                            "FREE  |  ${item.totalPages} Pages")
                                                        : item.isPurchase ==
                                                                true
                                                            ? Text(
                                                                'Purchased | Download Available')
                                                            : Text(
                                                                item.type +
                                                                    "  -  ${item.point} Points   |  ${item.totalPages} Pages",
                                                                style:
                                                                    TextStyle(
                                                                  color: Colors
                                                                      .indigo,
                                                                ),
                                                              ),
                                              );
                                            } else {
                                              return Container();
                                            }
                                          } else {
                                            return ListTile(
                                              onTap: () async {
                                                setState(() {
                                                  checkContainData(
                                                          chooseChapter,
                                                          item.id)
                                                      ? removeData(item.id)
                                                      : chooseChapter.add(item);
                                                });
                                              },
                                              trailing: Checkbox(
                                                value: checkContainData(
                                                    chooseChapter, item.id),
                                                onChanged: (value) {
                                                  setState(() {
                                                    checkContainData(
                                                            chooseChapter,
                                                            item.id)
                                                        ? removeData(item.id)
                                                        : chooseChapter
                                                            .add(item);
                                                  });
                                                },
                                                //checkColor: Colors.black,
                                              ),
                                              leading: Icon(Icons.bookmarks),
                                              title: Text(item.chapterName),
                                              subtitle: item.pages!.length != 0
                                                  ? Text("Downloaded")
                                                  : item.type == "FREE"
                                                      ? Text(
                                                          "FREE  |  ${item.totalPages} Pages")
                                                      : item.isPurchase == true
                                                          ? Text(
                                                              'Purchased | Download Available')
                                                          : Text(
                                                              item.type +
                                                                  "  -  ${item.point} Points   |  ${item.totalPages} Pages",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .indigo,
                                                              ),
                                                            ),
                                            );
                                          }
                                        }),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          20.0, 0.0, 20.0, 0.0),
                                      //padding: const EdgeInsets.fromLTRB(20.0, 10.0, 0.0, 10.0),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                if (selectAll) {
                                                  setState(() {
                                                    selectAllDone =
                                                        !selectAllDone;
                                                    selectAll = false;
                                                    size = 15;
                                                    chooseChapter.clear();
                                                  });
                                                  _pagingController.refresh();
                                                } else {
                                                  setState(() {
                                                    selectAll = true;
                                                    chooseChapter.clear();
                                                    size = 10000;
                                                  });
                                                  _pagingController.refresh();
                                                }
                                              },
                                              child: Text(
                                                selectAll
                                                    ? 'Deselect All'
                                                    : 'Select All',
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          if (chooseChapter.isEmpty)
                                            Container()
                                          else
                                            Expanded(
                                              child: OutlinedButton(
                                                child: Text('Download'),
                                                onPressed: () {
                                                  alertToWatchAds();
                                                },
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                            },
                            listener: (context, state) {
                              if (state is DownloadFail) {
                                setState(() {
                                  downloadTaskFinished = true;
                                  downloadStart = false;
                                });
                              } else if (state is DownloadSuccess) {
                                setState(() {
                                  downloadTaskFinished = true;
                                  downloadStart = false;
                                });
                              } else if (state is DownloadLoading) {
                                setState(() {
                                  downloadStart = true;
                                });
                              }
                            },
                          );
                  }, listener: (context, state) {
                    if (state is PopUpSuccess) {
                      Navigator.of(context).pop();
                      BlocProvider.of<DownloadCubit>(context)
                          .downloadAllChapter(
                              chooseChapter, mangaId, mangaCover, mangaName);
                    }
                  }),
                ),
                if (_anchoredBanner != null)
                  Container(
                    color: Colors.transparent,
                    width: _anchoredBanner!.size.width.toDouble(),
                    height: _anchoredBanner!.size.height.toDouble(),
                    child: AdWidget(ad: _anchoredBanner!),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
