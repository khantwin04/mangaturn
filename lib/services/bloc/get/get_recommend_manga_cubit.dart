import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

part 'get_recommend_manga_state.dart';

class GetRecommendMangaCubit extends Cubit<GetRecommendMangaState> {
  ApiRepository apiRepository;
  GetRecommendMangaCubit(this.apiRepository)
      : super(GetRecommendMangaInitial());

  set setToken(String data) => token = data;

  late String token;

  Future<void> fetchRelatedGenreManga(List<int> genreIdList) async {
    emit(GetRecommendMangaLoading());
    List<MangaModel> recommendList = [];
    for (int i = 0; i < genreIdList.length; i++) {
      GetAllMangaModel data =
          await apiRepository.getMangaByGenreId([genreIdList[i]], 0, token);
      for (int i = 0; i < data.mangaList.length; i++) {
        if (recommendList
                .where((element) => element.id == data.mangaList[i].id)
                .length !=
            1) {
          recommendList.add(data.mangaList[i]);
        }
      }
    }
    emit(GetRecommendMangaSuccess(recommendList));
  }
}
