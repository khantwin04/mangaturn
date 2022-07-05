import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/config/constants.dart';
import 'package:mangaturn/models/version_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

part 'version_state.dart';

class VersionCubit extends Cubit<VersionState> {
  ApiRepository apiRepository;
  VersionCubit({required this.apiRepository}) : super(VersionInitial());

  set setToken(String data) => token = data;

  late String token;

  void checkVersion() {
    emit(VersionLoading());
    apiRepository.checkVersion(Constant.versionNumber, token).then((value) {
      print(value.appLink);
      print(value.isForce);
      print(value.update);
      emit(VersionSuccess(value));
    }).catchError((e) {
      print(e.toString());
      emit(VersionFail());
    });
  }
}
