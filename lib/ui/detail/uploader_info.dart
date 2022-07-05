import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:device_apps/device_apps.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/header.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/models/firestore_models/follow_uploader_model.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/bloc/firestore/get_follow_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:share/share.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class UploaderInfo extends StatefulWidget {
  final GetUserModel? uploader;
  final int? id;

  UploaderInfo({this.uploader, this.id});

  @override
  _UploaderInfoState createState() => _UploaderInfoState();
}

class _UploaderInfoState extends State<UploaderInfo> {
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _onOpen(LinkableElement link) async {
    if (await canLaunch(link.url)) {
      await launch(link.url, forceSafariVC: true);
    } else {
      throw 'Could not launch $link';
    }
  }

  List<MangaModel> relatedManga = [];
  late ApiRepository apiRepository;
  late String token;
  late DBHelper dbHelper;
  bool notFetch = true;
  GetUserModel? userModel;
  late String updateDate;
  late String createdDate;

  void getToken() {
    final data = AuthFunction.getToken();
    setState(() {
      token = data!;
    });
    print(token);
    if (widget.uploader == null) {
      getUserInfo();
    } else {
      setState(() {
        userModel = widget.uploader!;
        updateDate = DateFormat('dd MMMM, yyyy', 'en_US')
            .format(DateTime.fromMillisecondsSinceEpoch(
                userModel!.updatedDateInMilliSeconds))
            .toString();

        createdDate = DateFormat('dd MMMM, yyyy', 'en_US')
            .format(DateTime.fromMillisecondsSinceEpoch(
                userModel!.createdDateInMilliSeconds))
            .toString();
      });
      getData();
    }
  }

