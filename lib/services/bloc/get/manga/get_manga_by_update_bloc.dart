import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_name_bloc.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:equatable/equatable.dart';

part 'get_manga_by_update_event.dart';
part 'get_manga_by_update_state.dart';

class GetMangaByUpdateBloc
    extends Bloc<GetMangaByUpdateEvent, GetMangaByUpdateState> {
  GetMangaByUpdateBloc({required this.apiRepository})
      : super(const GetMangaByUpdateState()) {
    on<GetMangaByUpdateFetched>(_onFetched);
    on<GetMangaByUpdateReload>(_onReload);
  }

  final ApiRepository apiRepository;
  late String token;
  int page = 0;

  void _onFetched(GetMangaByUpdateFetched event,
      Emitter<GetMangaByUpdateState> emit) async {
    if (state.hasReachedMax) return;
    try {
      final mangaList = await _fetchMangaByUpdate();
      emit(mangaList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetMangaByUpdateStatus.success,
              mangaList: List.of(state.mangaList)..addAll(mangaList),
              hasReachedMax: false,
            ));
    } catch (error) {
      print("manga error: $error");
      emit(state.copyWith(status: GetMangaByUpdateStatus.failure));
    }
  }

  void _onReload(
      GetMangaByUpdateReload event, Emitter<GetMangaByUpdateState> emit) async {
    try {
      page = 0; // Reset page number for reload
      final mangaList = await _fetchMangaByUpdate();
      emit(state.copyWith(
        status: GetMangaByUpdateStatus.success,
        mangaList: mangaList,
        hasReachedMax: false,
      ));
    } catch (error) {
      print("manga error: $error");
      emit(state.copyWith(status: GetMangaByUpdateStatus.failure));
    }
  }

  Future<List<MangaModel>> _fetchMangaByUpdate() async {
    print('Page value $page');
    final data =
        await apiRepository.getAllManga('updated_Date', 'desc', page++, token);
    print("data length ${data.mangaList.length}");
    return data.mangaList;
  }

  set setToken(String data) => token = data;
  set setPage(int data) => page = data;
}
