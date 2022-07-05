import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/services/database.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'get_all_chapter_state.dart';

class GetAllChapterCubit extends Cubit<GetAllChapterState> {
  ApiRepository apiRepository;
  DBHelper dbHelper;
  GetAllChapterCubit({required this.apiRepository, required this.dbHelper})
      : super(GetAllChapterInitial());

  set setToken(String data) => token = data;

  late String token;

  List<ChapterModel> _chapterList = [];
  List<ChapterModel> _allChapterList = [];

  void clear() {
    _chapterList.clear();
    _chapterList = [];
    _allChapterList.clear();
    _allChapterList = [];
  }

  void addChapterToList(List<ChapterModel> data) {
    _chapterList.addAll(data);
  }

  void addOneChapter(ChapterModel data) {
    _chapterList.add(data);
  }

  void addAllChapterToList(List<ChapterModel> data){
    _allChapterList.addAll(data);
  }

  List<ChapterModel> getChapters() {
    return [..._chapterList];
  }

  List<ChapterModel> getAllChapters(){
    return [..._allChapterList];
  }

  Future<void> fetchChapters(
      int mangaId, String sortBy, String sortType, int page, int size) async {
    emit(GetAllChapterLoading());
    List<DownloadChapter> dChapters = await dbHelper.getChapterLists(mangaId);
    apiRepository
        .getAllChapters(mangaId, sortBy, sortType, page, size, token)
        .then((chapters) async {

      for (int i = 0; i < chapters.length; i++) {
        if (dChapters.where((e) => e.chapterId == chapters[i].id).length == 1) {
          addOneChapter(ChapterModel(
            id: chapters[i].id,
            isPurchase: chapters[i].isPurchase,
            chapterName: chapters[i].chapterName,
            pages: [DownloadPage()],
            type: chapters[i].type,
            totalPages: chapters[i].totalPages,
            point: chapters[i].point,
            chapterNo: chapters[i].chapterNo,
          ));
        } else {
          addOneChapter(chapters[i]);
        }
      }
      //addChapterToList(chapters);
      emit(GetAllChapterSuccess());
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          if (page == 0)
            emit(GetAllChapterFail(res.toString()));
          else
            emit(GetAllChapterSuccess());
          break;
        default:
      }
    });
  }

  Future<void> fetchAllChapters(
      int mangaId, String sortBy, String sortType, int page, int size) async {
    emit(GetAllChapterLoading());
    _allChapterList.clear();
    _allChapterList = [];
    apiRepository
        .getAllChapters(mangaId, sortBy, sortType, page, size, token)
        .then((chapters) async {
          print(chapters.length);
          addAllChapterToList(chapters);

    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          if (page == 0)
            emit(GetAllChapterFail(res.toString()));
          else
            emit(GetAllChapterSuccess());
          break;
        default:
      }
    });
  }
}
