part of 'get_manga_by_name_bloc.dart';

abstract class GetMangaByNameEvent extends Equatable {
  const GetMangaByNameEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetMangaByNameFetched extends GetMangaByNameEvent {}

class GetMangaByNameReload extends GetMangaByNameEvent {}
