part of 'get_user_profile_cubit.dart';

abstract class GetUserProfileState extends Equatable {
  const GetUserProfileState();
  @override
  List<Object> get props => [];
}

class GetUserProfileInitial extends GetUserProfileState {}

class GetUserProfileSuccess extends GetUserProfileState {
  final GetUserModel user;
  GetUserProfileSuccess(this.user);

  @override
  List<Object> get props => [this.user];
}

class GetUserProfileFail extends GetUserProfileState {
  final String error;
  GetUserProfileFail(this.error);

  @override
  List<Object> get props => [this.error];
}

class GetUserProfileLoading extends GetUserProfileState {}