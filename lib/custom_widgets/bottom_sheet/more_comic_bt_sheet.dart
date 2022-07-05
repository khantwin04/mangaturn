import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/ui/detail/chapter_list.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:flutter/material.dart';
import 'package:mangaturn/ui/detail/new_chapter_list.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> MoreComicInfo(BuildContext context, MangaModel model) {
  return showMaterialModalBottomSheet(
    isDismissible: true,
    //useRootNavigator: true,
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ListTile(
        //   leading: Icon(Icons.favorite_border),
        //   title: Text("Add to Fav"),
        // ),
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushNamed(context, ComicDetail.routeName,
                arguments: [model, null]);
          },
          leading: Icon(Icons.read_more),
          title: Text("View Comic"),
        ),
        ListTile(
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  NewChapterList(mangaId: model.id, mangaName: model.name!, mangaCover: model.coverImagePath!),
            ));
          },
          leading: Icon(Icons.file_download),
          title: Text("Download Chapters"),
        ),
        // ListTile(
        //   leading: Icon(Icons.mark_email_read),
        //   title: Text("Subscribe this Comic"),
        // ),
      ],
    ),
  );
}
