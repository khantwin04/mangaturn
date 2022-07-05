import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'get_all_manga_state.dart';

class GetAllMangaCubit extends Cubit<GetAllMangaState> {
  final ApiRepository apiRepository;

  GetAllMangaCubit({required this.apiRepository}) : super(GetAllMangaInitial());

  set setToken(String data) => token = data;

  late String token;

  void clear() {
    _mangaList = [];
    _popularList = [];
    totalElements = 0;
    totalDailyManga = 0;
    totalWeeklyManga = 0;
    totalLatestManga = 0;
    allMangaPageCount = 0;
    latestMangaPageCount = 0;
  }

  List<MangaModel> _mangaList = [];
  List<MangaModel> _popularList = [];
  int totalElements = 0;
  int totalDailyManga = 0;
  int totalWeeklyManga = 0;
  int totalLatestManga = 0;
  int allMangaPageCount = 0;
  int latestMangaPageCount = 0;

  set totalManga(int data) => totalElements = data;

  void addFetchData(List<MangaModel> data) {
    _mangaList.addAll(data);
  }

  void addFetchPopularManga(List<MangaModel> data) {
    _popularList.addAll(data);
  }

  List<MangaModel> getAllManga() {
    return [..._mangaList];
  }

  List<MangaModel> getPopularList() {
    return [..._popularList];
  }


  void fetchAllManga(String sortBy, String sortType, int page) {
    emit(GetAllMangaLoading());
    apiRepository.getAllManga(sortBy, sortType, page, token).then((value) {
      if (sortBy == "views") {
        addFetchPopularManga(value.mangaList);
        emit(GetAllMangaSuccess(getPopularList()));
      } else {
        addFetchData(value.mangaList);
        totalManga = value.totalElements;
        emit(GetAllMangaSuccess(getPopularList()));
      }
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          if (page == 0)
            emit(GetAllMangaFail(res.toString()));
          else
            emit(GetAllMangaSuccess(getPopularList()));
          break;
        default:
      }
    });
  }

}
