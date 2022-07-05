part of 'get_download_manga_cubit.dart';

abstract class GetDownloadMangaState extends Equatable {
  const GetDownloadMangaState();
  @override
  List<Object> get props => [];
}

class GetDownloadMangaInitial extends GetDownloadMangaState {}

class GetDownloadMangaLoading extends GetDownloadMangaState {}

class GetDownloadMangaSuccess extends GetDownloadMangaState {
  List<DownloadManga> manga;
  GetDownloadMangaSuccess(this.manga);

  @override
  List<Object> get props => [manga];
}

class GetDownloadMangaFail extends GetDownloadMangaState {
  final String error;
  GetDownloadMangaFail(this.error);

  @override
  List<Object> get props => [error];
}