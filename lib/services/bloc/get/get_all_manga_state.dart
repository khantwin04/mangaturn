part of 'get_all_manga_cubit.dart';

abstract class GetAllMangaState extends Equatable {
  const GetAllMangaState();
  @override
  List<Object> get props => [];
}

class GetAllMangaInitial extends GetAllMangaState {}

class GetAllMangaSuccess extends GetAllMangaState {
  final List<MangaModel> mangaList;
  GetAllMangaSuccess(this.mangaList);

  @override
  List<Object> get props => [this.mangaList];

}

class GetAllMangaLoading extends GetAllMangaState {}

class GetAllMangaFail extends GetAllMangaState {
  final String error;
  GetAllMangaFail(this.error);

  @override
  List<Object> get props => [error];
}
