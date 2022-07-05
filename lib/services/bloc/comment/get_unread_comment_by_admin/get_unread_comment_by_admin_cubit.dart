import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/comment_model/get_unread_comment_by_admin.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

part 'get_unread_comment_by_admin_state.dart';

class GetUnreadCommentByAdminCubit extends Cubit<GetUnreadCommentByAdminState> {
  final ApiRepository repo;
  GetUnreadCommentByAdminCubit(this.repo)
      : super(GetUnreadCommentByAdminInitial());

  late String token;

  set setToken(String data) => token = data;

  void getUnreadCommentByAdmin() {
    emit(GetUnreadCommentByAdminLoading());
    repo
        .getUnreadCommentByAdmin(token)
        .then((value) => emit(GetUnreadCommentByAdminSuccess(value)))
        .catchError((e) => emit(GetUnreadCommentByAdminFail(e.toString())));
  }
}
