import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/custom_text_field.dart';
import 'package:mangaturn/custom_widgets/error_alert.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/chapter_models/insert_chapter_model.dart';
import 'package:mangaturn/models/chapter_models/page_model.dart';
import 'package:mangaturn/models/chapter_models/update_chapter_model.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/bloc/post/edit_chapter_cubit.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum Type { FREE, PAID }
enum Sort { Auto, String, Number, Custom }

class EditChapter extends StatefulWidget {
  final int mangaId;
  final bool newChapter;
  final ChapterModel? chapterModel;

  EditChapter(
      {required this.mangaId,
      required this.newChapter,
      required this.chapterModel});

  @override
  _EditChapterState createState() => _EditChapterState();
}

class _EditChapterState extends State<EditChapter> {
  late bool newChapter;
  late String chapterNo;
  late String chapterName;
  late String point;
  late Type type;
  Sort sort = Sort.Auto;
  late List<InsertPageModel> insertPages;
  List<PageModel> updatePages = [];
  late ApiRepository _apiRepository;
  late String token;
  int page = 0;

  int tabIndex = 0;
  int totalPages = 0;
  int _currentSortColumn = 0;
  bool _isAscending = false;
  late ScrollController scrollController;
  bool getMorePageLoading = false;
  late bool updateImages;

