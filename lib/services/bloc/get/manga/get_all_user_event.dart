part of 'get_all_user_bloc.dart';

abstract class GetAllUserEvent extends Equatable {
  const GetAllUserEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetAllUserFetched extends GetAllUserEvent {}

class GetAllUserReload extends GetAllUserEvent {}