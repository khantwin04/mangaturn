import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'get_all_user_event.dart';
part 'get_all_user_state.dart';

class GetAllUserBloc extends Bloc<GetAllUserEvent, GetAllUserState> {
  GetAllUserBloc({required this.apiRepository})
      : super(const GetAllUserState()) {
    on<GetAllUserFetched>(_onFetched);
    on<GetAllUserReload>(_onReload);
  }

  final ApiRepository apiRepository;
  late String token;
  int page = 0;

  void _onFetched(
      GetAllUserFetched event, Emitter<GetAllUserState> emit) async {
    if (state.hasReachedMax) return;
    try {
      final userList = await _fetchAllUser();
      emit(userList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetAllUserStatus.success,
              userList: List.of(state.userList)..addAll(userList),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: GetAllUserStatus.failure));
    }
  }

  void _onReload(GetAllUserReload event, Emitter<GetAllUserState> emit) async {
    try {
      page = 0; // Reset page number for reload
      final userList = await _fetchAllUser();
      emit(state.copyWith(
        status: GetAllUserStatus.success,
        userList: userList,
        hasReachedMax: false,
      ));
    } catch (_) {
      emit(state.copyWith(status: GetAllUserStatus.failure));
    }
  }

  Future<List<GetUserModel>> _fetchAllUser() async {
    print('Page value $page');
    final List<GetUserModel> data =
        await apiRepository.getAllAdmin(page++, token);
    return data;
  }

  set setToken(String data) => token = data;
  set setPage(int data) => page = data;
}
