import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/manga_models/insert_manga_model.dart';
import 'package:mangaturn/models/manga_models/update_manga_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'dart:convert';
part 'edit_manga_state.dart';

class EditMangaCubit extends Cubit<EditMangaState> {
  ApiRepository apiRepository;

  EditMangaCubit({required this.apiRepository}) : super(EditMangaInitial());

  set setToken(String data) => token = data;

  late String token;

  void insertNewManga(InsertMangaModel data) {
    emit(EditMangaLoading());
    apiRepository.insertNewManga(data, token).then((value) {
      print(value);
      Map<String, dynamic> mangaData = json.decode(json.decode(value)['data']);
      emit(EditMangaSuccess(
        mangaData['id'],
        data.name,
        mangaData['coverImagePath'],
        data.description,
      ));
    }).catchError((obj) {
      print(obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(EditMangaFail(res.toString()));
          break;
        default:
      }
    });
  }

  void updateOldManga(UpdateMangaModel data) {
    emit(EditMangaLoading());
    apiRepository
        .updateManga(data, token)
        .then((value) => emit(EditMangaSuccess(
            data.id, data.name, data.coverImage, data.description)))
        .catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(EditMangaFail(res.toString()));
          break;
        default:
      }
    });
  }
}
