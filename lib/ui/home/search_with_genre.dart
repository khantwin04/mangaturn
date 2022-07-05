import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/models/manga_models/genre_model.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/bloc/get/get_all_genre_cubit.dart';
import 'package:mangaturn/services/bloc/get/search_manga_by_name_cubit.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchWithGenre extends StatefulWidget {
  static const String routeName = '/search_with_genre';

  @override
  _SearchWithGenreState createState() => _SearchWithGenreState();
}

class _SearchWithGenreState extends State<SearchWithGenre> {
  int? searchGenreId;
  String? genreName;
  int page = 0;
  bool pagnitionLoading = false;
  List<MangaModel> searchResult = [];
  List<GenreModel> genreList = [];

  late ScrollController _controller;

  _scrollListener() {
    var isEnd = _controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange;
    if (isEnd) {
      setState(() {
        ++page;
        BlocProvider.of<SearchMangaByNameCubit>(context)
            .searchMangaByGenre(searchGenreId!, page);
      });
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
  void didChangeDependencies() {
    genreList = BlocProvider.of<GetAllGenreCubit>(context).getGenreList();
    final args = ModalRoute.of(context)!.settings.arguments as List;
    if (args[0] == null) {
      for (int i = 0; i < genreList.length; i++) {
        if (genreList[i].name == args[1]) {
          searchGenreId = genreList[i].id;
          genreName = args[1];
          BlocProvider.of<SearchMangaByNameCubit>(context)
              .searchMangaByGenre(searchGenreId!, page);
        }
      }
    } else {
      searchGenreId = args[0];
      genreName = args[1];

      BlocProvider.of<SearchMangaByNameCubit>(context)
          .searchMangaByGenre(searchGenreId!, page);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    searchResult =
        BlocProvider.of<SearchMangaByNameCubit>(context).getGenreResult();

    return Scaffold(
      appBar: AppBar(
        title: Text('$genreName List'),
      ),
      body: BlocConsumer<SearchMangaByNameCubit, SearchMangaByNameState>(
        listener: (context, state) {
          if (state is SearchMangaByNameSuccess) {
            if (mounted) {
              setState(() {
                pagnitionLoading = false;
              });
            }
          } else if (state is SearchMangaByNameLoading && page != 0) {
            if (mounted) {
              setState(() {
                pagnitionLoading = true;
              });
            }
          }
        },
        builder: (context, state) {
          if (state is SearchMangaByNameLoading && page == 0) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is SearchMangaByNameFail) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _controller,
                    itemCount: searchResult.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          Navigator.pushNamed(context, ComicDetail.routeName,
                              arguments: [searchResult[index], null]);
                        },
                        leading: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          child: CachedNetworkImage(
                            width: 50,
                            imageUrl: searchResult[index].coverImagePath!,
                            errorWidget: (_, __, ___) => Center(
                              child: Icon(Icons.error),
                            ),
                            placeholder: (_, __) => Center(
                              child: CircularProgressIndicator(),
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(searchResult[index].name!),
                        subtitle: Text(searchResult[index].uploadedBy!),
                      );
                    },
                  ),
                ),
                pagnitionLoading
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      )
                    : Container()
              ],
            );
          }
        },
      ),
    );
  }
}
