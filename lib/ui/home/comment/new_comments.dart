import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangaturn/config/local_storage.dart';
import 'package:mangaturn/custom_widgets/error_alert.dart';
import 'package:mangaturn/models/comment_model/get_comment_model.dart';
import 'package:mangaturn/models/comment_model/post_comment_model.dart';
import 'package:mangaturn/services/bloc/comment/get_mentioned_comment/get_mentioned_bloc.dart';
import 'package:mangaturn/services/bloc/comment/get_unread_comment_by_admin/get_unread_comment_by_admin_cubit.dart';
import 'package:mangaturn/services/bloc/comment/post_comment/post_comment_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';

class NewComments extends StatefulWidget {
  const NewComments({Key? key}) : super(key: key);

  @override
  _NewCommentsState createState() => _NewCommentsState();
}

class _NewCommentsState extends State<NewComments> {
  late ScrollController _controller;
  String cmt = '';
  GetCommentModel? replyToUser;

  bool get isEnd {
    if (!_controller.hasClients) return false;
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  _scrollListener() {
    if (isEnd) {
      BlocProvider.of<GetMentionedCommentBloc>(context)
          .add(GetMentionedCommentFetched());
    }
  }

  void reloadComment() {
    BlocProvider.of<GetMentionedCommentBloc>(context).setPage = 0;
    BlocProvider.of<GetMentionedCommentBloc>(context).emit(
      GetMentionedCommentState(
          hasReachedMax: false,
          cmtList: [],
          status: GetMentionedCommentStatus.initial),
    );
    BlocProvider.of<GetMentionedCommentBloc>(context)
        .add(GetMentionedCommentReload());
  }

  var _textController = TextEditingController();
  late FocusNode myFocusNode;

  @override
  void initState() {
    BlocProvider.of<GetUnreadCommentByAdminCubit>(context)
        .getUnreadCommentByAdmin();
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller.addListener(_scrollListener);
    reloadComment();
    myFocusNode = FocusNode();
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
        title: Text('Replied Comments'),
      ),
      body: Column(
        children: [
          BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
            builder: (context, state) {
              if (state is GetUserProfileSuccess) {
                if (state.user.role != "USER") {
                  return BlocBuilder<GetUnreadCommentByAdminCubit,
                      GetUnreadCommentByAdminState>(
                    builder: (context, state) {
                      if (state is GetUnreadCommentByAdminSuccess) {
                        if (state.cmtList.length == 0) {
                          return Container();
                        }
                        return Container(
                          height: 180,
                          padding: EdgeInsets.fromLTRB(16.0, 8.0, 0, 0),
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: state.cmtList.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ComicDetail.routeName,
                                      arguments: [
                                        null,
                                        state.cmtList[index].mangaId
                                      ]);
                                },
                                child: Container(
                                  height: 180,
                                  width: 110,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                          child: CachedNetworkImage(
                                              height: 120,
                                              width: 100,
                                              fit: BoxFit.cover,
                                              imageUrl: state.cmtList[index]
                                                  .mangaCoverUrl)),
                                      Text(
                                        state.cmtList[index].mangaName,
                                        style: TextStyle(
                                            fontSize: 15, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      Text(
                                        "${state.cmtList[index].count} Comments",
                                        style: TextStyle(
                                            fontSize: 13, color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else if (state is GetUnreadCommentByAdminFail) {
                        return Container(
                          height: 180,
                          child: Center(
                            child: Text(state.error),
                          ),
                        );
                      } else {
                        return Container(
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                    },
                  );
                } else {
                  return Container();
                }
              } else {
                return Container();
              }
            },
          ),
          Expanded(
            child:
                BlocConsumer<GetMentionedCommentBloc, GetMentionedCommentState>(
              listener: (context, state) {
                if (state.status == GetMentionedCommentStatus.success) {
                  setState(() {
                    replyToUser = null;
                  });
                }
              },
              builder: (context, state) {
                switch (state.status) {
                  case GetMentionedCommentStatus.failure:
                    return Center(
                      child: Text('Failed to fetch comment List'),
                    );
                  case GetMentionedCommentStatus.success:
                    if (state.cmtList.isEmpty) {
                      return Center(
                        child: Text('No Comments'),
                      );
                    }
                    return AnimationLimiter(
                      child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount:
                              state.hasReachedMax || state.cmtList.length < 8
                                  ? state.cmtList.length
                                  : state.cmtList.length + 1,
                          controller: _controller,
                          // gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                          //     childAspectRatio: (1 / 1.8), crossAxisCount: 3),
                          itemBuilder: (BuildContext context, int index) {
                            if (index >= state.cmtList.length) {
                              return Container(
                                height: 50,
                                padding: EdgeInsets.symmetric(horizontal: 40.0),
                                child: Center(
                                  child: LinearProgressIndicator(),
                                ),
                              );
                            } else {
                              return AnimationConfiguration.staggeredList(
                                position: index,
                                duration: const Duration(milliseconds: 375),
                                child: ScaleAnimation(
                                  child: FadeInAnimation(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                          title: Text(
                                            state.cmtList[index].mangaName,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          trailing: IconButton(
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  ComicDetail.routeName,
                                                  arguments: [
                                                    null,
                                                    state.cmtList[index].mangaId
                                                  ]);
                                            },
                                            icon: Icon(Icons.more_horiz),
                                          ),
                                        ),
                                        Container(
                                          color: state.cmtList[index].replied !=
                                                      null &&
                                                  state.cmtList[index].replied!
                                              ? Colors.grey[200]
                                              : Colors.white,
                                          child: ListTile(
                                            // onTap: () {
                                            //   final cmt = state.cmtList[index];
                                            //   // Navigator.of(context).push(
                                            //   //   MaterialPageRoute(
                                            //   //       builder: (context) => UploaderInfo(
                                            //   //           uploader: user, id: null),
                                            //   //       fullscreenDialog: true),
                                            //   // );
                                            // },
                                            minLeadingWidth: 50,
                                            leading: Hero(
                                              tag: state.cmtList[index].id,
                                              child: CircleAvatar(
                                                backgroundImage: state
                                                            .cmtList[index]
                                                            .createdUserProfileUrl ==
                                                        ''
                                                    ? CachedNetworkImageProvider(
                                                        'https://st3.depositphotos.com/1767687/16607/v/450/depositphotos_166074422-stock-illustration-default-avatar-profile-icon-grey.jpg')
                                                    : CachedNetworkImageProvider(
                                                        state.cmtList[index]
                                                            .createdUserProfileUrl,
                                                      ),
                                              ),
                                            ),
                                            title: Text(state.cmtList[index]
                                                        .mentionedUsername ==
                                                    null
                                                ? state.cmtList[index]
                                                    .createdUsername
                                                : "Replied From @" +
                                                    state.cmtList[index]
                                                        .createdUsername),
                                            subtitle: Text(
                                                state.cmtList[index].content),
                                            trailing: TextButton(
                                              child: Text('Reply'),
                                              onPressed: () {
                                                setState(() {
                                                  replyToUser =
                                                      state.cmtList[index];
                                                });
                                                myFocusNode.requestFocus();
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }
                          }),
                    );
                  default:
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                }
              },
            ),
          ),
          replyToUser == null
              ? Container()
              : ListTile(
                  leading: FaIcon(FontAwesomeIcons.comment),
                  title: TextFormField(
                    textInputAction: TextInputAction.done,
                    focusNode: myFocusNode,
                    controller: _textController,
                    decoration: InputDecoration(
                      prefix: replyToUser == null
                          ? null
                          : Text('@${replyToUser!.createdUsername} '),
                      border: InputBorder.none,
                    ),
                    // onChanged: (String data) {
                    //   setState(() {
                    //     cmt = data;
                    //   });
                    // },
                    onFieldSubmitted: (String data) async {
                      FocusScope.of(context).unfocus();
                      PostCommentModel model = PostCommentModel(
                        mangaId: replyToUser!.mangaId,
                        chapterId: null,
                        content: replyToUser == null
                            ? ''
                            : "Reply to @" +
                                replyToUser!.createdUsername +
                                " \n" +
                                _textController.value.text,
                        mentionedUserId: replyToUser == null
                            ? null
                            : replyToUser!.createdUserId,
                      );
                      await LocalStorage.saveRepliedCmt(replyToUser!.id);
                      BlocProvider.of<PostCommentCubit>(context)
                          .postComment(model);
                      print(model.toJson());
                    },
                  ),
                  trailing: BlocConsumer<PostCommentCubit, PostCommentState>(
                    listener: (context, state) {
                      if (state is PostCommentFail) {
                        AlertError(
                            context: context,
                            title: 'Something wrong',
                            content: state.error);
                      } else if (state is PostCommentSuccess) {
                        _textController.clear();
                        reloadComment();
                      }
                    },
                    builder: (context, state) {
                      if (state is PostCommentLoading) {
                        return CircularProgressIndicator();
                      } else {
                        return IconButton(
                          icon: Icon(Icons.send),
                          onPressed: () async {
                            FocusScope.of(context).unfocus();
                            PostCommentModel model = PostCommentModel(
                              mangaId: replyToUser!.mangaId,
                              content: replyToUser == null
                                  ? ''
                                  : "Reply to @" +
                                      replyToUser!.createdUsername +
                                      " \n" +
                                      _textController.value.text,
                              mentionedUserId: replyToUser == null
                                  ? null
                                  : replyToUser!.createdUserId,
                            );
                            await LocalStorage.saveRepliedCmt(replyToUser!.id);
                            BlocProvider.of<PostCommentCubit>(context)
                                .postComment(model);
                            print(model.toJson());
                          },
                        );
                      }
                    },
                  ),
                ),
        ],
      ),
    );
  }
}
