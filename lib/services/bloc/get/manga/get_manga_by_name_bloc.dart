import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
part 'get_manga_by_name_event.dart';
part 'get_manga_by_name_state.dart';


class GetMangaByNameBloc extends Bloc<GetMangaByNameEvent, GetMangaByNameState> {
  GetMangaByNameBloc({required this.apiRepository}) : super(const GetMangaByNameState());

  final ApiRepository apiRepository;

  set setToken(String data) => token = data;

  late String token;



  @override
  Stream<Transition<GetMangaByNameEvent, GetMangaByNameState>> transformEvents(
      Stream<GetMangaByNameEvent> events,
      TransitionFunction<GetMangaByNameEvent, GetMangaByNameState> transitionFn,
      ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<GetMangaByNameState> mapEventToState(GetMangaByNameEvent event) async* {
    if (event is GetMangaByNameFetched) {
      yield await _mapMangaFetchedToState(state);
    }else if (event is GetMangaByNameReload) {
      yield await _mapMangaFetchedToState(state.copyWith(
          mangaList: [],
          hasReachedMax: false,
          status: GetMangaByNameStatus.initial));
    }
  }

  Future<GetMangaByNameState> _mapMangaFetchedToState(GetMangaByNameState state) async {
    if (state.hasReachedMax) return state;
    try {
      if (state.status == GetMangaByNameStatus.initial) {
        final mangaList = await _fetchMangaByName();
        return state.copyWith(
          status: GetMangaByNameStatus.success,
          mangaList: mangaList,
          hasReachedMax: false,
        );
      }
      final mangaList = await _fetchMangaByName();
      return mangaList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
        status: GetMangaByNameStatus.success,
        mangaList: List.of(state.mangaList)..addAll(mangaList),
        hasReachedMax: false,
      );
    } on Exception {
      return state.copyWith(status: GetMangaByNameStatus.failure);
    }
  }

  set setPage(data) => page = data;

  int page = 0;

  Future<List<MangaModel>> _fetchMangaByName() async {
    print('Page value $page');
    GetAllMangaModel data = await apiRepository.getAllManga('name', 'asc', page++, token);
      return data.mangaList;


  }
}
