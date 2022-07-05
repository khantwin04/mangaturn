part of 'get_all_comment_bloc.dart';

abstract class GetAllCommentEvent extends Equatable {
  const GetAllCommentEvent();

  @override
  List<Object> get props => [];
}

class GetAllCommentFetched extends GetAllCommentEvent {
  final int mangaId;
  GetAllCommentFetched(this.mangaId);

  @override
  List<Object> get props => [mangaId];
}

class GetAllCommentReload extends GetAllCommentEvent {
  final int mangaId;
  GetAllCommentReload(this.mangaId);

  @override
  List<Object> get props => [mangaId];
}
