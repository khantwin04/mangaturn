import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/manga_models/genre_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'get_all_genre_state.dart';

class GetAllGenreCubit extends Cubit<GetAllGenreState> {
  ApiRepository apiRepository;

  GetAllGenreCubit({required this.apiRepository}) : super(GetAllGenreInitial());

  set setToken(String data) => token = data;

  late String token;

  List<GenreModel> genreList = [];

  List<GenreModel> getGenreList() {
    return [...genreList];
  }

  void getAllGenre() {
    emit(GetAllGenreLoading());
    apiRepository.getAllGenre(token).then((value) {
      genreList.addAll(value);
      emit(GetAllGenreSuccess(value));
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(GetAllGenreFail(res.toString()));
          break;
        default:
      }
    });
  }
}
