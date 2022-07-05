part of 'get_unread_cmt_count_cubit.dart';

abstract class GetUnreadCmtCountState extends Equatable {
  const GetUnreadCmtCountState();

  @override
  List<Object> get props => [];
}

class GetUnreadCmtCountInitial extends GetUnreadCmtCountState {}

class GetUnreadCmtCountLoading extends GetUnreadCmtCountState {}

class GetUnreadCmtCountSuccess extends GetUnreadCmtCountState {
  final String count;
  GetUnreadCmtCountSuccess(this.count);

  @override
  List<Object> get props => [count];
}

class GetUnreadCmtCountFail extends GetUnreadCmtCountState {
  final String error;
  GetUnreadCmtCountFail(this.error);

  @override
  List<Object> get props => [error];
}
