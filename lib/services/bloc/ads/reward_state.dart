part of 'reward_cubit.dart';

abstract class RewardState extends Equatable {
  const RewardState();

  @override
  List<Object> get props => [];
}

class RewardInitial extends RewardState {}

class RewardLoading extends RewardState {}

class RewardSuccess extends RewardState {}

class RewardFail extends RewardState {
  final String error;
  RewardFail(this.error);
 @override
  List<Object> get props => [error];

}
