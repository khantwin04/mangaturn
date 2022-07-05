import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/services/bloc/get/manga/get_uploaded_manga_bloc.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

part 'get_user_profile_state.dart';

class GetUserProfileCubit extends Cubit<GetUserProfileState> {
  ApiRepository apiRepository;

  GetUserProfileCubit({required this.apiRepository})
      : super(GetUserProfileInitial());

  set setToken(String data) => token = data;

  int? userId;
  late String token;
  late int point;

  set setPoint(int data) => point = data;

  int get getUserId => userId!;

  int get getPoint => point;

  void getUserProfile() {
    emit(GetUserProfileLoading());
    apiRepository.getUserProfile(token).then((value) {
      setPoint = value.point;
      Utility.registerOnFirebase(value.id.toString());
      emit(GetUserProfileSuccess(value));
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(GetUserProfileFail(res.toString()));
          break;
        default:
      }
    });
  }
}
