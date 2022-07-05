import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/comment_model/get_comment_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:rxdart/rxdart.dart';
part 'get_all_comment_event.dart';
part 'get_all_comment_state.dart';

class GetAllCommentBloc extends Bloc<GetAllCommentEvent, GetAllCommentState> {
  GetAllCommentBloc({required this.apiRepository})
      : super(const GetAllCommentState());

  final ApiRepository apiRepository;

  set setToken(String data) => token = data;

  late String token;

  @override
  Stream<Transition<GetAllCommentEvent, GetAllCommentState>> transformEvents(
    Stream<GetAllCommentEvent> events,
    TransitionFunction<GetAllCommentEvent, GetAllCommentState> transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<GetAllCommentState> mapEventToState(GetAllCommentEvent event) async* {
    if (event is GetAllCommentFetched) {
      yield await _mapUserToState(state, event.mangaId);
    } else if (event is GetAllCommentReload) {
      yield await _mapUserToState(state.copyWith(
          cmtList: [],
          hasReachedMax: false,
          status: GetAllCommentStatus.initial),
          event.mangaId);
    }
  }

  Future<GetAllCommentState> _mapUserToState(GetAllCommentState state, int mangaId) async {
    if (state.hasReachedMax) return state;
    try {
      if (state.status == GetAllCommentStatus.initial) {
        final cmtList = await _fetchAllComment(mangaId);
        return state.copyWith(
          status: GetAllCommentStatus.success,
          cmtList: cmtList,
          hasReachedMax: false,
        );
      }
      final cmtList = await _fetchAllComment(mangaId);
      return cmtList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetAllCommentStatus.success,
              cmtList: List.of(state.cmtList)..addAll(cmtList),
              hasReachedMax: false,
            );
    } on Exception {
      return state.copyWith(status: GetAllCommentStatus.failure);
    }
  }

  set setPage(data) => page = data;

  int page = 0;

  Future<List<GetCommentModel>> _fetchAllComment(int mangaId) async {
    print('Page value $page');
    List<GetCommentModel> data =
        await apiRepository.getAllCommentByMangaId(mangaId, page++, token);
    List<GetCommentModel> cmtList = data;
    return cmtList;
  }
}
