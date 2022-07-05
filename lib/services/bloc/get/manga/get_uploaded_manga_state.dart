part of 'get_uploaded_manga_bloc.dart';

enum GetUploadedMangaStatus { initial, success, failure }

class GetUploadedMangaState extends Equatable {
  const GetUploadedMangaState({
    this.status = GetUploadedMangaStatus.initial,
    this.mangaList = const <MangaModel>[],
    this.hasReachedMax = false,
  });

  final GetUploadedMangaStatus status;
  final List<MangaModel> mangaList;
  final bool hasReachedMax;

  GetUploadedMangaState copyWith({
    GetUploadedMangaStatus? status,
    List<MangaModel>? mangaList,
    bool? hasReachedMax,
  }) {
    return GetUploadedMangaState(
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


