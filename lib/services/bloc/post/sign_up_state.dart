part of 'sign_up_cubit.dart';

abstract class SignUpState extends Equatable {
  const SignUpState();
  @override
  List<Object> get props => [];
}

class SignUpInitial extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final AuthResponseModel auth;
  SignUpSuccess(this.auth);

  @override
  List<Object> get props => [auth];

}

class SignUpLoading extends SignUpState {}

class SignUpFail extends SignUpState {
  final String error;
  SignUpFail(this.error);

  @override
  List<Object> get props => [error];
}
