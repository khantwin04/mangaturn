import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/downloadAlertBox.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/chapter_list.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:mangaturn/ui/detail/new_chapter_list.dart';
import 'package:mangaturn/ui/routes_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> LatestChapterInfo(BuildContext context,
    ChapterModel chapterModel, int mangaId, String mangaName, String mangaCover,
    {bool downloaded = false}) {
  return showMaterialModalBottomSheet(
    isDismissible: true,
    //useRootNavigator: true,
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // downloaded
        //     ? ListTile(
        //         onTap: () async {
        //           Navigator.of(context).pop();
        //           DBHelper db = DBHelper();
        //           BlocProvider.of<GetRecentChapterCubit>(context)
        //               .deleteChapterById(chapterModel.id);
        //           await db.deleteChapter(chapterModel.id, mangaId, false);
        //             BlocProvider.of<GetLatestChaptersCubit>(context)
        //                 .getLatestChapters();
        //         },
        //         leading: Icon(Icons.delete),
        //         title: Text("Delete Chapter"),
        //       )
        //     : chapterModel.type == "FREE" || chapterModel.isPurchase == true
        //         ? ListTile(
        //             onTap: () async {
        //               Utility.requestPermission();
        //               Navigator.of(context).pop();
        //               BlocProvider.of<DownloadCubit>(context)
        //                   .downloadIndividualChapter(
        //                       chapterModel, mangaId, mangaCover, mangaName);
        //             },
        //             leading: Icon(Icons.download_sharp),
        //             title: Text('Download Chapter'),
        //           )
        //         : Container(),
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, ComicDetail.routeName,
                arguments: [null, mangaId]);
          },
          leading: Icon(Icons.info_outline_rounded),
          title: Text("More Manga Info"),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => NewChapterList(
                  mangaId: mangaId,
                  mangaName: mangaName,
                  mangaCover: mangaCover),
            ));
          },
          leading: Icon(Icons.menu_book),
          title: Text('View Chapters'),
        ),
      ],
    ),
  );
}
