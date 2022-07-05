part of 'notification_cubit.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationSuccess extends NotificationState {
  final List<NotiModel> notifications;
  NotificationSuccess(this.notifications);

  @override
  List<Object> get props => [notifications];

}

class NotificationFail extends NotificationState {
  final String error;
  NotificationFail(this.error);

  @override
  List<Object> get props => [error];
}
