part of 'get_recent_chapter_cubit.dart';

abstract class GetRecentChapterState extends Equatable {
  const GetRecentChapterState();
  @override
  List<Object> get props => [];
}

class GetRecentChapterInitial extends GetRecentChapterState {}

class GetRecentChapterLoading extends GetRecentChapterState {}

class GetRecentChapterSuccess extends GetRecentChapterState {
  final List<RecentChapterModel> recentList;
  GetRecentChapterSuccess(this.recentList);

  @override
  List<Object> get props => [recentList];
}

class GetRecentChapterFail extends GetRecentChapterState {
  final String error;
  GetRecentChapterFail(this.error);

  @override
  List<Object> get props => [error];
}
