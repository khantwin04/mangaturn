part of 'get_latest_chapters_cubit.dart';

abstract class GetLatestChaptersState extends Equatable {
  const GetLatestChaptersState();
  @override
  List<Object> get props => [];
}

class GetLatestChaptersInitial extends GetLatestChaptersState {}

class GetLatestChapterSuccess extends GetLatestChaptersState {
  final List<LatestChapterModel> chapters;
  GetLatestChapterSuccess(this.chapters);
  @override
  List<Object> get props => [chapters];
}

class GetLatestChapterLoading extends GetLatestChaptersState {}

class GetLatestChapterFail extends GetLatestChaptersState {
  final String error;
  GetLatestChapterFail(this.error);

  @override
  List<Object> get props => [this.error];
}
