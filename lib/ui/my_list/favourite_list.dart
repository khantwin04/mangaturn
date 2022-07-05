import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:mangaturn/services/bloc/get/manga/get_fav_manga_bloc.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:shimmer/shimmer.dart';

class FavMangaView extends StatefulWidget {
  @override
  _FavMangaViewState createState() => _FavMangaViewState();
}

class _FavMangaViewState extends State<FavMangaView> {
  late ScrollController _controller;
  late GetFavMangaBloc bloc;

  bool get isEnd {
    if (!_controller.hasClients) return false;
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  _scrollListener() {
    if (isEnd) {
      bloc.add(GetFavMangaFetched());
    }
  }

  @override
  void initState() {
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    bloc = context.read<GetFavMangaBloc>();
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
    return BlocBuilder<GetFavMangaBloc, GetFavMangaState>(
      builder: (context, state) {
        switch (state.status) {
          case GetFavMangaStatus.failure:
            return Center(
              child: Column(
                children: [
                  Text('Failed to fetch Manga List'),
                  TextButton(
                      onPressed: () {
                        BlocProvider.of<GetFavMangaBloc>(context).setPage = 0;
                        BlocProvider.of<GetFavMangaBloc>(context)
                            .add(GetFavMangaReload());
                      },
                      child: Text('Retry')),
                ],
              ),
            );
          case GetFavMangaStatus.success:
            if (state.mangaList.isEmpty) {
              return Center(
                child: Text('No Manga'),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: AnimationLimiter(
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.hasReachedMax
                        ? state.mangaList.length
                        : state.mangaList.length > 11
                            ? state.mangaList.length + 1
                            : state.mangaList.length,
                    controller: _controller,
                    itemBuilder: (BuildContext context, int index) {
                      if (index >= state.mangaList.length &&
                          state.mangaList.length > 11) {
                        return Container(
                          width: 120,
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
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
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
                                child: Container(
                                  width: 110,
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
            return Container(
              height: 200,
              padding: EdgeInsets.all(10.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[200]!,
                highlightColor: Colors.grey[50]!,
                enabled: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 100,
                          color: Colors.grey[100],
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 100,
                          color: Colors.grey[100],
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 100,
                          color: Colors.grey[100],
                        )),
                    SizedBox(
                      width: 10,
                    ),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 100,
                          color: Colors.grey[100],
                        )),
                  ],
                ),
              ),
            );
        }
      },
    );
  }
}
