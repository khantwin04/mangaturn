import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/header.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/models/firestore_models/follow_uploader_model.dart';
import 'package:mangaturn/models/manga_models/favourite_manga_model.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/bloc/comment/get_latest_comment/get_lastest_comment_cubit.dart';
import 'package:mangaturn/services/bloc/firestore/get_follow_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/bloc/get/manga/get_fav_manga_bloc.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/character_list.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mangaturn/ui/detail/new_chapter_list.dart';
import 'package:mangaturn/ui/detail/manga_comments.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';
import 'uploader_info.dart';
import 'package:timeago/timeago.dart' as timeago;

class ComicDetail extends StatefulWidget {
  MangaModel? model;
  ComicDetail({this.model});
  static String routeName = '/detail';

  @override
  _ComicDetailState createState() => _ComicDetailState();
}

class _ComicDetailState extends State<ComicDetail> {
  MangaModel? _manga;
  int _currentIndex = 0;
  late String date;
  List<Widget> _children = [];
  late ApiRepository _apiRepository;
  late DBHelper dbHelper;
  String error = '';

  Future<dynamic> showAdultAlert() async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dear Reader,'),
        content: Text(
            'This comic is containing adult scence. Do you want to view this comic?',
            style: TextStyle(
              fontSize: 18,
            )),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Quit'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('View')),
        ],
      ),
    );
  }

  void getMangaInfo(MangaModel? m, int? id) {
    if (m == null) {
      BlocProvider.of<GetLastetCommentCubit>(context).getLastetComment(id!);
      _apiRepository.getMangaById(id, AuthFunction.getToken()!).then((value) {
        setState(() {
          _manga = value;
          if (value.isAdult == true) showAdultAlert();
        });
        List<int> glistId = value.genreList!.map((e) => e.id).toList();
        var box = Hive.box('lastReadGenreList');
        box.put('mangaName', value.name);
        box.put('genreList', glistId);
      }).catchError((e) {
        print(e.toString());
        setState(() {
          error = e.toString();
        });
      });
    } else {
      BlocProvider.of<GetLastetCommentCubit>(context).getLastetComment(m.id);
      setState(() {
        _manga = m;
      });
    }
  }

  int _selectedIndex = 0;
  List<int> favList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url, forceSafariVC: false);
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
    dbHelper = DBHelper();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final arg = ModalRoute.of(context)!.settings.arguments;
      if (arg != null) {
        List data = arg as List;
        getMangaInfo(data[0], data[1]);
      } else {
        _manga = widget.model!;
      }

      followIdList =
          BlocProvider.of<GetFollowCubit>(context).getFollowUserIdList;
    });
    super.initState();
  }

  List<int> followIdList = [];

  final key = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    print(favList.length);
    date = _manga == null
        ? "Loading"
        : DateFormat('dd MMMM, yyyy', 'en_US')
            .format(DateTime.fromMillisecondsSinceEpoch(
                _manga!.updatedDateInMilliSeconds!))
            .toString();

    _children = [
      Scaffold(
        key: key,
        appBar: AppBar(
          elevation: 0.0,
          actions: _manga == null
              ? []
              : [
                  BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
                    builder: (context, state) {
                      if (state is GetUserProfileSuccess) {
                        if (state.user.role == "USER") {
                          return _manga!.favourite == true
                              ? TextButton.icon(
                                  label: Text(
                                    '${_manga!.favouriteCount!}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  icon: Icon(Icons.favorite, color: Colors.red),
                                  onPressed: () async {
                                    Loading(context);

                                    await BlocProvider.of<GetFavMangaBloc>(
                                            context)
                                        .deleteMangaById(_manga!.id);
                                    getMangaInfo(null, _manga!.id);
                                    Navigator.of(context).pop();
                                  })
                              : TextButton.icon(
                                  label: Text(
                                    '${_manga!.favouriteCount!}',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  icon: Icon(Icons.favorite_border_outlined),
                                  onPressed: () async {
                                    Loading(context);
                                    FavMangaModel fav = FavMangaModel(
                                      mangaId: _manga!.id,
                                      mangaCover: _manga!.coverImagePath!,
                                      mangaName: _manga!.name!,
                                    );

                                    await BlocProvider.of<GetFavMangaBloc>(
                                            context)
                                        .saveFavManga(fav);
                                    getMangaInfo(null, _manga!.id);
                                    Navigator.of(context).pop();
                                  });
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    },
                  ),
                  IconButton(
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
                                  UploaderInfo(context, _manga!.user);
                                },
                                child: Text(
                                  "[ Uploaded By - " + _manga!.uploadedBy + " ]",
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
                        // Padding(
                        //   padding: const EdgeInsets.all(8.0),
                        //   child: Header(context, 'Uploader'),
                        // ),
                        ListTile(
                          contentPadding:
                              EdgeInsets.only(left: 20.0, right: 20.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(40.0),
                            child: _manga!.uploadedByUser!.profileUrl == null
                                ? Container(
                                    color: Colors.grey, height: 50, width: 50)
                                : CachedNetworkImage(
                                    imageUrl:
                                        _manga!.uploadedByUser!.profileUrl!,
                                    height: 50,
                                    width: 50,
                                    fit: BoxFit.cover,
                                    alignment: Alignment.topCenter,
                                    placeholder: (_, __) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (_, ___, ____) => Center(
                                      child: Icon(Icons.error),
                                    ),
                                  ),
                          ),
                          title: Text(_manga!.uploadedByUser!.username),
                          subtitle: Text("Uploader"),
                          trailing: followIdList
                                  .contains(_manga!.uploadedByUser!.id)
                              ? TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      followIdList
                                          .remove(_manga!.uploadedByUser!.id);
                                    });
                                    setState(() {});
                                    BlocProvider.of<GetFollowCubit>(context)
                                        .unfollow(_manga!.uploadedByUser!.id);
                                  },
                                  icon: Icon(
                                    Icons.notification_important,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Unfollow',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              : TextButton.icon(
                                  onPressed: () async {
                                    Loading(context);
                                    setState(() {
                                      followIdList
                                          .add(_manga!.uploadedByUser!.id);
                                    });
                                    setState(() {});
                                    FollowModel follow = FollowModel(
                                      userId: _manga!.uploadedByUser!.id,
                                      userName:
                                          _manga!.uploadedByUser!.username,
                                      userMessenger: '',
                                      userCover:
                                          _manga!.uploadedByUser!.profileUrl!,
                                    );

                                    BlocProvider.of<GetFollowCubit>(context)
                                        .follow(follow);
                                    Navigator.of(context).pop();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          'You will get new chapter updates notification. \nFrom ${_manga!.uploadedByUser!.username}.'),
                                      duration: Duration(seconds: 1),
                                    ));
                                  },
                                  icon: Icon(
                                    Icons.notifications,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Follow',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => UploaderInfo(
                                    uploader: null,
                                    id: _manga!.uploadedByUser!.id),
                                fullscreenDialog: true));
                          },
                        ),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18.0, vertical: 5.0),
                          child: Linkify(
                            text: _manga!.description!,
                            onOpen: _onOpen,
                            textAlign: TextAlign.justify,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Header(context, 'Latest Comments',
                              seeMore: true,
                              button: TextButton(
                                  onPressed: () {
                                    Utility.nextScreen(
                                        context,
                                        ViewAllComments(
                                          uploaderId:
                                              _manga!.uploadedByUser!.id,
                                          uploaderName:
                                              _manga!.uploadedByUser!.username,
                                          mangaId: _manga!.id,
                                        ));
                                  },
                                  child: Text('View All Comments'))),
                        ),
                        BlocBuilder<GetLastetCommentCubit,
                            GetLastetCommentState>(
                          builder: (context, state) {
                            if (state is GetLastetCommentSuccess) {
                              return InkWell(
                                onTap: () {
                                  Utility.nextScreen(
                                      context,
                                      ViewAllComments(
                                        uploaderId: _manga!.uploadedByUser!.id,
                                        uploaderName:
                                            _manga!.uploadedByUser!.username,
                                        mangaId: _manga!.id,
                                      ));
                                },
                                child: Container(
                                  margin:
                                      EdgeInsets.symmetric(horizontal: 12.0),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10.0),
                                      border: Border.all(
                                          color: Colors.grey, width: 0.5)),
                                  child: state.cmtList.length == 0
                                      ? Container(
                                          width: double.infinity,
                                          alignment: Alignment.center,
                                          height: 50,
                                          child: Text('Tap to write comments'))
                                      : ListView.builder(
                                          itemCount: state.cmtList.length,
                                          shrinkWrap: true,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, index) {
                                            return ListTile(
                                              minLeadingWidth: 50,
                                              leading: CircleAvatar(
                                                backgroundImage: state
                                                        .cmtList[index]
                                                        .createdUserProfileUrl
                                                        .isEmpty
                                                    ? null
                                                    : CachedNetworkImageProvider(
                                                        state.cmtList[index]
                                                            .createdUserProfileUrl),
                                              ),
                                              title: Text(
                                                  '${state.cmtList[index].createdUsername}'),
                                              subtitle: Text(
                                                  '${state.cmtList[index].content}'),
                                              trailing: Text(
                                                  '${timeago.format(DateTime.fromMicrosecondsSinceEpoch(state.cmtList[index].createdDateInMilliSeconds * 1000))}'),
                                            );
                                          },
                                        ),
                                ),
                              );
                            } else if (state is GetLastetCommentFail) {
                              return Center(
                                child: Text(state.error),
                              );
                            } else {
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                          },
                        ),
                        CharacterList(_manga!.id),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Header(context, 'Stats'),
                        ),
                        // ListTile(
                        //   contentPadding: EdgeInsets.only(left: 30.0, right: 30.0),
                        //   leading: FaIcon(
                        //     FontAwesomeIcons.solidThumbsUp,
                        //     color: Colors.blue,
                        //   ),
                        //   title: Text('Liked'),
                        //   subtitle: Text('10 Readers'),
                        // ),
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
          : NewChapterList(
              mangaId: _manga!.id,
              mangaName: _manga!.name!,
              mangaCover: _manga!.coverImagePath!),
    ];

    return Scaffold(
      body: error != ''
          ? Center(
              child: Text(
              "Something wrong\nMay be deleted.",
              textAlign: TextAlign.center,
            ))
          : _children[_currentIndex],
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
        ],
      ),
    );
  }
}
