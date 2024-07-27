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
      : super(const GetUploadedMangaState()) {
    on<GetUploadedMangaFetched>(_onFetched);
    on<GetUploadedMangaReload>(_onReload);
  }

  final ApiRepository apiRepository;
  late String token;
  late String uploaderName;
  int page = 0;

  set setToken(String data) => token = data;
  set setUploaderName(String name) => uploaderName = name;
  set setPage(int data) => page = data;

  void _onFetched(GetUploadedMangaFetched event,
      Emitter<GetUploadedMangaState> emit) async {
    if (state.hasReachedMax) return;
    try {
      final mangaList = await _fetchMangaByUploader();
      emit(mangaList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetUploadedMangaStatus.success,
              mangaList: List.of(state.mangaList)..addAll(mangaList),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: GetUploadedMangaStatus.failure));
    }
  }

  void _onReload(
      GetUploadedMangaReload event, Emitter<GetUploadedMangaState> emit) async {
    try {
      page = 0; // Reset page number for reload
      final mangaList = await _fetchMangaByUploader();
      emit(state.copyWith(
        status: GetUploadedMangaStatus.success,
        mangaList: mangaList,
        hasReachedMax: false,
      ));
    } catch (_) {
      emit(state.copyWith(status: GetUploadedMangaStatus.failure));
    }
  }

  Future<List<MangaModel>> _fetchMangaByUploader() async {
    try {
      print('Page value $page');
      GetAllMangaModel data = await apiRepository.getMangaByUploaderName(
          'updated_Date', 'desc', page++, uploaderName, token);
      return data.mangaList;
    } catch (e) {
      print(e.toString() + " Error");
      return [];
    }
  }
}
