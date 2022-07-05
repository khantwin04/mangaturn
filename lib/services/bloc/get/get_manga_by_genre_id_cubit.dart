import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'get_manga_by_genre_id_state.dart';

class GetMangaByGenreIdCubit extends Cubit<GetMangaByGenreIdState> {
  ApiRepository apiRepository;

  GetMangaByGenreIdCubit({required this.apiRepository}) : super(GetMangaByGenreIdInitial());

  set setToken(String data) => token = data;

  late String token;

  void clear(){
    mmManga = [];
    searchManga = [];
  }

  List<MangaModel> mmManga = [];
  List<MangaModel> searchManga = [];

  void addMMManga(List<MangaModel> data){
    mmManga.addAll(data);
  }

  List<MangaModel> getMMManga(){
    return [...mmManga];
  }

  void addSearchManga(List<MangaModel> data){
    searchManga.addAll(data);
  }

  void fetchMMManga(List<int> genreIdList, int page){
    emit(GetMangaByGenreIdLoading());
    apiRepository.getMangaByGenreId(genreIdList, page, token)
    .then((value) {
      addMMManga(value.mangaList);
      emit(GetMangaByGenreIdSuccess(value.mangaList));
    }).catchError((obj) {
      print(obj.toString());
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(GetMangaByGenreIdFail(res.toString()));
          break;
        default:
      }
    });

  }
}
