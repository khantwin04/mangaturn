part of 'version_cubit.dart';

abstract class VersionState extends Equatable {
  const VersionState();

  @override
  List<Object> get props => [];
}

class VersionInitial extends VersionState {}

class VersionSuccess extends VersionState {
  final VersionModel version;
  VersionSuccess(this.version);

  @override
  List<Object> get props => [version];
}

class VersionLoading extends VersionState {}

class VersionFail extends VersionState {}
