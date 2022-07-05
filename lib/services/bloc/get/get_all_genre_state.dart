part of 'get_all_genre_cubit.dart';

abstract class GetAllGenreState extends Equatable {
  const GetAllGenreState();
  @override
  List<Object> get props => [];
}

class GetAllGenreInitial extends GetAllGenreState {}

class GetAllGenreLoading extends GetAllGenreState {}

class GetAllGenreSuccess extends GetAllGenreState {
  final List<GenreModel> genreList;
  GetAllGenreSuccess(this.genreList);

  @override
  List<Object> get props => [genreList];
}

class GetAllGenreFail extends GetAllGenreState {
  final String error;
  GetAllGenreFail(this.error);

  @override
  List<Object> get props => [error];
}
