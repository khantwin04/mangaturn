part of 'free_point_cubit.dart';

abstract class FreePointState extends Equatable {
  const FreePointState();

  @override
  List<Object> get props => [];
}

class FreePointInitial extends FreePointState {}

class FreePointLoading extends FreePointState {}

class FreePointSuccess extends FreePointState {}

class FreePointFail extends FreePointState {
  final String error;
  FreePointFail(this.error);
 @override
  List<Object> get props => [error];

}
