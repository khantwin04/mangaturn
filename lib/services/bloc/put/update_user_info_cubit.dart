import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/user_models/update_userInfo_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'update_user_info_state.dart';

class UpdateUserInfoCubit extends Cubit<UpdateUserInfoState> {
  ApiRepository apiRepository;

  UpdateUserInfoCubit({required this.apiRepository}) : super(UpdateUserInfoInitial());


  set setToken(String data) => token = data;

  late String token;

  void updateInfo(UpdateUserInfoModel update){
    emit(UpdateUserInfoLoading());
    apiRepository.userUpdate(update, token)
    .then((value) {
      emit(UpdateUserInfoSuccess());
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(UpdateUserInfoFail(json.decode(res.toString())['message']));
          break;
        default:
      }
    });

  }

  void updateUserPassword(UpdateUserPassword pwd){
    emit(UpdateUserInfoLoading());
    apiRepository.userPasswordUpdate(pwd, token)
        .then((value) {
      emit(UpdateUserInfoSuccess());
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(UpdateUserInfoFail(json.decode(res.toString())['message']));
          break;
        default:
      }
    });

  }

}
