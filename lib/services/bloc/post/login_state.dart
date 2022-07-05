part of 'login_cubit.dart';

abstract class LoginState extends Equatable {
  const LoginState();
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginSuccess extends LoginState {
  final AuthResponseModel auth;
  LoginSuccess(this.auth);

  @override
  List<Object> get props => [auth];
}

class LoginLoading extends LoginState {}

class LoginFail extends LoginState {
  final String error;
  LoginFail(this.error);

  @override
  List<Object> get props => [error];
}
