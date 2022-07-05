part of 'edit_characters_cubit.dart';

abstract class EditCharactersState extends Equatable {
  const EditCharactersState();

  @override
  List<Object> get props => [];
}

class EditCharactersInitial extends EditCharactersState {}

class EditCharactersLoading extends EditCharactersState {}

class EditCharactersSuccess extends EditCharactersState {}

class EditCharactersFail extends EditCharactersState {
  final String error;
  EditCharactersFail(this.error);

    @override
  List<Object> get props => [this.error];
}
