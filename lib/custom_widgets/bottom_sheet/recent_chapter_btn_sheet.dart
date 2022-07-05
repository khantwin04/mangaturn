import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:mangaturn/ui/my_list/detail/download_chapter_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> MoreRecentChapter(BuildContext context, int mangaId, String mangaName, int chapterId){
  return showMaterialModalBottomSheet(
    isDismissible: true,
    useRootNavigator: true,
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.read_more),
          title: Text("All Download Chapters"),
          onTap: (){
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => DownloadedChapters(mangaId, mangaName),));
          },
        ),
        ListTile(
          leading: Icon(Icons.info_outline_rounded),
          title: Text("Manga Info"),
          onTap: (){
            Navigator.of(context).pop();
            Navigator.pushNamed(context, ComicDetail.routeName, arguments: [null, mangaId]);
          },
        ),
        ListTile(
          onTap: () async {
            BlocProvider.of<GetRecentChapterCubit>(context).deleteChapterById(chapterId);
            Navigator.of(context).pop();
          },
          leading: Icon(Icons.remove_circle),
          title: Text("Remove from List"),
        ),
      ],
    ),
  );
}