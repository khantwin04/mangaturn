part of 'get_mentioned_bloc.dart';

abstract class GetMentionedCommentEvent extends Equatable {
  const GetMentionedCommentEvent();

  @override
  List<Object> get props => [];
}

class GetMentionedCommentFetched extends GetMentionedCommentEvent {
}

class GetMentionedCommentReload extends GetMentionedCommentEvent {
}
