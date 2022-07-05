part of 'get_all_comment_bloc.dart';
enum GetAllCommentStatus { initial, success, failure }

class GetAllCommentState extends Equatable {
  const GetAllCommentState({
    this.status = GetAllCommentStatus.initial,
    this.cmtList = const <GetCommentModel>[],
    this.hasReachedMax = false,
  });

  final GetAllCommentStatus status;
  final List<GetCommentModel> cmtList;
  final bool hasReachedMax;

  GetAllCommentState copyWith({
    GetAllCommentStatus? status,
    List<GetCommentModel>? cmtList,
    bool? hasReachedMax,
  }) {
    return GetAllCommentState(
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
