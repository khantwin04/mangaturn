import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'get_manga_by_name_event.dart';
part 'get_manga_by_name_state.dart';

class GetMangaByNameBloc
    extends Bloc<GetMangaByNameEvent, GetMangaByNameState> {
  GetMangaByNameBloc({required this.apiRepository})
      : super(const GetMangaByNameState()) {
    on<GetMangaByNameFetched>(_onFetched);
    on<GetMangaByNameReload>(_onReload);
  }

  final ApiRepository apiRepository;
  late String token;
  int page = 0;

  set setPage(data) => page = data;

  void _onFetched(
      GetMangaByNameFetched event, Emitter<GetMangaByNameState> emit) async {
    if (state.hasReachedMax) return;
    try {
      final mangaList = await _fetchMangaByName();
      emit(mangaList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetMangaByNameStatus.success,
              mangaList: List.of(state.mangaList)..addAll(mangaList),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: GetMangaByNameStatus.failure));
    }
  }

  void _onReload(
      GetMangaByNameReload event, Emitter<GetMangaByNameState> emit) async {
    try {
      page = 0; // Reset page number for reload
      final mangaList = await _fetchMangaByName();
      emit(state.copyWith(
        status: GetMangaByNameStatus.success,
        mangaList: mangaList,
        hasReachedMax: false,
      ));
    } catch (_) {
      emit(state.copyWith(status: GetMangaByNameStatus.failure));
    }
  }

  Future<List<MangaModel>> _fetchMangaByName() async {
    print('Page value $page');
    final data = await apiRepository.getAllManga('name', 'asc', page++, token);
    return data.mangaList;
  }

  set setToken(String data) {
    token = data;
  }
}
