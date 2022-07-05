import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_name_bloc.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:equatable/equatable.dart';

part 'get_manga_by_update_event.dart';
part 'get_manga_by_update_state.dart';

class GetMangaByUpdateBloc extends Bloc<GetMangaByUpdateEvent, GetMangaByUpdateState> {
  GetMangaByUpdateBloc({required this.apiRepository}) : super(const GetMangaByUpdateState());

  final ApiRepository apiRepository;

  set setToken(String data) => token = data;

  late String token;



  @override
  Stream<Transition<GetMangaByUpdateEvent, GetMangaByUpdateState>> transformEvents(
      Stream<GetMangaByUpdateEvent> events,
      TransitionFunction<GetMangaByUpdateEvent, GetMangaByUpdateState> transitionFn,
      ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<GetMangaByUpdateState> mapEventToState(GetMangaByUpdateEvent event) async* {
    if (event is GetMangaByUpdateFetched) {
      yield await _mapMangaFetchedToState(state);
    }else if (event is GetMangaByUpdateReload) {
      yield await _mapMangaFetchedToState(state.copyWith(
          mangaList: [],
          hasReachedMax: false,
          status: GetMangaByUpdateStatus.initial));
    }
  }

  Future<GetMangaByUpdateState> _mapMangaFetchedToState(GetMangaByUpdateState state) async {
    if (state.hasReachedMax) return state;
    try {
      if (state.status == GetMangaByUpdateStatus.initial) {
        final mangaList = await _fetchMangaByUpdate();
        return state.copyWith(
          status: GetMangaByUpdateStatus.success,
          mangaList: mangaList,
          hasReachedMax: false,
        );
      }
      final mangaList = await _fetchMangaByUpdate();
      return mangaList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
        status: GetMangaByUpdateStatus.success,
        mangaList: List.of(state.mangaList)..addAll(mangaList),
        hasReachedMax: false,
      );
    } on Exception {
      return state.copyWith(status: GetMangaByUpdateStatus.failure);
    }
  }

  set setPage(data) => page = data;
  int page = 0;

  Future<List<MangaModel>> _fetchMangaByUpdate() async {
    print('Page value $page');
    GetAllMangaModel data = await apiRepository.getAllManga('updated_Date', 'desc', page++, token);
    print(data.mangaList.length);
    return data.mangaList;
  }
}
