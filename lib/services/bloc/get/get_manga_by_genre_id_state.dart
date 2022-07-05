part of 'get_manga_by_genre_id_cubit.dart';

abstract class GetMangaByGenreIdState extends Equatable {
  const GetMangaByGenreIdState();
  @override
  List<Object> get props => [];
}

class GetMangaByGenreIdInitial extends GetMangaByGenreIdState {}

class GetMangaByGenreIdLoading extends GetMangaByGenreIdState {}

class GetMangaByGenreIdSuccess extends GetMangaByGenreIdState {
  final List<MangaModel> data;
  GetMangaByGenreIdSuccess(this.data);

  @override
  List<Object> get props => [data];
}

class GetMangaByGenreIdFail extends GetMangaByGenreIdState {
  final String error;
  GetMangaByGenreIdFail(this.error);

  @override
  List<Object> get props => [error];
}