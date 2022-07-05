import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/chapter_models/recent_chapter_model.dart';
import 'package:mangaturn/services/database.dart';
import 'package:equatable/equatable.dart';

part 'get_recent_chapter_state.dart';

class GetRecentChapterCubit extends Cubit<GetRecentChapterState> {
  DBHelper dbHelper;

  GetRecentChapterCubit({required  this.dbHelper}) : super(GetRecentChapterInitial()){
    getAllRecentChapterList();
  }

  void getAllRecentChapterList() {
    emit(GetRecentChapterLoading());
    dbHelper.getRecentChapterList().then((value) {
      emit(GetRecentChapterSuccess(value));
    }).catchError((e) {
      emit(GetRecentChapterFail(e.toString()));
    });
  }

  void deleteChapterById(int chapterId){
    emit(GetRecentChapterLoading());
    dbHelper.deleteRecentChapterById(chapterId)
        .then((value) {
          getAllRecentChapterList();
    }).catchError((e){
          emit(GetRecentChapterFail(e.toString()));
    });
  }

  void deleteChapterByMangaId(int mangaId){
    emit(GetRecentChapterLoading());
    dbHelper.deleteRecentChapterByMangaId(mangaId)
        .then((value) {
      getAllRecentChapterList();
    }).catchError((e){
      emit(GetRecentChapterFail(e.toString()));
    });
  }
}
