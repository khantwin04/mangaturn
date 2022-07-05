part of 'update_user_info_cubit.dart';

abstract class UpdateUserInfoState extends Equatable {
  const UpdateUserInfoState();
  @override
  List<Object> get props => [];

}

class UpdateUserInfoInitial extends UpdateUserInfoState {}

class UpdateUserInfoSuccess extends UpdateUserInfoState {}

class UpdateUserInfoLoading extends UpdateUserInfoState {}

class UpdateUserInfoFail extends UpdateUserInfoState {
  final String error;
  UpdateUserInfoFail(this.error);

  @override
  List<Object> get props => [error];

}
