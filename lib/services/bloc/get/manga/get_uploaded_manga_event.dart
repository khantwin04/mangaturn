part of 'get_uploaded_manga_bloc.dart';

abstract class GetUploadedMangaEvent extends Equatable {
  const GetUploadedMangaEvent();
  @override
  // TODO: implement props
  List<Object> get props => [];
}

class GetUploadedMangaFetched extends GetUploadedMangaEvent {
}

class GetUploadedMangaReload extends GetUploadedMangaEvent {
}
