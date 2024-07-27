import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/config/local_storage.dart';
import 'package:mangaturn/models/comment_model/get_comment_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:rxdart/rxdart.dart';

part 'get_mentioned_event.dart';
part 'get_mentioned_state.dart';

class GetMentionedCommentBloc
    extends Bloc<GetMentionedCommentEvent, GetMentionedCommentState> {
  GetMentionedCommentBloc({required this.apiRepository})
      : super(const GetMentionedCommentState()) {
    on<GetMentionedCommentFetched>(_onFetched);
    on<GetMentionedCommentReload>(_onReload);
  }

  final ApiRepository apiRepository;
  late String token;
  int page = 0;

  set setToken(String data) => token = data;
  set setPage(int data) => page = data;

  Future<void> _onFetched(GetMentionedCommentFetched event,
      Emitter<GetMentionedCommentState> emit) async {
    if (state.hasReachedMax) return;
    try {
      final cmtList = await _fetchMentionedComment();
      emit(cmtList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetMentionedCommentStatus.success,
              cmtList: List.of(state.cmtList)..addAll(cmtList),
              hasReachedMax: false,
            ));
    } catch (_) {
      emit(state.copyWith(status: GetMentionedCommentStatus.failure));
    }
  }

  Future<void> _onReload(GetMentionedCommentReload event,
      Emitter<GetMentionedCommentState> emit) async {
    try {
      page = 0; // Reset page number for reload
      final cmtList = await _fetchMentionedComment();
      emit(state.copyWith(
        status: GetMentionedCommentStatus.success,
        cmtList: cmtList,
        hasReachedMax: false,
      ));
    } catch (_) {
      emit(state.copyWith(status: GetMentionedCommentStatus.failure));
    }
  }

  Future<List<GetCommentModel>> _fetchMentionedComment() async {
    print('Page value $page');
    List<GetCommentModel> data =
        await apiRepository.getMentionedComments(page++, token);
    List<GetCommentModel> cmtList = [];
    for (int i = 0; i < data.length; i++) {
      if (await LocalStorage.getRepliedCmt(data[i].id) != null) {
        cmtList.add(GetCommentModel(
            id: data[i].id,
            content: data[i].content,
            mangaId: data[i].mangaId,
            mangaName: data[i].mangaName,
            createdUserId: data[i].createdUserId,
            createdUsername: data[i].createdUsername,
            createdUserProfileUrl: data[i].createdUserProfileUrl,
            createdDateInMilliSeconds: data[i].createdDateInMilliSeconds,
            updatedDateInMilliSeconds: data[i].updatedDateInMilliSeconds,
            uploaderId: data[i].uploaderId,
            uploaderReadStatus: data[i].uploaderReadStatus,
            type: data[i].type,
            mentionedUserReadStatus: data[i].mentionedUserReadStatus,
            mentionedUserId: data[i].mentionedUserId,
            mentionedUsername: data[i].mentionedUsername,
            replied: true));
      } else {
        cmtList.add(GetCommentModel(
          id: data[i].id,
          content: data[i].content,
          mangaId: data[i].mangaId,
          mangaName: data[i].mangaName,
          createdUserId: data[i].createdUserId,
          createdUsername: data[i].createdUsername,
          createdUserProfileUrl: data[i].createdUserProfileUrl,
          createdDateInMilliSeconds: data[i].createdDateInMilliSeconds,
          updatedDateInMilliSeconds: data[i].updatedDateInMilliSeconds,
          uploaderId: data[i].uploaderId,
          uploaderReadStatus: data[i].uploaderReadStatus,
          type: data[i].type,
          mentionedUserReadStatus: data[i].mentionedUserReadStatus,
          mentionedUserId: data[i].mentionedUserId,
          mentionedUsername: data[i].mentionedUsername,
        ));
      }
    }
    return cmtList;
  }
}
