import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_name_bloc.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllComicView extends StatefulWidget {
  @override
  _AllComicViewState createState() => _AllComicViewState();
}

class _AllComicViewState extends State<AllComicView> {
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
      BlocProvider.of<GetMangaByNameBloc>(context).add(GetMangaByNameFetched());
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
    return BlocBuilder<GetMangaByNameBloc, GetMangaByNameState>(
      builder: (context, state) {
        switch (state.status) {
          case GetMangaByNameStatus.failure:
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('Failed to fetch Manga List'),
                  TextButton(
                      onPressed: () {
                        BlocProvider.of<GetMangaByNameBloc>(context).setPage =
                            0;
                        BlocProvider.of<GetMangaByNameBloc>(context)
                            .add(GetMangaByNameReload());
                      },
                      child: Text('Retry')),
                ],
              ),
            );
          case GetMangaByNameStatus.success:
            if (state.mangaList.isEmpty) {
              return Center(
                child: Text('No Manga'),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: AnimationLimiter(
                child: GridView.builder(
                    itemCount: state.hasReachedMax
                        ? state.mangaList.length
                        : state.mangaList.length + 1,
                    controller: _controller,
                    gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                        childAspectRatio: (1 / 1.8), crossAxisCount: 3),
                    itemBuilder: (BuildContext context, int index) {
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
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                child: Text(
                                  '..Loading..',
                                  style: TextStyle(fontWeight: FontWeight.w300),
                                  textAlign: TextAlign.left,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return AnimationConfiguration.staggeredGrid(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          columnCount: 3,
                          child: ScaleAnimation(
                            child: FadeInAnimation(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, ComicDetail.routeName,
                                      arguments: [
                                        null,
                                        state.mangaList[index].id
                                      ]);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Hero(
                                          tag: state.mangaList[index].id,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            child: CachedNetworkImage(
                                              imageUrl: state.mangaList[index]
                                                  .coverImagePath!,
                                              placeholder: (_, __) => Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                              errorWidget: (_, __, ___) =>
                                                  Center(
                                                child: Icon(Icons.error),
                                              ),
                                              fit: BoxFit.cover,
                                              height: 100,
                                              width: double.infinity,
                                              alignment: Alignment.topCenter,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Text(
                                          state.mangaList[index].name!,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 15),
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        width: double.infinity,
                                        child: Text(
                                          state.mangaList[index].totalChapters
                                                  .toString() +
                                              " chapters",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w300),
                                          textAlign: TextAlign.left,
                                          overflow: TextOverflow.ellipsis,
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
    );
  }
}
