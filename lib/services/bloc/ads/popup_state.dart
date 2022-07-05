part of 'popup_cubit.dart';

abstract class PopupState extends Equatable {
  const PopupState();

  @override
  List<Object> get props => [];
}

class PopupInitial extends PopupState {}

class PopUpLoading extends PopupState {}

class PopUpSuccess extends PopupState {}

class PopUpFail extends PopupState {
}
