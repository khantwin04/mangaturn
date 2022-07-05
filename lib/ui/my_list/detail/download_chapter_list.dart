import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/offline_reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DownloadedChapters extends StatefulWidget {
  int mangaId;
  String mangaName;
  DownloadedChapters(this.mangaId, this.mangaName);
  @override
  _DownloadedChaptersState createState() => _DownloadedChaptersState();
}

class _DownloadedChaptersState extends State<DownloadedChapters> {
  List<DownloadChapter> chapters = [];
  DBHelper _dbHelper = new DBHelper();

  void getData() {
    _dbHelper.getChapterLists(widget.mangaId).then((value) {
      setState(() {
        chapters = value;
      });
    });
  }

  @override
  void initState() {
    _dbHelper = DBHelper();
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Downloaded Chapters'),
      ),
      body: ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          DownloadChapter e = chapters[index];
          return Card(
            child: ListTile(
              onTap: () {
                Navigator.pushNamed(context, OfflineReader.routeName,
                    arguments: [
                      e.chapterId,
                      e.chapterName,
                      widget.mangaName,
                      widget.mangaId,
                      chapters,
                      index,
                    ]);
              },
              leading: IconButton(
                icon: Icon(Icons.delete),
                onPressed: () async {
                  await _dbHelper.deleteChapter(
                      e.chapterId!, widget.mangaId, false);
                  BlocProvider.of<GetRecentChapterCubit>(context)
                      .deleteChapterById(e.chapterId!);
                  getData();
                },
              ),
              title: Text(e.chapterName!),
              subtitle: Text(
                "${e.totalPage} Pages",
                style: TextStyle(
                  color: Colors.indigo,
                ),
              ),
              // trailing: IconButton(
              //   icon: Icon(
              //     Icons.comment,
              //     size: 18,
              //     color: Colors.black,
              //   ),
              //   onPressed: () {},
              // ),
            ),
          );
        },
      ),
    );
  }
}
