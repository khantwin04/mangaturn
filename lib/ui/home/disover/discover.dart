import 'package:cached_network_image/cached_network_image.dart' as cachedImg;
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/header.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/models/user_models/update_userInfo_model.dart';
import 'package:mangaturn/services/bloc/firestore/notification_cubit.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_manga_by_genre_id_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/ui/all_comic/all_admin_list.dart';
import 'package:mangaturn/ui/detail/chapter_list.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:mangaturn/ui/detail/offline_reader.dart';
import 'package:mangaturn/ui/detail/uploader_info.dart';
import 'package:mangaturn/ui/home/disover/popular_genre.dart';
import 'package:mangaturn/ui/home/disover/recommend_manga.dart';
import 'package:mangaturn/ui/home/reader_notification.dart';
import 'package:mangaturn/ui/home/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/ui/more/purchase_method.dart';
import 'package:mangaturn/ui/more/update_user_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'latest_chapters.dart';
import 'mm_origin.dart';
import 'most_view_comic.dart';
import 'weekly_update.dart';

class DiscoverView extends StatefulWidget {
  @override
  _DiscoverViewState createState() => _DiscoverViewState();
}

class _DiscoverViewState extends State<DiscoverView> {
  String? mangaName;
  @override
  void initState() {
    var box = Hive.box('lastReadGenreList');
    mangaName = box.get('mangaName');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        BlocProvider.of<GetLatestChaptersCubit>(context).getLatestChapters();
        BlocProvider.of<GetAllMangaCubit>(context).clear();
        BlocProvider.of<GetAllMangaCubit>(context)
            .fetchAllManga("views", "desc", 0);
        BlocProvider.of<GetAllMangaCubit>(context)
            .fetchAllManga("name", "asc", 0);
        // BlocProvider.of<GetAllMangaCubit>(context)
        //     .fetchAllManga("updated_Date", "desc", 0);
        BlocProvider.of<GetMangaByGenreIdCubit>(context).clear();
        BlocProvider.of<GetMangaByGenreIdCubit>(context)
            .fetchMMManga([29769], 0);
        // var box = Hive.box('lastReadGenreList');
        // int? firstGenreId = box.get('firstGenreId');
        // int? similarGenreId = box.get('similarGenreId');
        // if (firstGenreId != null)
        //   BlocProvider.of<GetAllMangaCubit>(context)
        //       .fetchRelatedGenreManga(firstGenreId, 'first');

        // if (similarGenreId != null)
        //   BlocProvider.of<GetAllMangaCubit>(context)
        //       .fetchRelatedGenreManga(similarGenreId, 'similar');
      },
      child: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(5.0),
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                  duration: const Duration(milliseconds: 375),
                  childAnimationBuilder: (widget) => SlideAnimation(
                        horizontalOffset: 50.0,
                        child: FadeInAnimation(
                          child: widget,
                        ),
                      ),
                  children: [
                    Header(context, 'Popular Genres'),
                    PopularGenre(),
                    Header(context, 'Latest Chapters', seeMore: true),
                    LatestChaptersView(),
                    BlocBuilder<DownloadCubit, DownloadState>(
                      builder: (context, state) {
                        if (state is DownloadLoading) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                'Downloading ${state.downloadingChapter}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: LinearProgressIndicator()),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text("0/${state.totalPage}")
                                    ],
                                  ),
                                  Text(
                                    'While Downloading, don\'t quit from your app.',
                                    textAlign: TextAlign.left,
                                  )
                                ],
                              ),
                            ),
                          );
                        } else if (state is DownloadProgress) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                'Downloading ${state.downloadingChapter}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: LinearProgressIndicator()),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      state.progress == null
                                          ? Text("0/${state.totalPages}")
                                          : Text(
                                              "${state.progress}/${state.totalPages}")
                                    ],
                                  ),
                                  Text(
                                    'While Downloading, don\'t quit from your app.',
                                    textAlign: TextAlign.left,
                                  )
                                ],
                              ),
                            ),
                          );
                        } else if (state is DownloadFail) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: Icon(Icons.error),
                              title: Text(
                                  'Download Fail | ${state.downloadingChapter}'),
                              subtitle: Text(state.error),
                            ),
                          );
                        } else if (state is DownloadSuccess) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              onTap: () {
                                DownloadChapter chapter = DownloadChapter(
                                  chapterId: state.chapterId,
                                  chapterName: state.downloadingChapter,
                                  mangaId: state.mangaId,
                                );
                                Navigator.pushNamed(
                                    context, OfflineReader.routeName,
                                    arguments: [
                                      state.chapterId,
                                      state.downloadingChapter,
                                      state.mangaName,
                                      state.mangaId,
                                      [chapter],
                                      0,
                                    ]);
                              },
                              leading: Icon(Icons.download_sharp),
                              title: Text(
                                'Downloaded ${state.downloadingChapter}',
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text('You can read now.'),
                            ),
                          );
                        }
                        return Container();
                      },
                    ),
                    mangaName == null
                        ? Container()
                        : Header(context, 'Recommend for you'),
                    MangaRecommend(),

                    //Divider(indent: 10, endIndent: 10, thickness: 2,),
                    // MMOriginComicView(),
                    // Header(context, 'All Uploaders'),
                    // AllAdminList(),
                    // SizedBox(
                    //   height: 10,
                    // ),
                    Header(context, 'Most View Comic'),
                    MostViewComic(),
                    //Header(context, 'Weekly Update'),
                    //WeeklyUpdateComic(),
                  ]),
            ),
          ),
        ),
      ),
    );
  }
}
