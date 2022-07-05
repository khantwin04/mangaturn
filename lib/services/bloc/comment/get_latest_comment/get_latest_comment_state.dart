part of 'get_lastest_comment_cubit.dart';

abstract class GetLastetCommentState extends Equatable {
  const GetLastetCommentState();

  @override
  List<Object> get props => [];
}

class GetLastetCommentInitial extends GetLastetCommentState {}

class GetLastetCommentLoading extends GetLastetCommentState {}

class GetLastetCommentSuccess extends GetLastetCommentState {
  final List<GetCommentModel> cmtList;
  GetLastetCommentSuccess(this.cmtList);

  @override
  List<Object> get props => [cmtList];
}

class GetLastetCommentFail extends GetLastetCommentState {
  final String error;
  GetLastetCommentFail(this.error);

  @override
  List<Object> get props => [error];
}
