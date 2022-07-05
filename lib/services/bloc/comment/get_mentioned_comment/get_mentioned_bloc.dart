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
      : super(const GetMentionedCommentState());

  final ApiRepository apiRepository;

  set setToken(String data) => token = data;

  late String token;

  @override
  Stream<Transition<GetMentionedCommentEvent, GetMentionedCommentState>>
      transformEvents(
    Stream<GetMentionedCommentEvent> events,
    TransitionFunction<GetMentionedCommentEvent, GetMentionedCommentState>
        transitionFn,
  ) {
    return super.transformEvents(
      events.debounceTime(const Duration(milliseconds: 500)),
      transitionFn,
    );
  }

  @override
  Stream<GetMentionedCommentState> mapEventToState(
      GetMentionedCommentEvent event) async* {
    if (event is GetMentionedCommentFetched) {
      yield await _mapUserToState(state);
    } else if (event is GetMentionedCommentReload) {
      yield await _mapUserToState(
        state.copyWith(
            cmtList: [],
            hasReachedMax: false,
            status: GetMentionedCommentStatus.initial),
      );
    }
  }

  Future<GetMentionedCommentState> _mapUserToState(
      GetMentionedCommentState state) async {
    if (state.hasReachedMax) return state;
    try {
      if (state.status == GetMentionedCommentStatus.initial) {
        final cmtList = await _fetchMentionedComment();
        return state.copyWith(
          status: GetMentionedCommentStatus.success,
          cmtList: cmtList,
          hasReachedMax: false,
        );
      }
      final cmtList = await _fetchMentionedComment();
      return cmtList.isEmpty
          ? state.copyWith(hasReachedMax: true)
          : state.copyWith(
              status: GetMentionedCommentStatus.success,
              cmtList: List.of(state.cmtList)..addAll(cmtList),
              hasReachedMax: false,
            );
    } on Exception {
      return state.copyWith(status: GetMentionedCommentStatus.failure);
    }
  }

  set setPage(data) => page = data;

  int page = 0;

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
