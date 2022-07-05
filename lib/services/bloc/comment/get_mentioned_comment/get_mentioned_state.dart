part of 'get_mentioned_bloc.dart';
enum GetMentionedCommentStatus { initial, success, failure }

class GetMentionedCommentState extends Equatable {
  const GetMentionedCommentState({
    this.status = GetMentionedCommentStatus.initial,
    this.cmtList = const <GetCommentModel>[],
    this.hasReachedMax = false,
  });

  final GetMentionedCommentStatus status;
  final List<GetCommentModel> cmtList;
  final bool hasReachedMax;

  GetMentionedCommentState copyWith({
    GetMentionedCommentStatus? status,
    List<GetCommentModel>? cmtList,
    bool? hasReachedMax,
  }) {
    return GetMentionedCommentState(
      status: status ?? this.status,
      cmtList: cmtList ?? this.cmtList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''UserState { status: $status, hasReachedMax: $hasReachedMax, posts: ${cmtList.length} }''';
  }

  @override
  List<Object> get props => [status, cmtList, hasReachedMax];
}
