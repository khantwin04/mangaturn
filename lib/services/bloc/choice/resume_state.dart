part of 'resume_cubit.dart';

abstract class ResumeState extends Equatable {
  const ResumeState();

  @override
  List<Object> get props => [];
}

class ResumeInitial extends ResumeState {}

class ResumeLoading extends ResumeState {}

class ResumeSuccess extends ResumeState {
  final Map<String, ResumeModel> resumeList;
  ResumeSuccess(this.resumeList);
  @override
  List<Object> get props => [resumeList];
}

class ResumeFail extends ResumeState {
  final String error;
  ResumeFail(this.error);
  @override
  List<Object> get props => [error];
}
