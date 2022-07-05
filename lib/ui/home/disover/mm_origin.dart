import 'package:mangaturn/custom_widgets/comic_card.dart';
import 'package:mangaturn/custom_widgets/header.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/bloc/get/get_manga_by_genre_id_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class MMOriginComicView extends StatefulWidget {
  @override
  _MMOriginComicViewState createState() => _MMOriginComicViewState();
}

class _MMOriginComicViewState extends State<MMOriginComicView> {
  List<MangaModel> mmManga = [];

  @override
  Widget build(BuildContext context) {
    // mmManga = BlocProvider.of<GetMangaByGenreIdCubit>(context, listen: false).getMMManga();

    return Container(
      width: double.infinity,
      child: BlocBuilder<GetMangaByGenreIdCubit, GetMangaByGenreIdState>(
        builder: (context, state) {
          if (state is GetMangaByGenreIdSuccess) {
            return Column(
              children: [
                state.data.length == 0?Container():Header(context, 'Myanmar-Original Comic'),
                Container(
                  height: state.data.length == 0? 0: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.data.length,
                    itemBuilder: (context, index) {
                      return ComicCard(context, state.data[index]);
                    },
                  ),
                ),
              ],
            );
          } else if (state is GetMangaByGenreIdFail) {
            return Center(
              child: Text(state.error),
            );
          } else {
            return Column(
              children: [
                Shimmer.fromColors(
                    baseColor: Colors.grey[200]!,
                    highlightColor: Colors.grey[50]!,
                    enabled: true,
                    child: Header(context, 'Myanmar-Original Comic')),
                Container(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return ComicCard(context, MangaModel(id: 0), loading: true);
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
