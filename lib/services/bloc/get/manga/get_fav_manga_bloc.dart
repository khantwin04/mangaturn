import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/manga_models/favourite_manga_model.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'get_fav_manga_event.dart';
part 'get_fav_manga_state.dart';

class GetFavMangaBloc extends Bloc<GetFavMangaEvent, GetFavMangaState> {
  GetFavMangaBloc({required this.apiRepository})
      : super(const GetFavMangaState()) {
    on<GetFavMangaFetched>(_onFetched);
    on<GetFavMangaReload>(_onReload);
  }

  final ApiRepository apiRepository;
  late String token;
  int page = 0;

  void _onFetched(
      GetFavMangaFetched event, Emitter<GetFavMangaState> emit) async {
    if (state.hasReachedMax) return;
    try {
      final mangaList = await _fetchFavManga();
      emit(mangaList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetFavMangaStatus.success,
              mangaList: List.of(state.mangaList)..addAll(mangaList),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: GetFavMangaStatus.failure));
    }
  }

  void _onReload(
      GetFavMangaReload event, Emitter<GetFavMangaState> emit) async {
    try {
      page = 0; // Reset page number for reload
      final mangaList = await _fetchFavManga();
      emit(state.copyWith(
        status: GetFavMangaStatus.success,
        mangaList: mangaList,
        hasReachedMax: false,
      ));
    } catch (_) {
      emit(state.copyWith(status: GetFavMangaStatus.failure));
    }
  }

  Future<List<MangaModel>> _fetchFavManga() async {
    try {
      final GetAllMangaModel data =
          await apiRepository.getAllFavouriteManga(page++, token);
      print(data.mangaList.length);
      return data.mangaList;
    } catch (e) {
      print('${e.toString()} Error');
      if (e is DioError) {
        // Handle DioError specific cases
        print(e.response?.toString());
      }
      return [];
    }
  }

  Future<void> saveFavManga(FavMangaModel data) async {
    await apiRepository.addFavourtieManga(data.mangaId, token);
  }

  Future<void> deleteMangaById(int mangaId) async {
    await apiRepository.removeFavouriteManga(mangaId, token);
  }

  set setToken(String data) => token = data;
  set setPage(int data) => page = data;
}
