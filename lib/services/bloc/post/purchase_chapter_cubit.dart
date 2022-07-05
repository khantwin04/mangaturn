import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'purchase_chapter_state.dart';

class PurchaseChapterCubit extends Cubit<PurchaseChapterState> {
  ApiRepository apiRepository;

  PurchaseChapterCubit({required this.apiRepository}) : super(PurchaseChapterInitial());

  set setToken(String data) => token = data;

  late String token;

  void purchaseChapter(int chapterId, BuildContext context){
    emit(PurchaseChapterLoading());
    apiRepository.purchaseChapter(chapterId, token)
    .then((value){
      BlocProvider.of<
          GetLatestChaptersCubit>(
          context,
          listen: false)
          .getLatestChapters();
      emit(PurchaseChapterSuccess());
    }).catchError((obj) {
      switch (obj.runtimeType) {
        case DioError:
        // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          String message =json.decode(res.toString())['message'];
          emit(PurchaseChapterFail(message));
          break;
        default:
      }
    });
  }
}
