import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/models/chapter_models/latestChapter_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

import '../../database.dart';

part 'get_latest_chapters_state.dart';

class GetLatestChaptersCubit extends Cubit<GetLatestChaptersState> {
  final ApiRepository apiRepository;
  final DBHelper dbHelper;

  GetLatestChaptersCubit({required this.apiRepository, required this.dbHelper})
      : super(GetLatestChaptersInitial());

  set setToken(String data) => token = data;

  late String token;

  void getLatestChapters() {
    emit(GetLatestChapterLoading());
    apiRepository.getLatestChapter(token).then((value) {
        var box = Hive.box('lastReadGenreList');
        box.put('lastManga', value[0].manga.name);
        box.put('similarGenreId', value[0].manga.genreList![0].id);
        
      emit(GetLatestChapterSuccess(value));
    }).catchError((obj) {
      print(obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(GetLatestChapterFail(res.toString()));
          break;
        default:
      }
    });
  }
}
