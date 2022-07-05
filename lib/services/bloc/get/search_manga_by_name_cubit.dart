import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'search_manga_by_name_state.dart';

class SearchMangaByNameCubit extends Cubit<SearchMangaByNameState> {
  ApiRepository apiRepository;

  SearchMangaByNameCubit({required this.apiRepository})
      : super(SearchMangaByNameInitial());

  set setToken(String data) => token = data;

  late String token;

  void clearGenreList() {
    genreResult = [];
  }

  void clearNameList() {
    nameResult = [];
  }

  void clearUploaderList() {
    uploaderResult = [];
  }

  void clearUploaderNameList() {
    uploaderNameResult = [];
  }

  List<MangaModel> nameResult = [];
  List<MangaModel> genreResult = [];
  List<MangaModel> uploaderResult = [];
  List<GetUserModel> uploaderNameResult = [];

  List<MangaModel> getSearchResult() {
    return [...nameResult];
  }

  List<MangaModel> getGenreResult() {
    return [...genreResult];
  }

  List<MangaModel> getUploaderResult() {
    return [...uploaderResult];
  }

  List<GetUserModel> getUploaderNameResult() {
    return [...uploaderNameResult];
  }

  void searchMangaByGenre(int genreId, int page) {
    if (page == 0) genreResult.clear();
    emit(SearchMangaByNameLoading());
    apiRepository.getMangaByGenreId([genreId], page, token).then((value) {
      genreResult.addAll(value.mangaList);
      emit(SearchMangaByNameSuccess());
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          if (page == 0)
            emit(SearchMangaByNameFail(res.toString()));
          else
            emit(SearchMangaByNameSuccess());
          break;
        default:
      }
    });
  }

  void searchMangaByName(String name, int page) {
    print(name + "$page");
    if (page == 0) nameResult.clear();
    emit(SearchMangaByNameLoading());
    apiRepository.searchMangaByName(name, page, token).then((value) {
      nameResult.addAll(value);
      emit(SearchMangaByNameSuccess());
    }).catchError((obj) {
      print(obj);
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          if (page == 0)
            emit(SearchMangaByNameFail(res.toString()));
          else
            emit(SearchMangaByNameSuccess());
          break;
        default:
      }
    });
  }

  void searchMangaByUploader(String name, int page) {
    if (page == 0) uploaderResult.clear();
    emit(SearchMangaByNameLoading());
    apiRepository.getMangaByUploader(name, page, token).then((value) {
      uploaderResult.addAll(value.mangaList);
      emit(SearchMangaByNameSuccess());
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          if (page == 0)
            emit(SearchMangaByNameFail(res.toString()));
          else
            emit(SearchMangaByNameSuccess());
          break;
        default:
      }
    });
  }

  void searchUploaderByName(String name, int page) {
    if (page == 0) uploaderNameResult.clear();
    emit(SearchMangaByNameLoading());
    apiRepository.getAdminByName(name, page, token).then((value) {
      uploaderNameResult.addAll(value);
      emit(SearchMangaByNameSuccess());
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          if (page == 0)
            emit(SearchMangaByNameFail(res.toString()));
          else
            emit(SearchMangaByNameSuccess());
          break;
        default:
      }
    });
  }
}
