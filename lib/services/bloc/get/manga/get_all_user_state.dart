part of 'get_all_user_bloc.dart';

enum GetAllUserStatus { initial, success, failure }

class GetAllUserState extends Equatable {
  const GetAllUserState({
    this.status = GetAllUserStatus.initial,
    this.userList = const <GetUserModel>[],
    this.hasReachedMax = false,
  });

  final GetAllUserStatus status;
  final List<GetUserModel> userList;
  final bool hasReachedMax;

  GetAllUserState copyWith({
    GetAllUserStatus? status,
    List<GetUserModel>? userList,
    bool? hasReachedMax,
  }) {
    return GetAllUserState(
      status: status ?? this.status,
      userList: userList ?? this.userList,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  String toString() {
    return '''UserState { status: $status, hasReachedMax: $hasReachedMax, posts: ${userList.length} }''';
  }

  @override
  List<Object> get props => [status, userList, hasReachedMax];
}
