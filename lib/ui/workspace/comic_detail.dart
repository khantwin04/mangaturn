import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/error_alert.dart';
import 'package:mangaturn/custom_widgets/header.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/custom_widgets/uploader_info_alert_box.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/models/manga_models/manga_user_model.dart';
import 'package:mangaturn/services/bloc/get/manga/get_uploaded_manga_bloc.dart';
import 'package:mangaturn/services/bloc/post/edit_manga_cubit.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/chapter_list.dart';
import 'package:mangaturn/ui/workspace/chapter_list.dart';
import 'package:mangaturn/ui/workspace/character_list.dart';
import 'package:mangaturn/ui/workspace/edit_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mangaturn/custom_widgets/customText.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class ComicDetailAdminView extends StatefulWidget {
  static String routeName = '/detail-admin-view';

  @override
  _ComicDetailAdminViewState createState() => _ComicDetailAdminViewState();
}

class _ComicDetailAdminViewState extends State<ComicDetailAdminView> {
  MangaModel? _manga;
  int _currentIndex = 0;
  late String date;
  List<Widget> _children = [];
  late ApiRepository _apiRepository;

  void reloadDetail(int? id) {
    setState(() {
      _manga = null;
    });
    _apiRepository.getMangaById(id!, AuthFunction.getToken()!).then((value) {
      setState(() {
        _manga = value;
      });
    });
  }

  void getMangaInfo(MangaModel? m, int? id) {
    if (m == null) {
      reloadDetail(id);
    } else {
      setState(() {
        _manga = m;
      });
    }
  }

