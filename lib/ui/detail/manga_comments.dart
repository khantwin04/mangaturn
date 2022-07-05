import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/custom_text_field.dart';
import 'package:mangaturn/custom_widgets/error_alert.dart';
import 'package:mangaturn/models/comment_model/get_comment_model.dart';
import 'package:mangaturn/models/comment_model/post_comment_model.dart';
import 'package:mangaturn/services/bloc/comment/get_all_comment/get_all_comment_bloc.dart';
import 'package:mangaturn/services/bloc/comment/post_comment/post_comment_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';

class ViewAllComments extends StatefulWidget {
  final int mangaId;
  final int uploaderId;
  final String uploaderName;
  ViewAllComments(
      {required this.mangaId,
      required this.uploaderId,
      required this.uploaderName});

  @override
  _ViewAllCommentsState createState() => _ViewAllCommentsState();
}

class _ViewAllCommentsState extends State<ViewAllComments> {
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
      BlocProvider.of<GetAllCommentBloc>(context)
          .add(GetAllCommentFetched(widget.mangaId));
    }
  }

  void reloadComment() {
    BlocProvider.of<GetAllCommentBloc>(context).setPage = 0;
    BlocProvider.of<GetAllCommentBloc>(context).emit(
      GetAllCommentState(
          hasReachedMax: false,
          cmtList: [],
          status: GetAllCommentStatus.initial),
    );
    BlocProvider.of<GetAllCommentBloc>(context)
        .add(GetAllCommentReload(widget.mangaId));
  }

  var _textController = TextEditingController();
  late FocusNode myFocusNode;

  @override
  void initState() {
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
        title: Text('Comments'),
        actions: [
          TextButton(
              onPressed: () {
                setState(() {
                  replyToUser = GetCommentModel(
                      id: 0,
                      content: '',
                      mangaId: 0,
                      mangaName: '',
                      createdUserId: widget.uploaderId,
                      createdUsername: widget.uploaderName,
                      createdUserProfileUrl: '',
                      createdDateInMilliSeconds: 0,
                      updatedDateInMilliSeconds: 0,
                      uploaderId: 0,
                      uploaderReadStatus: false,
                      type: '',
                      mentionedUserReadStatus: false);
                });
                myFocusNode.requestFocus();
              },
              child: Text('Tag Uploader')),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<GetAllCommentBloc, GetAllCommentState>(
              listener: (context, state) {
                if (state.status == GetAllCommentStatus.success) {
                  setState(() {
                    replyToUser = null;
                  });
                }
              },
              builder: (context, state) {
                switch (state.status) {
                  case GetAllCommentStatus.failure:
                    return Center(
                      child: Text('Failed to fetch comment List'),
                    );
                  case GetAllCommentStatus.success:
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
                              state.hasReachedMax || state.cmtList.length < 9
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
                                    child: InkWell(
                                      child: ListTile(
                                        onTap: () {
                                          final cmt = state.cmtList[index];

                                          // Navigator.of(context).push(
                                          //   MaterialPageRoute(
                                          //       builder: (context) => UploaderInfo(
                                          //           uploader: user, id: null),
                                          //       fullscreenDialog: true),
                                          // );
                                        },
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
                                        title: Text(state
                                            .cmtList[index].createdUsername),
                                        subtitle: Text(state.cmtList[index]
                                                    .mentionedUsername ==
                                                null
                                            ? state.cmtList[index].content
                                            : "Replied to @" +
                                                state.cmtList[index]
                                                    .mentionedUsername! +
                                                "\n" +
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
          ListTile(
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
              onFieldSubmitted: (String data) {
                FocusScope.of(context).unfocus();
                PostCommentModel model = PostCommentModel(
                  mangaId: widget.mangaId,
                  content: _textController.value.text,
                  mentionedUserId:
                      replyToUser == null ? null : replyToUser!.createdUserId,
                  type: replyToUser == null ? "DEFAULT" : "MENTION",
                );
                BlocProvider.of<PostCommentCubit>(context).postComment(model);
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
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      PostCommentModel model = PostCommentModel(
                        mangaId: widget.mangaId,
                        content: _textController.value.text,
                        mentionedUserId: replyToUser == null
                            ? null
                            : replyToUser!.createdUserId,
                        type: replyToUser == null ? "DEFAULT" : "MENTION",
                      );
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
