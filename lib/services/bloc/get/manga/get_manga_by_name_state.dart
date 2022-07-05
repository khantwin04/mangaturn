part of 'get_manga_by_name_bloc.dart';

enum GetMangaByNameStatus { initial, success, failure }

class GetMangaByNameState extends Equatable {
  const GetMangaByNameState({
    this.status = GetMangaByNameStatus.initial,
    this.mangaList = const <MangaModel>[],
    this.hasReachedMax = false,
  });

  final GetMangaByNameStatus status;
  final List<MangaModel> mangaList;
  final bool hasReachedMax;

  GetMangaByNameState copyWith({
    GetMangaByNameStatus? status,
    List<MangaModel>? mangaList,
    bool? hasReachedMax,
  }) {
    return GetMangaByNameState(
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
