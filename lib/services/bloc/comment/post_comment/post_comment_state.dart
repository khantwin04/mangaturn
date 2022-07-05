part of 'post_comment_cubit.dart';

abstract class PostCommentState extends Equatable {
  const PostCommentState();

  @override
  List<Object> get props => [];
}

class PostCommentInitial extends PostCommentState {}

class PostCommentLoading extends PostCommentState {}

class PostCommentSuccess extends PostCommentState {
  final String success;
  PostCommentSuccess(this.success);

  @override
  List<Object> get props => [success];
}

class PostCommentFail extends PostCommentState {
  final String error;
  PostCommentFail(this.error);

  @override
  List<Object> get props => [error];
}
