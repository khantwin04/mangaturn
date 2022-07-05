import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/manga_models/insert_character_model.dart';
import 'package:mangaturn/models/manga_models/update_character_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'edit_characters_state.dart';

class EditCharactersCubit extends Cubit<EditCharactersState> {
  ApiRepository apiRepository;
  EditCharactersCubit(this.apiRepository) : super(EditCharactersInitial());

  late String token;

  set setToken(String data) => token = data;

  void insertNewCharacter(InsertCharacterModel data) {
    emit(EditCharactersLoading());
    apiRepository.insertNewCharacter(data, token).then((value) {
      emit(EditCharactersSuccess());
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          emit(EditCharactersFail(res.toString()));
          break;
        default:
      }
    });
  }

  void deleteCharacter(UpdateCharacterModel data) {
    emit(EditCharactersLoading());
    apiRepository.deleteCharacter(data.id, token)
    .then((value) {
      emit(EditCharactersSuccess());
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          final res = (obj as DioError).response;
          emit(EditCharactersFail(res.toString()));
          break;
        default:
      }
    });
  }
}