  void getUserInfo() {
    print('widget ${widget.id}');
    apiRepository.getUserById(widget.id, token).then((value) {
      setState(() {
        userModel = value;
      });
      getData();
      setState(() {
        updateDate = DateFormat('dd MMMM, yyyy', 'en_US')
            .format(DateTime.fromMillisecondsSinceEpoch(
                userModel!.updatedDateInMilliSeconds))
            .toString();

        createdDate = DateFormat('dd MMMM, yyyy', 'en_US')
            .format(DateTime.fromMillisecondsSinceEpoch(
                userModel!.createdDateInMilliSeconds))
            .toString();
      });
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

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    dbHelper = DBHelper();
    apiRepository = getIt.call();
    getToken();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        getData();
      }
    });
    super.initState();
  }

  int page = -1;
  ScrollController _scrollController = new ScrollController();
  bool isLoading = false;
  bool noManga = false;
  String sortingField = 'name';
  String sortType = 'asc';

  void getData() {
    if (!isLoading) {
      setState(() {
        page++;
        isLoading = true;
      });

      apiRepository
          .getMangaByUploader(userModel!.username, page, token)
          .then((_manga) {
        print(_manga.mangaList.length);
        setState(() {
          notFetch = false;
          isLoading = false;
          relatedManga.addAll(_manga.mangaList);
        });
      }).catchError((e) {
        print(e.toString());
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<int> followIdList = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    followIdList = BlocProvider.of<GetFollowCubit>(context).getFollowUserIdList;
  }

  Widget mangaCard(BuildContext context, int index) {
    if (index == relatedManga.length) {
      return _buildProgressIndicator();
    } else {
      final manga = relatedManga[index];
      return InkWell(
        onTap: () {
          Navigator.pushNamed(context, ComicDetail.routeName, arguments: [
            manga,
            manga.id,
          ]);
        },
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Expanded(
                child: Hero(
                  tag: manga.id.toString(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5.0),
                    child: CachedNetworkImage(
                      imageUrl: manga.coverImagePath!,
                      placeholder: (_, __) => Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorWidget: (_, __, ___) => Center(
                        child: Icon(Icons.error),
                      ),
                      fit: BoxFit.cover,
                      height: 120,
                      width: double.infinity,
                      alignment: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              Container(
                height: 50,
                width: double.infinity,
                child: Text(
                  manga.name!,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Visibility(
          visible: isLoading,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(
          userModel == null ? "Loading" : userModel!.username,
        ),
      ),
      body: userModel == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Card(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: userModel!.profileUrl == null
                              ? Container(
                                  height: 250,
                                  width: 200,
                                  color: Colors.grey[200],
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: CachedNetworkImage(
                                    imageUrl: userModel!.profileUrl!,
                                    height: 250,
                                    width: 200,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      height: 150,
                                      child: Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Center(
                                      child: Container(
                                          height: 150,
                                          child: Icon(Icons.error)),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Updated at",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.indigo),
                            ),
                            Text(updateDate),
                            Text(
                              "Created at",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.indigo),
                            ),
                            Text(createdDate),
                            Text(
                              "Role",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.indigo),
                            ),
                            Text("${userModel!.role}"),
                            Text(
                              "Account Type",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.indigo),
                            ),
                            Text("${userModel!.type}"),
                            Text(
                              "Earning Now",
                              style:
                                  TextStyle(fontSize: 18, color: Colors.indigo),
                            ),
                            Text("${userModel!.point} Point"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Card(
                    elevation: 2.0,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        followIdList.contains(userModel!.id)
                            ? Expanded(
                                child: TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      followIdList.remove(userModel!.id);
                                    });
                                    setState(() {});
                                    BlocProvider.of<GetFollowCubit>(context)
                                        .unfollow(userModel!.id);
                                  },
                                  icon: Icon(
                                    Icons.notification_important,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Unfollow',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              )
                            : Expanded(
                                child: TextButton.icon(
                                  onPressed: () async {
                                    setState(() {
                                      followIdList.add(userModel!.id);
                                    });
                                    setState(() {});
                                    FollowModel follow = FollowModel(
                                      userId: userModel!.id,
                                      userName: userModel!.username,
                                      userMessenger: userModel!.payment!,
                                      userCover: userModel!.profileUrl ?? '',
                                    );

                                    BlocProvider.of<GetFollowCubit>(context)
                                        .follow(follow);
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
                              ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: TextButton.icon(
                            onPressed: () async {
                              print('ok tap');
                              Loading(context);
                              String link = await Utility.createDynamicLink(
                                userInfo: true,
                                id: userModel!.id,
                                name: userModel!.username,
                                cover: userModel!.profileUrl!,
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
                            },
                            icon: FaIcon(
                              FontAwesomeIcons.share,
                              size: 13,
                            ),
                            label: Text(
                              'Share',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  userModel!.payment == null ||
                          userModel!.payment == '{}' ||
                          userModel!.payment == '/'
                      ? Container()
                      : Column(
                          children: [
                            Header(context, "Donate Us"),
                            userModel!.payment!.split('/').last == null ||
                                    userModel!.payment!.split('/').last == ''
                                ? Container()
                                : ListTile(
                                    onTap: () async {
                                      print(await DeviceApps
                                          .getInstalledApplications(
                                              includeSystemApps: false));
                                      bool isInstalled =
                                          await DeviceApps.isAppInstalled(
                                              'mm.com.wavemoney.wavepay');
                                      if (isInstalled) {
                                        FlutterClipboard.copy(userModel!
                                                .payment!
                                                .split('/')
                                                .last)
                                            .then((value) => print('copied'));
                                        await DeviceApps.openApp(
                                            'mm.com.wavemoney.wavepay');
                                      } else {
                                        _showToast(
                                            'You don\'t have Wave Pay App.');
                                      }
                                    },
                                    trailing: IconButton(
                                        onPressed: () {
                                          FlutterClipboard.copy(userModel!
                                                  .payment!
                                                  .split('/')
                                                  .last)
                                              .then((value) =>
                                                  _showToast('Copied'));
                                        },
                                        icon: Icon(Icons.copy)),
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                        'https://play-lh.googleusercontent.com/rPq4GMCZy12WhwTlanEu7RzxihYCgYevQHVHLNha1VcY5SU1uLKHMd060b4VEV1r-OQ',
                                      ),
                                    ),
                                    title: Text('Wave Pay'),
                                    subtitle: Text(
                                      'ဖုန်းနံပါတ်အလိုအလျောက်copy ကူးပြီး ယခု appကိုသွားဖွင့်ရန် နှိပ်ပါ။ ဖုန်းနံပါတ် - ${userModel!.payment!.split('/').last}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                            userModel!.payment!.split('/').first == null ||
                                    userModel!.payment!.split('/').first == ''
                                ? Container()
                                : ListTile(
                                    onTap: () async {
                                      bool isInstalled =
                                          await DeviceApps.isAppInstalled(
                                              'com.kbzbank.kpaycustomer');
                                      if (isInstalled) {
                                        FlutterClipboard.copy(userModel!
                                                .payment!
                                                .split('/')
                                                .first)
                                            .then((value) => print('copied'));
                                        await DeviceApps.openApp(
                                            'com.kbzbank.kpaycustomer');
                                      } else {
                                        _showToast(
                                            'You don\'t have KBZ Pay App.');
                                      }
                                    },
                                    trailing: IconButton(
                                        onPressed: () {
                                          FlutterClipboard.copy(userModel!
                                                  .payment!
                                                  .split('/')
                                                  .first)
                                              .then((value) =>
                                                  _showToast('Copied'));
                                        },
                                        icon: Icon(Icons.copy)),
                                    leading: CircleAvatar(
                                      backgroundImage: CachedNetworkImageProvider(
                                          'https://img1.wsimg.com/isteam/ip/151ba070-ac09-4cf9-8410-1643f3db331a/KBZ%20Pay%20Life%20Cover.png/:/cr=t:0%25,l:0%25,w:100%25,h:100%25/rs=w:400,cg:true'),
                                    ),
                                    title: Text('KBZ Pay'),
                                    subtitle: Text(
                                      'ဖုန်းနံပါတ်အလိုအလျောက်copy ကူးပြီး ယခု appကိုသွားဖွင့်ရန် နှိပ်ပါ။ ဖုန်းနံပါတ် - ${userModel!.payment!.split('/').first}',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                          ],
                        ),
                  Header(context, 'About Us'),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    width: double.infinity,
                    child: userModel!.description == null ||
                            userModel!.description == ''
                        ? Text('Uploader doesn\'t provide any information.')
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10.0, vertical: 10.0),
                            child: Linkify(
                              text: userModel!.description!,
                              onOpen: _onOpen,
                              textAlign: TextAlign.left,
                            ),
                          ),
                  ),
                  Header(context, 'Uploaded Manga'),
                  relatedManga.isEmpty && notFetch
                      ? Container(
                          height: 100,
                          width: 80,
                          child: Center(child: LinearProgressIndicator()),
                        )
                      : relatedManga.isEmpty
                          ? Container(
                              height: 150,
                              margin: EdgeInsets.all(40.0),
                              color: Colors.grey[100],
                              child: Center(child: Text("No manga uploaded")))
                          : Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: relatedManga.length + 1,
                                  gridDelegate:
                                      new SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: (1 / 1.9),
                                          crossAxisCount: 3),
                                  itemBuilder:
                                      (BuildContext context, int index) {
                                    return mangaCard(context, index);
                                  }),
                            ),
                ],
              ),
            ),
    );
  }
}
