import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/models/comment_model/get_comment_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

part 'get_all_comment_event.dart';
part 'get_all_comment_state.dart';

class GetAllCommentBloc extends Bloc<GetAllCommentEvent, GetAllCommentState> {
  GetAllCommentBloc({required this.apiRepository})
      : super(const GetAllCommentState()) {
    on<GetAllCommentFetched>(_onFetched);
    on<GetAllCommentReload>(_onReload);
  }

  final ApiRepository apiRepository;
  late String token;
  int page = 0;

  set setToken(String data) => token = data;
  set setPage(int data) => page = data;

  Future<void> _onFetched(
      GetAllCommentFetched event, Emitter<GetAllCommentState> emit) async {
    if (state.hasReachedMax) return;
    try {
      final cmtList = await _fetchAllComment(event.mangaId);
      emit(cmtList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetAllCommentStatus.success,
              cmtList: List.of(state.cmtList)..addAll(cmtList),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: GetAllCommentStatus.failure));
    }
  }

  Future<void> _onReload(
      GetAllCommentReload event, Emitter<GetAllCommentState> emit) async {
    try {
      page = 0; // Reset page number for reload
      final cmtList = await _fetchAllComment(event.mangaId);
      emit(state.copyWith(
        status: GetAllCommentStatus.success,
        cmtList: cmtList,
        hasReachedMax: false,
      ));
    } catch (_) {
      emit(state.copyWith(status: GetAllCommentStatus.failure));
    }
  }

  Future<List<GetCommentModel>> _fetchAllComment(int mangaId) async {
    print('Page value $page');
    try {
      List<GetCommentModel> data =
          await apiRepository.getAllCommentByMangaId(mangaId, page++, token);
      return data;
    } catch (e) {
      print('Error fetching comments: $e');
      throw Exception('Failed to fetch comments');
    }
  }
}
