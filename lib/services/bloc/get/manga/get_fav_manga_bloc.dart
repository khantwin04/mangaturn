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
      : super(const GetFavMangaState());

  final ApiRepository apiRepository;

  set setToken(String data) => token = data;

  late String token;

  @override
  Stream<Transition<GetFavMangaEvent, GetFavMangaState>> transformEvents(
    Stream<GetFavMangaEvent> events,
    TransitionFunction<GetFavMangaEvent, GetFavMangaState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<GetFavMangaState> mapEventToState(GetFavMangaEvent event) async* {
    if (event is GetFavMangaFetched) {
      yield await _mapMangaFetchedToState(state);
    } else if (event is GetFavMangaReload) {
      yield await _mapMangaFetchedToState(state.copyWith(
          mangaList: [],
          hasReachedMax: false,
          status: GetFavMangaStatus.initial));
    }
  }

  Future<GetFavMangaState> _mapMangaFetchedToState(
      GetFavMangaState state) async {
    if (state.hasReachedMax) return state;
    try {
      if (state.status == GetFavMangaStatus.initial) {
        final mangaList = await _fetchFavManga();
        return state.copyWith(
          status: GetFavMangaStatus.success,
          mangaList: mangaList,
          hasReachedMax: false,
        );
      }
      final mangaList = await _fetchFavManga();
      return mangaList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetFavMangaStatus.success,
              mangaList: List.of(state.mangaList)..addAll(mangaList),
              hasReachedMax: false,
            );
    } on Exception {
      return state.copyWith(status: GetFavMangaStatus.failure);
    }
  }

  set setPage(data) => page = data;

  int page = 0;

  Future<List<MangaModel>> _fetchFavManga() async {

    try {
      GetAllMangaModel data =
          await apiRepository.getAllFavouriteManga(page++, token);
      print(data.mangaList.length);
      return data.mangaList;
    } catch (e) {
      print(e.toString() + " Error");
      switch (e.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (e as DioError).response;
          print(res.toString());
          break;
        default:
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
}
