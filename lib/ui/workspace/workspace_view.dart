import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mangaturn/custom_widgets/confirm_sending_notification.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/user_models/update_userInfo_model.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/bloc/get/manga/get_uploaded_manga_bloc.dart';
import 'package:mangaturn/ui/home/search.dart';
import 'package:mangaturn/ui/more/more.dart';
import 'package:mangaturn/ui/more/update_user_info.dart';
import 'package:mangaturn/ui/workspace/comic_detail.dart';
import 'package:mangaturn/ui/workspace/edit_manga.dart';
import 'package:mangaturn/ui/workspace/point_reclaim_history.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/ui/workspace/send_notification.dart';

class WorkspaceView extends StatefulWidget {
  @override
  _WorkspaceViewState createState() => _WorkspaceViewState();
}

class _WorkspaceViewState extends State<WorkspaceView> {
  late ScrollController _controller;

  String token = '';

  bool get isEnd {
    if (!_controller.hasClients) return false;
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  _scrollListener() {
    if (isEnd) {
      BlocProvider.of<GetUploadedMangaBloc>(context)
          .add(GetUploadedMangaFetched());
    }
  }

  @override
  void initState() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Work',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                BlocProvider.of<GetUserProfileCubit>(context).getUserProfile();
                BlocProvider.of<GetUploadedMangaBloc>(context).setPage = 0;
                BlocProvider.of<GetUploadedMangaBloc>(context)
                    .add(GetUploadedMangaReload());
              }),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => MoreView(),
              ));
            },
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.0),
            child: IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => Search(
                    isAdmin: true,
                  ),
                ));
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          BlocProvider.of<GetUserProfileCubit>(context).getUserProfile();
          BlocProvider.of<GetUploadedMangaBloc>(context).setPage = 0;
          BlocProvider.of<GetUploadedMangaBloc>(context)
              .add(GetUploadedMangaReload());
        },
        child: SingleChildScrollView(
          controller: _controller,
          padding: EdgeInsets.all(10.0),
          child: Container(
            width: double.infinity,
            child: AnimationLimiter(
              child: Column(
                children: AnimationConfiguration.toStaggeredList(
                    duration: const Duration(milliseconds: 450),
                    childAnimationBuilder: (widget) => SlideAnimation(
                          horizontalOffset: 50.0,
                          child: FadeInAnimation(
                            child: widget,
                          ),
                        ),
                    children: [
                      BlocConsumer<GetUserProfileCubit, GetUserProfileState>(
                        listener: (context, state) {
                          print(state);
                          if (state is GetUserProfileSuccess) {
                            print(state.user.id);
                          } else {
                            print('else');
                          }
                        },
                        builder: (context, state) {
                          if (state is GetUserProfileSuccess) {
                            print(state.user.id);
                            BlocProvider.of<GetUploadedMangaBloc>(context)
                                .setUploaderName = state.user.username;
                            BlocProvider.of<GetUploadedMangaBloc>(context)
                                .add(GetUploadedMangaFetched());
                            return Column(
                              children: [
                                ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(40.0),
                                    child: state.user.profileUrl == null
                                        ? Container(
                                            color: Colors.grey,
                                            height: 50,
                                            width: 50)
                                        : CachedNetworkImage(
                                            imageUrl: state.user.profileUrl!,
                                            height: 50,
                                            width: 50,
                                            fit: BoxFit.cover,
                                            alignment: Alignment.topCenter,
                                            placeholder: (_, __) => Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            ),
                                            errorWidget: (_, ___, ____) =>
                                                Center(
                                              child: Icon(Icons.error),
                                            ),
                                          ),
                                  ),
                                  title: Text(state.user.username),
                                  subtitle: Text('Edit your profile'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      UpdateUserInfoModel update =
                                          UpdateUserInfoModel(
                                              id: state.user.id,
                                              username: state.user.username,
                                              payment: state.user.payment!,
                                              description:
                                                  state.user.description ?? '',
                                              type: state.user.type!,
                                              profile: state.user.profileUrl);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateUserInfoView(
                                                      update, true)));
                                    },
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.notifications),
                                  title: Text('Send Text&Link Notification'),
                                  subtitle: Text(
                                      'You can send notification to your followers without uploading new manga or new chapter.'),
                                  trailing: IconButton(
                                      icon: Icon(Icons.send),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  SendNotification(
                                                    mangaId: 0,
                                                    mangaName: 'mangaName',
                                                    mangaCover: '',
                                                    chaperModel: ChapterModel(
                                                        type: UpdateType.post
                                                            .toString(),
                                                        chapterName: '',
                                                        point: 0,
                                                        totalPages: 0,
                                                        chapterNo: 0,
                                                        id: 0,
                                                        pages: [],
                                                        isPurchase: false),
                                                    mangaDescription: '',
                                                    updateType: UpdateType.post
                                                        .toString(),
                                                  )),
                                        );
                                      }),
                                ),
                                Card(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.monetization_on),
                                        title: state.user.point == 0
                                            ? Text('${state.user.point} Point')
                                            : Text(
                                                '${state.user.point} Points'),
                                        subtitle: Text(
                                            'Account Type - ${state.user.type}'),
                                        trailing: IconButton(
                                          icon:
                                              Icon(Icons.request_page_outlined),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  PointReclaimHistory(
                                                      state.user.point),
                                            ));
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.list),
                                  title: Text('Your uploads'),
                                  trailing: OutlinedButton(
                                      onPressed: () async {
                                        final arg = await Navigator.pushNamed(
                                            context, EditManga.routeName,
                                            arguments: null);
                                        if (arg != null) {
                                          List result = arg as List;
                                          if (result[0] == 'success') {
                                            bool notiConfirm =
                                                await confirmSendNoti(context);
                                            if (notiConfirm != null &&
                                                notiConfirm) {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      SendNotification(
                                                    mangaId: result[1],
                                                    mangaName: result[2],
                                                    mangaCover: result[3],
                                                    mangaDescription: result[4],
                                                    updateType: UpdateType
                                                        .mangaInsert
                                                        .toString(),
                                                    chaperModel: ChapterModel(
                                                        type: '',
                                                        chapterName: '',
                                                        point: 0,
                                                        totalPages: 0,
                                                        chapterNo: 0,
                                                        id: 0,
                                                        pages: [],
                                                        isPurchase: false),
                                                  ),
                                                  fullscreenDialog: true,
                                                ),
                                              );
                                            }
                                          }
                                        }
                                      },
                                      child: Text('New Upload')),
                                ),
                              ],
                            );
                          } else if (state is GetUserProfileFail) {
                            return Center(
                              child: Text(state.error),
                            );
                          } else {
                            return Column(
                              children: [
                                ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(40.0),
                                    child: Container(
                                      color: Colors.grey,
                                      width: 50,
                                      height: 50,
                                    ),
                                  ),
                                  title: Text('Loading'),
                                  subtitle: Text('Edit your profile'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {},
                                  ),
                                ),
                                Card(
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: Icon(Icons.monetization_on),
                                        title: Text('0 Point'),
                                        subtitle:
                                            Text('Account Type - Loading..'),
                                        trailing: IconButton(
                                          icon:
                                              Icon(Icons.request_page_outlined),
                                          onPressed: () {},
                                        ),
                                      ),
                                      ListTile(
                                        leading: Icon(
                                            Icons.chrome_reader_mode_outlined),
                                        title: Text('Your best comic'),
                                        subtitle: Text(
                                          'Loading',
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        trailing: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'View Counts',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                            Text(
                                              '0',
                                              style: TextStyle(fontSize: 10),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(Icons.list),
                                  title: Text('0 Uploaded'),
                                  trailing: Text('Loading..'),
                                ),
                              ],
                            );
                          }
                        },
                      ),
                      BlocBuilder<GetUploadedMangaBloc, GetUploadedMangaState>(
                        builder: (context, state) {
                          switch (state.status) {
                            case GetUploadedMangaStatus.failure:
                              return Center(
                                child: Container(
                                    height: 100,
                                    child: Text(
                                        'Failed to fetch Manga List\Try Refresh!')),
                              );
                            case GetUploadedMangaStatus.success:
                              if (state.mangaList.isEmpty) {
                                return Center(
                                  child: Container(
                                      height: 200,
                                      padding: EdgeInsets.all(40),
                                      child: Text('No Manga Uploaded')),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: AnimationLimiter(
                                  child: GridView.builder(
                                      itemCount: state.hasReachedMax ||
                                              state.mangaList.length < 8
                                          ? state.mangaList.length
                                          : state.mangaList.length + 1,
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          new SliverGridDelegateWithFixedCrossAxisCount(
                                              childAspectRatio: (1 / 1.8),
                                              crossAxisCount: 3),
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        if (index >= state.mangaList.length) {
                                          return Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Column(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    height: 100,
                                                    color: Colors.grey[100],
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    "..Loading..",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 15),
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                Container(
                                                  width: double.infinity,
                                                  child: Text(
                                                    '..Loading..',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w300),
                                                    textAlign: TextAlign.left,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        } else {
                                          return AnimationConfiguration
                                              .staggeredGrid(
                                            position: index,
                                            duration: const Duration(
                                                milliseconds: 375),
                                            columnCount: 3,
                                            child: ScaleAnimation(
                                              child: FadeInAnimation(
                                                child: InkWell(
                                                  onTap: () {
                                                    Navigator.pushNamed(
                                                        context,
                                                        ComicDetailAdminView
                                                            .routeName,
                                                        arguments: [
                                                          state
                                                              .mangaList[index],
                                                          state.mangaList[index]
                                                              .id
                                                        ]);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Column(
                                                      children: [
                                                        Expanded(
                                                          child: Hero(
                                                            tag: state
                                                                .mangaList[
                                                                    index]
                                                                .id,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5.0),
                                                              child:
                                                                  CachedNetworkImage(
                                                                imageUrl: state
                                                                    .mangaList[
                                                                        index]
                                                                    .coverImagePath!,
                                                                placeholder:
                                                                    (_, __) =>
                                                                        Center(
                                                                  child:
                                                                      CircularProgressIndicator(),
                                                                ),
                                                                errorWidget: (_,
                                                                        __,
                                                                        ___) =>
                                                                    Center(
                                                                  child: Icon(
                                                                      Icons
                                                                          .error),
                                                                ),
                                                                fit: BoxFit
                                                                    .cover,
                                                                height: 100,
                                                                width: double
                                                                    .infinity,
                                                                alignment:
                                                                    Alignment
                                                                        .topCenter,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          child: Text(
                                                            state
                                                                .mangaList[
                                                                    index]
                                                                .name!,
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 15),
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        Container(
                                                          width:
                                                              double.infinity,
                                                          child: Text(
                                                            state
                                                                        .mangaList[
                                                                            index]
                                                                        .update ==
                                                                    null
                                                                ? 'Normal Update'
                                                                : state
                                                                        .mangaList[
                                                                            index]
                                                                        .update! +
                                                                    ' Update',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300),
                                                            textAlign:
                                                                TextAlign.left,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        }
                                      }),
                                ),
                              );
                            default:
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                          }
                        },
                      )
                    ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
