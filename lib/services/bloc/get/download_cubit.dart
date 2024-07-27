import 'dart:convert';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/chapter_models/page_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:path_provider/path_provider.dart';
part 'download_state.dart';

class DownloadCubit extends Cubit<DownloadState> {
  ApiRepository apiRepository;
  DBHelper dbHelper;

  DownloadCubit({required this.apiRepository, required this.dbHelper})
      : super(DownloadInitial());

  List<int> downloadedChapters = [];

  set setDownloadedChapters(int chapterId) => downloadedChapters.add(chapterId);

  List<int> get getDownloadedChapters => [...downloadedChapters];

  set setToken(String data) => token = data;

  late String token;

  int _totalPage = 0;

  set setTotalPage(int value) => _totalPage = value;

  int get getTotalPage => _totalPage;

  void clear() {
    emit(DownloadInitial());
    downloadedChapters.clear();
  }

  Future<void> downloadIndividualChapter(ChapterModel chapter, int mangaId,
      String manga_cover, String manga_name) async {
    // emit(DownloadProgress(0, chapter.chapterName, chapter.totalPages));
    // emit(DownloadLoading(chapter.chapterName, chapter.totalPages));
    // setTotalPage = chapter.totalPages;
    // List<DownloadPage> pages = [];
    // try {
    //   String mangaCover = manga_cover;

    //   DownloadManga dManga = await dbHelper.saveMangaInfo(DownloadManga(
    //     mangaId: mangaId,
    //     mangaCover: mangaCover,
    //     mangaName: manga_name,
    //   ));
    //   DownloadChapter dChapter = await dbHelper.saveChapterInfo(DownloadChapter(
    //     mangaId: mangaId,
    //     chapterName: chapter.chapterName,
    //     totalPage: chapter.totalPages,
    //     chapterId: chapter.id,
    //   ));

    //   List<PageModel> originalPages = await apiRepository.getAllPages(
    //       chapter.id, chapter.totalPages, 0, token);

    //   for (int i = 0; i < originalPages.length; i++) {
    //     var imageId = await ImageDownloader.downloadImage(
    //       originalPages[i].contentPath,
    //       destination: AndroidDestinationType.directoryPictures
    //         ..inExternalFilesDir()
    //         ..subDirectory(
    //             '.mangaturn/.${mangaId}/.${chapter.id}/${originalPages[i].id}'),
    //       outputMimeType: "image/png",
    //     ).timeout((Duration(seconds: 40)));
    //     var path = await ImageDownloader.findPath(imageId!);
    //     pages.add(await dbHelper.savePages(DownloadPage(
    //       mangaId: mangaId,
    //       chapterId: chapter.id,
    //       contentPage: path!,
    //       pageId: originalPages[i].id,
    //     )));
    //     emit(DownloadProgress(i + 1, chapter.chapterName, chapter.totalPages));
    //   }
    //   setDownloadedChapters = chapter.id;
    //   emit(DownloadSuccess(
    //       chapter.chapterName, chapter.id, manga_name, mangaId, pages));
    // } catch (e) {
    //   ImageDownloader.cancel();
    //   print(e);
    //   emit(DownloadFail('Image resource error', chapter.chapterName));
    // }
  }

  Future<void> downloadAllChapter(List<ChapterModel> chapters, int mangaId,
      String manga_cover, String manga_name) async {
    for (int i = 0; i < chapters.length; i++) {
      await downloadIndividualChapter(
          chapters[i], mangaId, manga_cover, manga_name);
    }
    downloadedChapters.clear();
  }
}
