part of 'edit_chapter_cubit.dart';

abstract class EditChapterState extends Equatable {
  const EditChapterState();

  @override
  List<Object> get props => [];
}

class EditChapterInitial extends EditChapterState {}

class EditChapterLoading extends EditChapterState {}

class EditChapterSuccess extends EditChapterState {
  final ChapterModel chapterModel;
  EditChapterSuccess(this.chapterModel);
  @override
  List<Object> get props => [chapterModel];
}

class EditChapterFail extends EditChapterState {
  final String error;
  EditChapterFail(this.error);

  @override
  List<Object> get props => [this.error];

}
