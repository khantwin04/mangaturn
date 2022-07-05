part of 'search_manga_by_name_cubit.dart';

abstract class SearchMangaByNameState extends Equatable {
  const SearchMangaByNameState();
  @override
  List<Object> get props => [];
}

class SearchMangaByNameInitial extends SearchMangaByNameState {}

class SearchMangaByNameLoading extends SearchMangaByNameState {}

class SearchMangaByNameSuccess extends SearchMangaByNameState {

}

class SearchMangaByNameFail extends SearchMangaByNameState {
  final String error;
  SearchMangaByNameFail(this.error);

  @override
  List<Object> get props => [error];
}
