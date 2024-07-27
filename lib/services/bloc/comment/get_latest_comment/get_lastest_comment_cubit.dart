import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/comment_model/get_comment_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

part 'get_latest_comment_state.dart';

class GetLastetCommentCubit extends Cubit<GetLastetCommentState> {
  final ApiRepository repo;
  GetLastetCommentCubit(this.repo) : super(GetLastetCommentInitial());

  set setToken(String data) => token = data;

  String? token;

  void getLastetComment(int mangaId) {
    emit(GetLastetCommentLoading());
    repo
        .getLastCommentByMangaId(mangaId, 0, token!)
        .then((value) => emit(GetLastetCommentSuccess(value)))
        .catchError((e) => emit(GetLastetCommentFail(e.toString())));
  }
}
