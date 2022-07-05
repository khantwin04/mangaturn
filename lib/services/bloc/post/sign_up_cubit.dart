import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final ApiRepository apiRepository;
  final Box<AuthResponseModel> authBox;
  SignUpCubit({required this.apiRepository, required this.authBox})
      : super(SignUpInitial());

  void signUp(SignUpModel model) {
    print(model.toJson());
    emit(SignUpLoading());
    apiRepository.signUp(model).then((value) {
      authBox.put('0', value);
      emit(SignUpSuccess(value));
    }).catchError((obj) {
      print(obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(SignUpFail(json.decode(res.toString())['message']));
          break;
        default:
          emit(SignUpFail(obj.toString()));
      }
    });
  }

  void logOut() {
    authBox.deleteAt(0);
  }
}
