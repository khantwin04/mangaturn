part of 'download_cubit.dart';

abstract class DownloadState extends Equatable {
  const DownloadState();
  @override
  List<Object> get props => [];
}

class DownloadInitial extends DownloadState {}

class DownloadLoading extends DownloadState {
  final String downloadingChapter;
  final int totalPage;
  DownloadLoading(this.downloadingChapter, this.totalPage);

  @override
  List<Object> get props => [this.downloadingChapter, totalPage];

}


class DownloadFail extends DownloadState {
  final String error;
  final String downloadingChapter;
  DownloadFail(this.error, this.downloadingChapter);

  @override
  List<Object> get props => [error, downloadingChapter];
}

class DownloadProgress extends DownloadState {
  final int progress;
  final String downloadingChapter;
  final int totalPages;
  DownloadProgress(this.progress, this.downloadingChapter, this.totalPages);

  @override
  List<Object> get props => [progress, downloadingChapter, totalPages];
}

class DownloadSuccess extends DownloadState {
  final String downloadingChapter;
  final int chapterId;
  final String mangaName;
  final int mangaId;
  final List<DownloadPage> pages;
  DownloadSuccess(this.downloadingChapter, this.chapterId, this.mangaName, this.mangaId, this.pages);

  @override
  List<Object> get props => [downloadingChapter];
}