  void getToken() async {
    String? data = await AuthFunction.getToken();
    setState(() {
      token = data!;
    });
    if (widget.newChapter == false) {
      updatePages = await _apiRepository.getAllPages(
          widget.chapterModel!.id, 20, page++, data!);
      setState(() {});
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
    initialValue();
    _apiRepository = ApiRepository(getIt.call());
    getToken();
    scrollController =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    scrollController.addListener(_scrollListener);
    newChapter = widget.newChapter;
    super.initState();
  }

  initialValue() async {
    if (widget.chapterModel == null || widget.newChapter == true) {
      setState(() {
        chapterNo = '';
        chapterName = '';
        point = '';
        type = Type.FREE;
        insertPages = [];
        updatePages = [];
        updateImages = true;
      });
    } else {
      setState(() {
        chapterNo = widget.chapterModel!.chapterNo.toString();
        chapterName = widget.chapterModel!.chapterName;
        point = widget.chapterModel!.point.toString();
        type = widget.chapterModel!.type == Type.FREE.toString().split('.').last
            ? Type.FREE
            : Type.PAID;
        insertPages = [];
        updateImages = false;
        totalPages = widget.chapterModel!.totalPages;
      });
    }
  }

  bool get isEnd {
    if (!scrollController.hasClients) return false;
    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  _scrollListener() async {
    if (isEnd) {
      setState(() {
        getMorePageLoading = true;
      });
      _apiRepository
          .getAllPages(widget.chapterModel!.id, 20, page++, token)
          .then((value) {
        setState(() {
          updatePages.addAll(value);
          getMorePageLoading = false;
        });
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }

  void hasImage() {
    if (imageError) {
      AlertError(
          context: context,
          title: 'Image Error',
          content: 'You have to pick images.');
    } else if (chapterNo == '') {
      AlertError(
          context: context, title: 'Error', content: 'Required Chapter No.');
    } else {
      if (newChapter) {
        uploadNewChapter();
      } else {
        updateOldChapter();
      }
    }
  }

  void uploadNewChapter() async {
    if (_paths == null) {
      AlertError(
          context: context,
          title: 'Upload Error',
          content: 'Your have to pick images.');
    } else {
      Loading(context);
      await assetToBase64Images();
      Navigator.of(context).pop();
      try {
        InsertChapterModel newChapter = InsertChapterModel(
          mangaId: widget.mangaId,
          chapterNo: int.parse(chapterNo),
          chapterName: chapterName,
          type: type == Type.FREE ? "FREE" : "PAID",
          point: point == '' ? 0 : int.parse(point),
          pages: insertPages,
        );
        BlocProvider.of<EditChapterCubit>(context)
            .uploadNewChapter(newChapter, insertPages.length);
      } catch (e) {
        AlertError(
            context: context,
            title: 'Upload Error',
            content: 'Chapter no have to be integer');
        setState(() {
          insertPages.clear();
        });
      }
    }
  }

  void updateOldChapter() async {
    if (updateImages == true) {
      if (_paths == null) {
        AlertError(
            context: context,
            title: 'Upload Error',
            content: 'Your have to pick images.');
      } else {
        Loading(context);
        await assetToBase64Images();
        Navigator.of(context).pop();
        UpdateChapterModel updateChapter = UpdateChapterModel(
          type: type == Type.FREE ? "FREE" : "PAID",
          point: point == '' ? 0 : int.parse(point),
          id: widget.chapterModel!.id,
          chapterName: chapterName,
          chapterNo: int.parse(chapterNo),
          mangaId: widget.mangaId,
          pages: insertPages,
        );
        BlocProvider.of<EditChapterCubit>(context)
            .updateOldChapter(updateChapter);
      }
    } else {
      List<InsertPageModel> pages = [];
      for (int i = 0; i < updatePages.length; i++) {
        setState(() {
          pages.add(InsertPageModel(
              id: updatePages[i].id, pageNo: updatePages[i].pageNo));
        });
      }

      UpdateChapterModel updateChapter = UpdateChapterModel(
        type: type == Type.FREE ? "FREE" : "PAID",
        point: point == '' ? 0 : int.parse(point),
        id: widget.chapterModel!.id,
        chapterName: chapterName,
        chapterNo: int.parse(chapterNo),
        mangaId: widget.mangaId,
        pages: pages,
      );
      BlocProvider.of<EditChapterCubit>(context)
          .updateOldChapter(updateChapter);
    }
  }

  bool loading = false;

  Future<bool> back() async {
    if (!loading) {
      Navigator.of(context).pop();
      return true;
    } else {
      _showToast('You can\'t quit while uploading..');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: back,
      child: DefaultTabController(
        initialIndex: tabIndex,
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                back();
              },
            ),
            title: newChapter ? Text('Add new chapter') : Text('Edit chapter'),
            bottom: TabBar(
              onTap: (index) {
                setState(() {
                  tabIndex = index;
                });
              },
              tabs: [
                Tab(
                  child: Text('Chapter Info'),
                ),
                Tab(child: Text('Chapter Images')),
              ],
            ),
          ),
          body: BlocConsumer<EditChapterCubit, EditChapterState>(
            listener: (context, state) {
              if (state is EditChapterSuccess) {
                if (newChapter) {
                  Navigator.of(context).pop(['success', state.chapterModel]);
                } else {
                  Navigator.of(context)
                      .pop('success');
                }
              } else if (state is EditChapterLoading) {
                setState(() {
                  loading = true;
                });
              } else if (state is EditChapterFail) {
                setState(() {
                  loading = false;
                  insertPages.clear();
                });
              }
            },
            builder: (context, state) {
              if (state is EditChapterLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is EditChapterFail) {
                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            state.error,
                            textAlign: TextAlign.center,
                          ),
                        ),
                        ElevatedButton(
                          child: Text('Try Again'),
                          onPressed: () {
                            BlocProvider.of<EditChapterCubit>(context)
                                .emit(EditChapterInitial());
                          },
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return TabBarView(
                  children: [
                    Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            padding: EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                !newChapter
                                    ? Column(
                                        children: [
                                          BlocBuilder<GetUserProfileCubit,
                                              GetUserProfileState>(
                                            builder: (context, state) {
                                              if (state
                                                  is GetUserProfileSuccess) {
                                                if (state.user.type ==
                                                        "SOLE_PROPRIETOR" ||
                                                    state.user.type ==
                                                        "ORGANIZER" ||
                                                    state.user.type == "USER") {
                                                  return Column(
                                                    children: [
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Container(
                                                              child: Text(
                                                                'Chapter Type',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            DropdownButton(
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .indigo,
                                                                    fontSize:
                                                                        18),
                                                                underline:
                                                                    Container(),
                                                                value: type,
                                                                onChanged:
                                                                    (Type?
                                                                        data) {
                                                                  setState(() {
                                                                    type =
                                                                        data!;
                                                                  });
                                                                },
                                                                items: [
                                                                  DropdownMenuItem(
                                                                      child: Text(
                                                                          'FREE'),
                                                                      value: Type
                                                                          .FREE),
                                                                  DropdownMenuItem(
                                                                      child: Text(
                                                                          'PAID'),
                                                                      value: Type
                                                                          .PAID),
                                                                ]),
                                                            SizedBox(width: 10),
                                                            type == Type.FREE
                                                                ? Container()
                                                                : Expanded(
                                                                    child: CustomTextField(
                                                                        initialVal: point,
                                                                        context: context,
                                                                        label: 'Point',
                                                                        inputType: TextInputType.number,
                                                                        validatorText: 'Required',
                                                                        action: TextInputAction.done,
                                                                        onChange: (data) {
                                                                          print(
                                                                              data);
                                                                          setState(
                                                                              () {
                                                                            point =
                                                                                data;
                                                                          });
                                                                        }),
                                                                  ),
                                                          ]),
                                                      SizedBox(height: 20),
                                                    ],
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              } else if (state
                                                  is GetUserProfileFail) {
                                                return Text(state.error);
                                              } else {
                                                return Container(
                                                  width: double.infinity,
                                                  child: Text('Loading..'),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Container(
                                            width: double.infinity,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey[50]!,
                                                style: BorderStyle.solid,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                              boxShadow: [
                                                BoxShadow(
                                                    color: Colors.grey[100]!,
                                                    offset: Offset(0, 1))
                                              ],
                                            ),
                                            padding: EdgeInsets.all(5.0),
                                            child: Text(
                                              'Chapter no is only for chapter sorting purpose, you can\'t edit chapterNo after you had uploaded.',
                                              style: TextStyle(fontSize: 18),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          CustomTextField(
                                              initialVal: chapterNo,
                                              context: context,
                                              label: 'Chapter no',
                                              inputType: TextInputType.number,
                                              validatorText: 'Required',
                                              action: TextInputAction.done,
                                              onChange: (data) {
                                                print(data);
                                                setState(() {
                                                  chapterNo = data;
                                                });
                                              }),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          BlocBuilder<GetUserProfileCubit,
                                              GetUserProfileState>(
                                            builder: (context, state) {
                                              if (state
                                                  is GetUserProfileSuccess) {
                                                if (state.user.type ==
                                                        "SOLE_PROPRIETOR" ||
                                                    state.user.type ==
                                                        "ORGANIZER" ||
                                                    state.user.type == 'USER') {
                                                  return Column(
                                                    children: [
                                                      Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Container(
                                                              child: Text(
                                                                'Chapter Type',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ),
                                                            SizedBox(width: 10),
                                                            DropdownButton(
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .indigo,
                                                                    fontSize:
                                                                        18),
                                                                underline:
                                                                    Container(),
                                                                value: type,
                                                                onChanged:
                                                                    (Type?
                                                                        data) {
                                                                  setState(() {
                                                                    type =
                                                                        data!;
                                                                  });
                                                                },
                                                                items: [
                                                                  DropdownMenuItem(
                                                                      child: Text(
                                                                          'FREE'),
                                                                      value: Type
                                                                          .FREE),
                                                                  DropdownMenuItem(
                                                                      child: Text(
                                                                          'PAID'),
                                                                      value: Type
                                                                          .PAID),
                                                                ]),
                                                            SizedBox(width: 10),
                                                            type == Type.FREE
                                                                ? Container()
                                                                : Expanded(
                                                                    child: CustomTextField(
                                                                        initialVal: point,
                                                                        context: context,
                                                                        label: 'Point',
                                                                        inputType: TextInputType.number,
                                                                        validatorText: 'Required',
                                                                        action: TextInputAction.done,
                                                                        onChange: (data) {
                                                                          print(
                                                                              data);
                                                                          setState(
                                                                              () {
                                                                            point =
                                                                                data;
                                                                          });
                                                                        }),
                                                                  ),
                                                          ]),
                                                      SizedBox(height: 20),
                                                    ],
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              } else if (state
                                                  is GetUserProfileFail) {
                                                return Text(state.error);
                                              } else {
                                                return Container(
                                                  width: double.infinity,
                                                  child: Text('Loading..'),
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                CustomTextField(
                                    initialVal: chapterName,
                                    context: context,
                                    label: 'Chapter name',
                                    inputType: TextInputType.text,
                                    validatorText: 'Required',
                                    action: TextInputAction.done,
                                    onChange: (data) {
                                      setState(() {
                                        chapterName = data;
                                      });
                                    }),
                                SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[50]!,
                                      style: BorderStyle.solid,
                                    ),
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey[100]!,
                                          offset: Offset(0, 1))
                                    ],
                                  ),
                                  padding: EdgeInsets.all(5.0),
                                  child: Text(
                                    'Swipe to the right to pick images ->',
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            hasImage();
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.indigo[50]!,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.indigo[100]!,
                                    offset: Offset(0, 1))
                              ],
                            ),
                            padding: EdgeInsets.all(5.0),
                            child: newChapter
                                ? Text(
                                    'Upload new chapter',
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    'Update chapter',
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        newChapter == false && updateImages == false
                            ? updatePages.length == 0
                                ? Center(child: CircularProgressIndicator())
                                : Expanded(
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      child: Column(
                                        children: [
                                          Container(
                                              width: double.infinity,
                                              child: DataTable(
                                                sortColumnIndex:
                                                    _currentSortColumn,
                                                sortAscending: _isAscending,
                                                columns: [
                                                  DataColumn(
                                                      label: Text('Name'),
                                                      onSort: (columnIndex, _) {
                                                        setState(() {
                                                          _currentSortColumn =
                                                              columnIndex;
                                                          if (_isAscending ==
                                                              true) {
                                                            _isAscending =
                                                                false;
                                                            updatePages.sort((img1,
                                                                    img2) =>
                                                                img2.pageNo
                                                                    .compareTo(img1
                                                                        .pageNo));
                                                          } else {
                                                            _isAscending = true;
                                                            updatePages.sort((img1,
                                                                    img2) =>
                                                                img1.pageNo
                                                                    .compareTo(img2
                                                                        .pageNo));
                                                          }
                                                        });
                                                      }),
                                                  DataColumn(
                                                      label: Text('Image')),
                                                ],
                                                rows: updatePages.map((e) {
                                                  return DataRow(
                                                    cells: [
                                                      DataCell(Text(
                                                          e.pageNo.toString())),
                                                      DataCell(Image.network(
                                                        e.contentPath,
                                                        cacheHeight: 80,
                                                        cacheWidth: 80,
                                                        fit: BoxFit.cover,
                                                      )),
                                                    ],
                                                  );
                                                }).toList(),
                                              )),
                                          getMorePageLoading
                                              ? Padding(
                                                  padding: EdgeInsets.all(5.0),
                                                  child:
                                                      LinearProgressIndicator(),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  )
                            : Expanded(
                                child: Column(
                                  children: [
                                    ListTile(
                                        contentPadding: EdgeInsets.all(10.0),
                                        leading: ToggleButtons(
                                          direction: Axis.horizontal,
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          onPressed: (int index) {
                                            setState(() {
                                              _selectedIndex = index;
                                            });
                                          },
                                          isSelected: [
                                            _selectedIndex == 0 ? true : false,
                                            _selectedIndex == 1 ? true : false,
                                          ],
                                          children: [
                                            Text('Name'),
                                            Text('Image'),
                                          ],
                                        ),
                                        title: Text(
                                          'While you\'re choosing images, you can use \"Sort by\" tool at the upper right corner. Images can be sorted by dragging image name.',
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        )),
                                    _loadingPath
                                        ? Container(
                                            height: 100,
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 40.0),
                                            child: Center(
                                                child:
                                                    const LinearProgressIndicator()),
                                          )
                                        : Expanded(
                                            child: _paths != null
                                                ? Container(
                                                    child: Scrollbar(
                                                        child:
                                                            ReorderableListView
                                                                .builder(
                                                      itemCount: _paths !=
                                                                  null &&
                                                              _paths!.isNotEmpty
                                                          ? _paths!.length
                                                          : 1,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        final bool isMultiPath =
                                                            _paths != null &&
                                                                _paths!
                                                                    .isNotEmpty;
                                                        final String name = (isMultiPath
                                                            ? _paths!
                                                                .map((e) =>
                                                                    e.name)
                                                                .toList()[index]
                                                            : _fileName ??
                                                                '...');
                                                        final path = _paths!
                                                            .map((e) => e.path)
                                                            .toList()[index]
                                                            .toString();

                                                        // return Image.file(
                                                        //   File(path),
                                                        //   width: 100,
                                                        //   fit: BoxFit.cover,
                                                        // );
                                                        if (path
                                                                    .split('.')
                                                                    .last !=
                                                                'jpg' &&
                                                            path
                                                                    .split('.')
                                                                    .last !=
                                                                'png' &&
                                                            path
                                                                    .split('.')
                                                                    .last !=
                                                                'jpeg') {
                                                          imageError = true;
                                                          return ListTile(
                                                            key: ValueKey(name),
                                                            title: Text(
                                                              'This is not a image',
                                                            ),
                                                            subtitle:
                                                                Text(path),
                                                          );
                                                        } else {
                                                          if (_selectedIndex ==
                                                              1) {
                                                            return Image.file(
                                                              File(path),
                                                              key: ValueKey(
                                                                  name),
                                                            );
                                                          } else {
                                                            return ListTile(
                                                              key: ValueKey(
                                                                  name),
                                                              title: Text(
                                                                name,
                                                              ),
                                                              subtitle:
                                                                  Text(path),
                                                            );
                                                          }
                                                        }
                                                      },
                                                      onReorder: reorderData,
                                                    )),
                                                  )
                                                : Container(),
                                          ),
                                  ],
                                ),
                              ),
                        Container(
                            padding: EdgeInsets.all(10.0),
                            width: double.infinity,
                            child: Text(
                              'Total Page: $totalPages',
                              textAlign: TextAlign.left,
                            )),
                        InkWell(
                          onTap: () async {
                            _openFileExplorer();
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.grey[50]!,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey[100]!,
                                    offset: Offset(0, 1))
                              ],
                            ),
                            padding: EdgeInsets.all(5.0),
                            child: Text(
                              'Choose Images',
                              style: TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            hasImage();
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(
                                horizontal: 20.0, vertical: 5.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.indigo[50]!,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(10.0),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.indigo[100]!,
                                    offset: Offset(0, 1))
                              ],
                            ),
                            padding: EdgeInsets.all(5.0),
                            child: newChapter
                                ? Text(
                                    'Upload new chapter',
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  )
                                : Text(
                                    'Update chapter',
                                    style: TextStyle(fontSize: 18),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                      ],
                    )
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  String? _fileName;
  List<PlatformFile>? _paths;
  bool _loadingPath = false;
  int _selectedIndex = 0;
  bool imageError = false;

  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = _paths!.removeAt(oldindex);
      _paths!.insert(newindex, items);
    });
  }

  void _openFileExplorer() async {
    setState(() {
      imageError = false;
      _loadingPath = true;
      updateImages = true;
      totalPages = 0;
    });
    await _clearCachedFiles();
    try {
      //_directoryPath = null;
      _paths = (await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: true,
        onFileLoading: (FilePickerStatus status) => print(status),
      ))
          ?.files;
      try {
        _paths!.sort((a, b) => int.parse(a.name.split('.').first)
            .compareTo(int.parse(b.name.split('.').first)));
      } catch (e) {
        print(e);
        _paths!.sort((a, b) => a.name.compareTo(b.name));
      }
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    } catch (ex) {
      print(ex);
    }
    if (!mounted) return;
    setState(() {
      totalPages = _paths != null ? _paths!.length : 0;
      _loadingPath = false;
      _fileName =
          _paths != null ? _paths!.map((e) => e.name).toString() : '...';
    });
  }

  Future<void> _clearCachedFiles() async {
    await FilePicker.platform.clearTemporaryFiles();
  }

  Future<void> assetToBase64Images() async {
    if (_paths != null) {
      print(_paths![0].path);
      for (int i = 0; i < _paths!.length; i++) {
        Uint8List uint8list = File(_paths![i].path!).readAsBytesSync();
        print("$i this is i");
        setState(() {
          insertPages.add(
            InsertPageModel(
              pageNo: i + 1,
              content: Utility.base64String(uint8list),
            ),
          );
        });
      }
    }
  }
}
