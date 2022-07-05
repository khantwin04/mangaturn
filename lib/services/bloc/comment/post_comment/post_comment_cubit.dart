import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/comment_model/post_comment_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
part 'post_comment_state.dart';

class PostCommentCubit extends Cubit<PostCommentState> {
  final ApiRepository repo;
  PostCommentCubit(this.repo) : super(PostCommentInitial());

  late String token;
  set setToken(String data) => token = data;

  void postComment(PostCommentModel commentModel) {
    emit(PostCommentLoading());
    repo
        .postComment(commentModel, token)
        .then((value) => emit(PostCommentSuccess(value)))
        .catchError((e) {
      switch (e.runtimeType) {
        case DioError:
          // Here's the sample to get the failed response error code and message
          final res = (e as DioError).response;
          emit(PostCommentFail(res.toString()));
          break;
        default:
          emit(PostCommentFail(e.toString()));
      }
    });
  }
}
