import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/models/auth_models/login_model.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  
  final ApiRepository apiRepository;
  final Box<AuthResponseModel> authBox;
  LoginCubit({required this.apiRepository, required this.authBox})
      : super(LoginInitial());

  void startLogin() {
    emit(LoginInitial());
  }

  void login(LoginModel model) {
    emit(LoginLoading());
    apiRepository.login(model).then((value) {
      authBox.put('0', value);

      emit(LoginSuccess(value));
    }).catchError((obj) {
      print(obj);
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(LoginFail(res.toString()));
          break;
        default:
          emit(LoginFail(obj.toString()));
      }
    });
  }

  void dispose() {
    close();
  }
}