  @override
  void didChangeDependencies() {
    final arg = ModalRoute.of(context)!.settings.arguments;
    if (arg != null) {
      List data = arg as List;
      getMangaInfo(data[0], data[1]);
    }
    super.didChangeDependencies();
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url);
    } else {
      throw 'Could not launch $link';
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
    _apiRepository = ApiRepository(getIt.call());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    date = _manga == null
        ? "Loading"
        : DateFormat('dd MMMM, yyyy', 'en_US')
            .format(DateTime.fromMillisecondsSinceEpoch(
                _manga!.updatedDateInMilliSeconds!))
            .toString();

    _children = [
      Scaffold(
        appBar: AppBar(
          actions: [
            _manga == null
                ? Container()
                : IconButton(
                    icon: FaIcon(FontAwesomeIcons.share),
                    onPressed: () async {
                      print('ok tap');
                      Loading(context);
                      String link = await Utility.createDynamicLink(
                        userInfo: false,
                        id: _manga!.id,
                        name: _manga!.name!,
                        cover: _manga!.coverImagePath!,
                      );
                      print(link);
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
                    }),
            IconButton(
                icon: Icon(Icons.edit),
                onPressed: () async {
                  final result = await Navigator.pushNamed(
                      context, EditManga.routeName,
                      arguments: _manga);
                  if (result != null) {
                    reloadDetail(result as int);
                  }
                }),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                var result = await confirmDelete();
                if (result != null && result == true) {
                  Loading(context);
                  ApiRepository api = getIt.call();
                  api
                      .deleteMangaById(_manga!.id, AuthFunction.getToken()!)
                      .then((value) {
                    print(value);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    BlocProvider.of<GetUploadedMangaBloc>(context).setPage = 0;
                    BlocProvider.of<GetUploadedMangaBloc>(context)
                        .add(GetUploadedMangaReload());
                  }).catchError((e) {
                    print(e.toString());
                    Navigator.of(context).pop();
                    AlertError(
                        context: context, title: 'Oops', content: e.toString());
                  });
                }
              },
            ),
          ],
        ),
        body: _manga == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: AnimationLimiter(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: AnimationConfiguration.toStaggeredList(
                      duration: const Duration(milliseconds: 450),
                      childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 16.0, right: 16.0),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: CachedNetworkImage(
                                  imageUrl: _manga!.coverImagePath!,
                                  placeholder: (_, __) => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  errorWidget: (_, __, ___) => Center(
                                    child: Icon(Icons.error),
                                  ),
                                  fit: BoxFit.cover,
                                  alignment: Alignment.topCenter,
                                  height: 200,
                                  width: 150,
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        _manga!.name!,
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500),
                                        textAlign: TextAlign.start,
                                        softWrap: true,
                                      ),
                                      Text(
                                        "Author - " + _manga!.author!,
                                        style: TextStyle(fontSize: 16),
                                        textAlign: TextAlign.start,
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Latest Update : $date",
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        _manga!.update == null
                                            ? 'Normal Update'
                                            : _manga!.update! + ' Update',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        _manga!.status!,
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w300),
                                      ),
                                      SizedBox(
                                        height: 5,
                                      ),
                                      /*InkWell(
                                onTap: (){
                                  UploaderInfo(context, _manga.user);
                                },
                                child: Text(
                                  "[ Uploaded By - " + _manga.uploadedBy + " ]",
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w300, color: Colors.blue),
                                  textAlign: TextAlign.center,
                                ),
                              ),*/
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: _manga!.genreList!
                                              .map((e) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 4.0,
                                                            right: 4.0),
                                                    child: Chip(
                                                      label: Text(e.name),
                                                      backgroundColor:
                                                          Colors.grey[100],
                                                    ),
                                                  ))
                                              .toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Card(
                        //     elevation: 2.0,
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Expanded(
                        //           child: TextButton.icon(
                        //               style: ButtonStyle(
                        //                 foregroundColor:
                        //                     MaterialStateProperty.all<Color>(
                        //                         Colors.black),
                        //               ),
                        //               onPressed: () {},
                        //               icon: FaIcon(
                        //                 FontAwesomeIcons.thumbsUp,
                        //                 size: 13,
                        //                 color: Colors.blue,
                        //               ),
                        //               label: Text('Like')),
                        //         ),
                        //         Expanded(
                        //           child: TextButton.icon(
                        //               style: ButtonStyle(
                        //                 foregroundColor:
                        //                     MaterialStateProperty.all<Color>(
                        //                         Colors.black),
                        //               ),
                        //               onPressed: () {},
                        //               icon: FaIcon(
                        //                 FontAwesomeIcons.comments,
                        //                 size: 13,
                        //                 color: Colors.green,
                        //               ),
                        //               label: Text('Comment')),
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10.0, vertical: 10.0),
                          child: Linkify(
                            text: _manga!.description!,
                            onOpen: _onOpen,
                            textAlign: TextAlign.left,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Header(context, 'Stats'),
                        ),
                        ListTile(
                          contentPadding:
                              EdgeInsets.only(left: 30.0, right: 30.0),
                          leading: FaIcon(
                            FontAwesomeIcons.solidThumbsUp,
                            color: Colors.blue,
                          ),
                          title: Text('Liked'),
                          subtitle: Text(_manga!.favouriteCount.toString()),
                        ),

                        ListTile(
                          contentPadding:
                              EdgeInsets.only(left: 30.0, right: 30.0),
                          leading: FaIcon(
                            FontAwesomeIcons.eye,
                            color: Colors.brown,
                          ),
                          title: Text('View Count'),
                          subtitle: Text(_manga!.views.toString()),
                        ),
                        ListTile(
                          contentPadding:
                              EdgeInsets.only(left: 30.0, right: 30.0),
                          leading: FaIcon(
                            FontAwesomeIcons.infoCircle,
                            size: 28,
                            color: Colors.grey,
                          ),
                          title: Text('Other names'),
                          subtitle: Text(_manga!.otherNames.toString()),
                        ),
                        // ListTile(
                        //   contentPadding: EdgeInsets.only(left: 30.0, right: 30.0),
                        //   leading: FaIcon(
                        //     FontAwesomeIcons.commentAlt,
                        //     color: Colors.green,
                        //   ),
                        //   title: Text('Comments'),
                        //   subtitle: Text('1000'),
                        // ),
                        // ListTile(
                        //   contentPadding: EdgeInsets.only(left: 30.0, right: 30.0),
                        //   leading: FaIcon(
                        //     FontAwesomeIcons.bell,
                        //     color: Colors.teal,
                        //   ),
                        //   title: Text('Followed'),
                        //   subtitle: Text('100 Readers'),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
      _manga == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ChapterListAdminView(
              _manga!.id, _manga!.name!, _manga!.coverImagePath!),
      _manga == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : CharacterList(_manga!.id)
    ];

    return Scaffold(
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedLabelStyle: TextStyle(color: Colors.indigo),
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline_rounded), label: 'Detail'),
          BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined), label: 'Chapters'),
          BottomNavigationBarItem(
              icon: Icon(Icons.photo_album), label: 'Artworks'),
        ],
      ),
    );
  }

  Future<dynamic> confirmDelete() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Do you want to delete this?'),
          content:
              Text('All of your chapters and information will be deleted.'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('Delete All')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: Text('No')),
          ],
        );
      },
    );
  }
}
