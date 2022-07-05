import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/firestore_models/payload.dart';
import 'package:mangaturn/models/manga_models/manga_user_model.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/models/user_models/point_purchase_model.dart';
import 'package:mangaturn/models/user_models/requestPointModel.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

part 'buy_point_state.dart';

class BuyPointCubit extends Cubit<BuyPointState> {
  final ApiRepository apiRepository;
  BuyPointCubit({required this.apiRepository}) : super(BuyPointInitial());

  late String token;

  set setToken(data) => token = data;

  void submit(RequestPointModel model, GetUserModel user) {
    emit(BuyPointLoading());
    apiRepository.requestPointPurchase(model, token).then((value) {
      PayloadNotification notification = PayloadNotification(
        title: 'Filling point to account',
        body: 'From ${user.username}',
        sound: 'default',
        image: '',
      );

      PayloadData data = PayloadData(
        click_action: "FLUTTER_NOTIFICATION_CLICK",
        mangaId: user.id.toString(),
        mangaName: user.username,
        mangaCover: user.profileUrl ?? '',
      );

      Payload payload = Payload(
        to: '/topics/pointRequest',
        priority: "high",
        notification: notification,
        data: data,
      );
      apiRepository.sendNotification(payload).then((value) {
        emit(BuyPointSuccess());
      });
    }).catchError((obj) {
      print(obj.toString());
      switch (obj.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (obj as DioError).response;
          emit(BuyPointFail(res.toString()));
          break;
        default:
      }
    });
  }
}
