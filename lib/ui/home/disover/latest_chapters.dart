import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/bottom_sheet/latest_chapters_bt_sheet.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class LatestChaptersView extends StatefulWidget {
  @override
  _LatestChaptersViewState createState() => _LatestChaptersViewState();
}

class _LatestChaptersViewState extends State<LatestChaptersView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetLatestChaptersCubit, GetLatestChaptersState>(
      builder: (context, state) {
        print(state);
        if (state is GetLatestChapterSuccess) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: state.chapters
                    .map((e) => InkWell(
                          onTap: () {
                            ChapterModel chapter = ChapterModel(
                                isPurchase: e.isPurchase,
                                id: e.id,
                                chapterName: e.chapterName,
                                chapterNo: e.chapterNo,
                                type: e.type,
                                point: e.point,
                                totalPages: e.totalPages);
                            Utility.onTapChapter(
                                e.manga.id, e.manga.name!, chapter, context);
                          },
                          child: Container(
                            height: 180,
                            width: 110,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                    borderRadius: BorderRadius.circular(5.0),
                                    child: CachedNetworkImage(
                                        height: 120,
                                        width: 100,
                                        fit: BoxFit.cover,
                                        imageUrl: e.manga.coverImagePath!)),
                                Text(
                                  e.chapterName,
                                  style: TextStyle(fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                // Text(
                                //   e.manga.name!,
                                //   overflow: TextOverflow.ellipsis,
                                //   maxLines: 2,
                                //   style: TextStyle(height: 1.5),
                                // ),
                                SizedBox(
                                  height: 2,
                                ),
                                e.type == "FREE"
                                    ? Text(
                                        "FREE\n${e.totalPages} Pages",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w300,
                                            height: 1),
                                      )
                                    : e.isPurchase == true
                                        ? Text(
                                            'Purchased\n${e.totalPages} Pages',
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                                height: 1),
                                          )
                                        : Text(
                                            e.type +
                                                "  -  ${e.point} Points\n${e.totalPages} Pages",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w300,
                                                color: Colors.indigo,
                                                height: 1),
                                          ),
                              ],
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
          );
        } else if (state is GetLatestChapterFail) {
          return Center(
            child: Text(state.error),
          );
        } else {
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
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Chapter name loading...',
                            style: TextStyle(fontSize: 18),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Text(
                            'Manga name loading..',
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: 2,
                          ),
                          Text(
                            'Loading data..',
                            style: TextStyle(
                              color: Colors.black,
                            ),
                          ),
                          Spacer(),
                          /*Container(
                              width: double.infinity,
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Utility.onTapChapter(e['chapterList'][0], context, token);
                                      },
                                      child: FittedBox(
                                        child: e['chapterList'][0]
                                            .type ==
                                            "FREE"
                                            ? Text("READ")
                                            : e['chapterList'][0]
                                            .isPurchase ==
                                            true
                                            ? Text('READ')
                                            : Text(
                                          'Purchase',
                                          style: TextStyle(
                                            color:
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: ElevatedButton(
                                        onPressed: () {
                                          LatestChapterInfo(
                                              context,
                                              e['chapterList'][0],
                                              e['mangaId'],
                                              e['mangaName'],
                                              e['coverImage'],
                                              token,
                                              downloaded: e['chapterList'][0].pages.isNotEmpty);
                                        },
                                        child: Text('More')),
                                  ),
                                ],
                              )), */
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        
        }
      },
    );
  }
}
