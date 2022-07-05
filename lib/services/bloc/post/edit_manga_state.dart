part of 'edit_manga_cubit.dart';

abstract class EditMangaState extends Equatable {
  const EditMangaState();

  @override
  List<Object> get props => [];
}

class EditMangaInitial extends EditMangaState {}

class EditMangaLoading extends EditMangaState {}

class EditMangaSuccess extends EditMangaState {
  final int id;
  final String name;
  final String cover;
  final String description;

  EditMangaSuccess(this.id, this.name, this.cover, this.description);

  @override
  List<Object> get props => [id, name, cover, description];
}

class EditMangaFail extends EditMangaState {
  final String error;

  EditMangaFail(this.error);

  @override
  List<Object> get props => [error];
}
