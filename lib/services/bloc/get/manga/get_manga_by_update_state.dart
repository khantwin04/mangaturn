part of 'get_manga_by_update_bloc.dart';

enum GetMangaByUpdateStatus { initial, success, failure }

class GetMangaByUpdateState extends Equatable {
  const GetMangaByUpdateState({
    this.status = GetMangaByUpdateStatus.initial,
    this.mangaList = const <MangaModel>[],
    this.hasReachedMax = false,
  });

  final GetMangaByUpdateStatus status;
  final List<MangaModel> mangaList;
  final bool hasReachedMax;

  GetMangaByUpdateState copyWith({
    GetMangaByUpdateStatus? status,
    List<MangaModel>? mangaList,
    bool? hasReachedMax,
  }) {
    return GetMangaByUpdateState(
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

