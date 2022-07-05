import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';

part 'get_uploaded_manga_event.dart';

part 'get_uploaded_manga_state.dart';

class GetUploadedMangaBloc
    extends Bloc<GetUploadedMangaEvent, GetUploadedMangaState> {
  GetUploadedMangaBloc({required this.apiRepository})
      : super(const GetUploadedMangaState());

  final ApiRepository apiRepository;

  set setToken(String data) => token = data;
  set setUploaderName(String name) => uploaderName = name;
  late String uploaderName;
  late String token;

  @override
  Stream<Transition<GetUploadedMangaEvent, GetUploadedMangaState>>
      transformEvents(
    Stream<GetUploadedMangaEvent> events,
    TransitionFunction<GetUploadedMangaEvent, GetUploadedMangaState>
        transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<GetUploadedMangaState> mapEventToState(
      GetUploadedMangaEvent event) async* {
    if (event is GetUploadedMangaFetched) {
      yield await _mapMangaFetchedToState(state);
    } else if (event is GetUploadedMangaReload) {
      yield await _mapMangaFetchedToState(
        state.copyWith(
          mangaList: [],
          hasReachedMax: false,
          status: GetUploadedMangaStatus.initial,
        ),
      );
    }
  }

  Future<GetUploadedMangaState> _mapMangaFetchedToState(
      GetUploadedMangaState state) async {
    if (state.hasReachedMax) return state;
    try {
      if (state.status == GetUploadedMangaStatus.initial) {
        final mangaList = await _fetchMangaByUpdate();
        return state.copyWith(
          status: GetUploadedMangaStatus.success,
          mangaList: mangaList,
          hasReachedMax: false,
        );
      }
      final mangaList = await _fetchMangaByUpdate();
      return mangaList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetUploadedMangaStatus.success,
              mangaList: List.of(state.mangaList)..addAll(mangaList),
              hasReachedMax: false,
            );
    } on Exception {
      return state.copyWith(status: GetUploadedMangaStatus.failure);
    }
  }

  set setPage(data) => page = data;
  int page = 0;

  Future<List<MangaModel>> _fetchMangaByUpdate() async {
    print('Page value $page');
    GetAllMangaModel data = await apiRepository.getMangaByUploaderName(
        'updated_Date', 'desc', page++, uploaderName, token);
    return data.mangaList;
  }
}
