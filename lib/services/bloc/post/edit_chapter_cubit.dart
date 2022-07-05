import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/chapter_models/insert_chapter_model.dart';
import 'package:mangaturn/models/chapter_models/update_chapter_model.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'edit_chapter_state.dart';

class EditChapterCubit extends Cubit<EditChapterState> {
  final ApiRepository apiRepository;

  EditChapterCubit({required this.apiRepository}) : super(EditChapterInitial());

  late String token;

  set setToken(data) => token = data;

  void uploadNewChapter(InsertChapterModel chapter, int totalPages) {
    emit(EditChapterLoading());
    apiRepository.insertNewChapter(chapter, token).then((value) {
      Map<String, dynamic> data = json.decode(json.decode(value)['data']);
      
      emit(EditChapterSuccess(ChapterModel(
          type: chapter.type,
          chapterName: chapter.chapterName,
          point: chapter.point,
          totalPages: totalPages,
          chapterNo: chapter.chapterNo,
          id: data['id'],
          pages: [],
          isPurchase: false)));
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(EditChapterFail(res.toString()));
          break;
        default:
      }
    });
  }

  void updateOldChapter(UpdateChapterModel chapter) {
    print(chapter.toJson());
    emit(EditChapterLoading());
    apiRepository.updateOldChapter(chapter, token).then((value) {
      emit(EditChapterSuccess(ChapterModel(
          type: '',
          chapterName: '',
          point: 0,
          totalPages: 0,
          chapterNo: 0,
          id: 0,
          pages: [],
          isPurchase: false)));
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(EditChapterFail(res.toString()));
          break;
        default:
      }
    });
  }
}
