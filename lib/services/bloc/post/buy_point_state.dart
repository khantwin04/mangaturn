part of 'buy_point_cubit.dart';

abstract class BuyPointState extends Equatable {
  const BuyPointState();
  @override
  List<Object> get props => [];
}

class BuyPointInitial extends BuyPointState {}

class BuyPointLoading extends BuyPointState {}

class BuyPointSuccess extends BuyPointState {}

class BuyPointFail extends BuyPointState {
  final String error;
  BuyPointFail(this.error);

  @override
  List<Object> get props => [error];
}
