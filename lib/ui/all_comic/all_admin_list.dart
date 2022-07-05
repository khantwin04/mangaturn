import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mangaturn/models/manga_models/manga_user_model.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/services/bloc/get/manga/get_all_user_bloc.dart';
import 'package:mangaturn/ui/detail/uploader_info.dart';

class AllAdminList extends StatefulWidget {
  @override
  _AllAdminListState createState() => _AllAdminListState();
}

class _AllAdminListState extends State<AllAdminList> {
  late ScrollController _controller;

  bool get isEnd {
    if (!_controller.hasClients) return false;
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  _scrollListener() {
    if (isEnd) {
      BlocProvider.of<GetAllUserBloc>(context).add(GetAllUserFetched());
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
      body: BlocBuilder<GetAllUserBloc, GetAllUserState>(
        builder: (context, state) {
          switch (state.status) {
            case GetAllUserStatus.failure:
              return Center(
                child: Text('Failed to fetch uploader List'),
              );
            case GetAllUserStatus.success:
              if (state.userList.isEmpty) {
                return Center(
                  child: Text('No Uploaders'),
                );
              }
              return AnimationLimiter(
                child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemCount: state.hasReachedMax || state.userList.length < 8
                        ? state.userList.length
                        : state.userList.length + 1,
                    controller: _controller,
                    // gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                    //     childAspectRatio: (1 / 1.8), crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= state.userList.length) {
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
                                    final user = state.userList[index];

                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) => UploaderInfo(
                                              uploader: user, id: null),
                                          fullscreenDialog: true),
                                    );
                                  },
                                  leading: Hero(
                                    tag: state.userList[index].id,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(50.0),
                                      child: state.userList[index].profileUrl ==
                                              null
                                          ? Image.asset(
                                              'assets/icon/icon.png',
                                              // height: 300,
                                              width: 60,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.topCenter,
                                            )
                                          : CachedNetworkImage(
                                              imageUrl: state
                                                  .userList[index].profileUrl!,
                                              placeholder: (_, __) => Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              errorWidget: (_, __, ___) =>
                                                  Image.asset(
                                                'assets/icon/icon.png',
                                                width: 60,
                                                fit: BoxFit.cover,
                                                alignment: Alignment.topCenter,
                                              ),
                                              fit: BoxFit.cover,
                                              width: 60,
                                              alignment: Alignment.topCenter,
                                            ),
                                    ),
                                  ),
                                  title: Text(state.userList[index].username),
                                  subtitle: Text(state.userList[index].type!),
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
    
    );
  }
}
