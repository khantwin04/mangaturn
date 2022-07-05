part of 'get_recommend_manga_cubit.dart';

abstract class GetRecommendMangaState extends Equatable {
  const GetRecommendMangaState();

  @override
  List<Object> get props => [];
}

class GetRecommendMangaInitial extends GetRecommendMangaState {}

class GetRecommendMangaLoading extends GetRecommendMangaState {}

class GetRecommendMangaSuccess extends GetRecommendMangaState {
  List<MangaModel> mangaList;
  GetRecommendMangaSuccess(this.mangaList);

    @override
  List<Object> get props => [mangaList];
}

class GetRecommendMangaFail extends GetRecommendMangaState {
  String error;
  GetRecommendMangaFail(this.error);

  @override
  List<Object> get props => [error];
}
