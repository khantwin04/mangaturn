import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/firestore_models/noti_model.dart';
import 'package:mangaturn/services/firestore_db.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  FirestoreDB db;

  NotificationCubit({required this.db}) : super(NotificationInitial()) {
    getAllReaderNotification();
  }

  int numberOfNotification = 0;

  int get getNoOfNotification => numberOfNotification;

  void saveNotification(NotiModel model) {
    emit(NotificationLoading());
    db.saveNotification(model).then((value) => getAllReaderNotification());
  }

  void updateNotification(NotiModel model) {
    emit(NotificationLoading());
    db
        .updateNotificationById(model.id!, model)
        .then((value) => getAllReaderNotification());
  }

  void deleteNotificationById(int notificationId) {
    emit(NotificationLoading());
    db.deleteNotificationById(notificationId).then((value) {
      getAllReaderNotification();
    });
  }

  void deleteAllNotification() {
    emit(NotificationLoading());
    db.deleteAllNotification().then((value) => getAllReaderNotification());
  }

  void getAllReaderNotification() {
    numberOfNotification = 0;
    emit(NotificationLoading());
    db.getAllNotification().then((value) {
      for (int i = 0; i < value.length; i++) {
        if (value[i].see == 'false') ++numberOfNotification;
      }
      emit(NotificationSuccess(value));
    }).catchError((e) => emit(NotificationFail(e.toString())));
  }
}
