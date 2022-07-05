import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/services/bloc/get/get_download_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'detail/download_chapter_list.dart';

class DownloadList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Download List'),
        actions: [
          IconButton(
              icon: Icon(Icons.help_outline),
              onPressed: () {
                showDownloadHelp(context);
              }),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<GetDownloadMangaCubit, GetDownloadMangaState>(
          builder: (context, state) {
            if (state is GetDownloadMangaLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GetDownloadMangaSuccess) {
              return GridView.builder(
                  itemCount: state.manga.length,
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: (1 / 1.8), crossAxisCount: 3),
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => DownloadedChapters(
                                state.manga[index].mangaId!,
                                state.manga[index].mangaName!)));
                      },
                      onLongPress: () {
                        BlocProvider.of<GetDownloadMangaCubit>(context)
                            .deleteMangaById(state.manga[index].mangaId!);
                        BlocProvider.of<GetRecentChapterCubit>(context)
                            .deleteChapterByMangaId(state.manga[index].mangaId!);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: Hero(
                                tag: state.manga[index].mangaId!,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(5.0),
                                  child: CachedNetworkImage(
                                  
                                       imageUrl:  state.manga[index].mangaCover!,
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
                                state.manga[index].mangaName!,
                                style: TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 15),
                                textAlign: TextAlign.left,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
            } else if (state is GetDownloadMangaFail) {
              return Center(
                child: Text(state.error),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}

void showDownloadHelp(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline),
            SizedBox(width: 5),
            Text('Help'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Long Press to delete on Manga'),
            ),
          ],
        ),
      );
    },
  );
}
