part of 'get_fav_manga_bloc.dart';

enum GetFavMangaStatus { initial, success, failure }

class GetFavMangaState extends Equatable {
  const GetFavMangaState({
    this.status = GetFavMangaStatus.initial,
    this.mangaList = const <MangaModel>[],
    this.hasReachedMax = false,
  });

  final GetFavMangaStatus status;
  final List<MangaModel> mangaList;
  final bool hasReachedMax;

  GetFavMangaState copyWith({
    GetFavMangaStatus? status,
    List<MangaModel>? mangaList,
    bool? hasReachedMax,
  }) {
    return GetFavMangaState(
      status: status ?? this.status,
      mangaList: mangaList ?? this.mangaList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''MangaState { status: $status, hasReachedMax: $hasReachedMax, posts: ${mangaList.length} }''';
  }

  @override
  List<Object> get props => [status, mangaList, hasReachedMax];
}
