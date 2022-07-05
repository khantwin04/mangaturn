import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/models/firestore_models/follow_uploader_model.dart';
import 'package:mangaturn/services/firestore_db.dart';

part 'get_follow_state.dart';

class GetFollowCubit extends Cubit<GetFollowState> {
  FirestoreDB firestoreDb;

  GetFollowCubit({required this.firestoreDb}) : super(GetFollowInitial()) {
    getFollowList();
  }

  int followCount = 0;

  List<int> followUserIdList = [];

  int get getFollowCount => followCount;

  List<int> get getFollowUserIdList => [...followUserIdList];

  void follow(FollowModel data) async {
    emit(GetFollowLoading());
    await Utility.registerOnFirebase(data.userId.toString());
    firestoreDb.followUser(data).then((value) {
      getFollowList();
    }).catchError((e) => emit(GetFollowFail(e.toString())));
  }

  void getFollowList() {
    followUserIdList = [];
    emit(GetFollowLoading());
    firestoreDb.getFollowUsers().then((value) async {
      followCount = value.length;
      for (int i = 0; i < value.length; i++) {
        followUserIdList.add(value[i].userId);
      }
    
      emit(GetFollowSuccess(value));
    }).catchError((e) => emit(GetFollowFail(e.toString())));
  }

  void unfollow(int userId) async {
    emit(GetFollowLoading());
    await Utility.unregisterOnFirebase(
      userId.toString(),
    );
    firestoreDb.unfollowUserById(userId).then((value) {
      getFollowList();
    }).catchError((e) => emit(GetFollowFail(e.toString())));
  }
}
