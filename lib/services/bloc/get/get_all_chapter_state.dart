part of 'get_all_chapter_cubit.dart';

abstract class GetAllChapterState extends Equatable {
  const GetAllChapterState();
  @override
  List<Object> get props => [];
}

class GetAllChapterInitial extends GetAllChapterState {}

class GetAllChapterSuccess extends GetAllChapterState {}

class GetAllChapterLoading extends GetAllChapterState {}

class GetAllChapterFail extends GetAllChapterState {
  final String error;
  GetAllChapterFail(this.error);

  @override
  List<Object> get props => [error];
}
