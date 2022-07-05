part of 'get_follow_cubit.dart';

abstract class GetFollowState extends Equatable {
  const GetFollowState();

  @override
  List<Object> get props => [];
}

class GetFollowInitial extends GetFollowState {}

class GetFollowLoading extends GetFollowState {}

class GetFollowSuccess extends GetFollowState {
  final List<FollowModel> followList;
  GetFollowSuccess(this.followList);

  @override
  List<Object> get props => [followList];
}

class GetFollowFail extends GetFollowState {
  final String error;
  GetFollowFail(this.error);

  @override
  List<Object> get props => [error];
}
