import 'package:bloc/bloc.dart';
import 'package:mangaturn/models/download_models/download_manga_model.dart';
import 'package:mangaturn/services/database.dart';
import 'package:equatable/equatable.dart';

part 'get_download_manga_state.dart';

class GetDownloadMangaCubit extends Cubit<GetDownloadMangaState> {
  DBHelper dbHelper;

  GetDownloadMangaCubit({required this.dbHelper})
      : super(GetDownloadMangaInitial()) {
    getMangaList();
  }

  int downloadMangaList = 0;

  int get getDownloadList => downloadMangaList;

  void getMangaList() {
    emit(GetDownloadMangaLoading());
    dbHelper.getMangaList().then((value) {
      downloadMangaList = value.length;
      emit(GetDownloadMangaSuccess(value));
    }).catchError((e) => emit(GetDownloadMangaFail(e.toString())));
  }

  void deleteMangaById(int mangaId) {
    emit(GetDownloadMangaLoading());
    dbHelper.deleteMangaById(mangaId).then((value) {
      getMangaList();
    }).catchError((e) => emit(GetDownloadMangaFail(e.toString())));
  }
}
