part of 'get_fav_manga_bloc.dart';

abstract class GetFavMangaEvent extends Equatable {
  const GetFavMangaEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetFavMangaFetched extends GetFavMangaEvent {}

class GetFavMangaReload extends GetFavMangaEvent {}