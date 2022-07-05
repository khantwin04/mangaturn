import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:rxdart/rxdart.dart';
part 'get_all_user_event.dart';
part 'get_all_user_state.dart';

class GetAllUserBloc extends Bloc<GetAllUserEvent, GetAllUserState> {
  GetAllUserBloc({required this.apiRepository}) : super(const GetAllUserState());

  final ApiRepository apiRepository;

  set setToken(String data) => token = data;

  late String token;

  @override
  Stream<Transition<GetAllUserEvent, GetAllUserState>> transformEvents(
      Stream<GetAllUserEvent> events,
      TransitionFunction<GetAllUserEvent, GetAllUserState> transitionFn,
      ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<GetAllUserState> mapEventToState(GetAllUserEvent event) async* {
    if (event is GetAllUserFetched) {
      yield await _mapUserToState(state);
    }else if (event is GetAllUserReload) {
      yield await _mapUserToState(state.copyWith(
          userList: [],
          hasReachedMax: false,
          status: GetAllUserStatus.initial));
    }
  }

  Future<GetAllUserState> _mapUserToState(GetAllUserState state) async {
    if (state.hasReachedMax) return state;
    try {
      if (state.status == GetAllUserStatus.initial) {
        final userList = await _fetchAllUser();
        return state.copyWith(
          status: GetAllUserStatus.success,
          userList: userList,
          hasReachedMax: false,
        );
      }
      final userList = await _fetchAllUser();
      return userList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
        status: GetAllUserStatus.success,
        userList: List.of(state.userList)..addAll(userList),
        hasReachedMax: false,
      );
    } on Exception {
      return state.copyWith(status: GetAllUserStatus.failure);
    }
  }

  set setPage(data) => page = data;

  int page = 0;

  Future<List<GetUserModel>> _fetchAllUser() async {
    print('Page value $page');
    List<GetUserModel> data = await apiRepository.getAllAdmin(page++, token);
    List<GetUserModel> userList = data;
    return userList;

  }
}
