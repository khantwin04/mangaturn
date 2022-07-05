import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

part 'get_unread_cmt_count_state.dart';

class GetUnreadCmtCountCubit extends Cubit<GetUnreadCmtCountState> {
  ApiRepository repo;
  GetUnreadCmtCountCubit(this.repo) : super(GetUnreadCmtCountInitial());

  
  set setToken(String data) => token = data;

  late String token;

  void getUnreadCmtCount() {
    emit(GetUnreadCmtCountLoading());
    repo
        .getUnreadCommentCount(token)
        .then((value) => emit(GetUnreadCmtCountSuccess(value)))
        .catchError((e) => emit(GetUnreadCmtCountFail(e.toString())));
  }
}
