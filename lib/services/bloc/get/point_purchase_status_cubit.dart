import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/user_models/point_purchase_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

part 'point_purchase_status_state.dart';

class PointPurchaseStatusCubit extends Cubit<PointPurchaseStatusState> {
  PointPurchaseStatusCubit(this.apiRepository)
      : super(PointPurchaseStatusInitial());
  ApiRepository apiRepository;

  late String token;

  set setToken(String data) => token = data;

  void getLatestPurchaseStatus() {
    emit(PointPurchaseStatusLoading());
    apiRepository.getPointPurchaseList(token, 0, 1).then((value) {
      if (value.isEmpty) {
        emit(PointPurchaseStatusSuccess(null));
      }else{
emit(PointPurchaseStatusSuccess(value[0]));
      }
    }).catchError((e) {
      emit(PointPurchaseStatusFail(e.toString()));
    });
  }
}
