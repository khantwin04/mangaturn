import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recommend_manga_cubit.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';

class MangaRecommend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetRecommendMangaCubit, GetRecommendMangaState>(
      builder: (context, state) {
        if (state is GetRecommendMangaSuccess) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: state.mangaList.reversed
                .map((e) => Container(
                      height: 240,
                      padding: EdgeInsets.all(10.0),
                      //width: 350,
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushNamed(ComicDetail.routeName,
                              arguments: [null, e.id]);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ClipRRect(
                                borderRadius: BorderRadius.circular(5.0),
                                child: CachedNetworkImage(
                                    height: 200,
                                    width: 120,
                                    fit: BoxFit.cover,
                                    imageUrl: e.coverImagePath!)),
                            SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      e.name!,
                                      softWrap: true,
                                      style:
                                          TextStyle(fontSize: 16, height: 1.2),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 2,
                                    ),
                                    Text(
                                      e.author!,
                                      maxLines: 1,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      e.description!,
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: TextStyle(
                                        fontSize: 12,
                                        height: 1.5,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    Spacer(),
                                    Text(
                                      e.uploadedByUser!.username,
                                      softWrap: true,
                                    ),
                                    e.totalChapters == 1
                                        ? Text('${e.totalChapters} chapter')
                                        : Text('${e.totalChapters} chapters'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
          );
        } else if (state is GetRecommendMangaFail) {
          return Center(child: Text(state.error));
        } else {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
                10,
                (index) => Container(
                      height: 200,
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                height: 200,
                                width: 120,
                                color: Colors.grey[100],
                              )),
                          SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Loading..',
                                    style: TextStyle(fontSize: 18),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  Text(
                                    "Loading..",
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(
                                    height: 2,
                                  ),
                                  Text(
                                    "Loading...",
                                    maxLines: 5,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
          );
        }
      },
    );
  }
}
