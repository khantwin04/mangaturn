part of 'get_manga_by_update_bloc.dart';

abstract class GetMangaByUpdateEvent extends Equatable {
  const GetMangaByUpdateEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetMangaByUpdateFetched extends GetMangaByUpdateEvent {}

class GetMangaByUpdateReload extends GetMangaByUpdateEvent {}
