import 'package:hive/hive.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/models/your_choice_models/resume_model.dart';
import 'package:mangaturn/services/api.dart';
import 'package:mangaturn/services/bloc/ads/free_point_cubit.dart';
import 'package:mangaturn/services/bloc/ads/popup_cubit.dart';
import 'package:mangaturn/services/bloc/ads/reward_cubit.dart';
import 'package:mangaturn/services/bloc/choice/resume_cubit.dart';
import 'package:mangaturn/services/bloc/choice/version_cubit.dart';
import 'package:mangaturn/services/bloc/comment/get_all_comment/get_all_comment_bloc.dart';
import 'package:mangaturn/services/bloc/comment/get_latest_comment/get_lastest_comment_cubit.dart';
import 'package:mangaturn/services/bloc/comment/get_mentioned_comment/get_mentioned_bloc.dart';
import 'package:mangaturn/services/bloc/comment/get_unread_cmt_count/get_unread_cmt_count_cubit.dart';
import 'package:mangaturn/services/bloc/comment/get_unread_comment_by_admin/get_unread_comment_by_admin_cubit.dart';
import 'package:mangaturn/services/bloc/comment/post_comment/post_comment_cubit.dart';
import 'package:mangaturn/services/bloc/firestore/get_follow_cubit.dart';
import 'package:mangaturn/services/bloc/firestore/notification_cubit.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_genre_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_download_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_manga_by_genre_id_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recommend_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/bloc/get/manga/get_all_user_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_fav_manga_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_name_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_update_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_uploaded_manga_bloc.dart';
import 'package:mangaturn/services/bloc/get/point_purchase_status_cubit.dart';
import 'package:mangaturn/services/bloc/get/search_manga_by_name_cubit.dart';
import 'package:mangaturn/services/bloc/post/buy_point_cubit.dart';
import 'package:mangaturn/services/bloc/post/edit_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/post/edit_characters_cubit.dart';
import 'package:mangaturn/services/bloc/post/edit_manga_cubit.dart';
import 'package:mangaturn/services/bloc/post/purchase_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/post/sign_up_cubit.dart';
import 'package:mangaturn/services/bloc/put/update_user_info_cubit.dart';
import 'package:mangaturn/services/database.dart';
import 'package:dio_flutter_transformer/dio_flutter_transformer.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:mangaturn/services/firestore_db.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/services/bloc/post/login_cubit.dart';

var getIt = GetIt.I;

void locator() {
  Dio dio = Dio();
  dio.transformer = FlutterTransformer();
  // dio.interceptors
  //     .add(LogInterceptor(responseBody: true, logPrint: (log) => print(log)));
  getIt.registerLazySingleton(() => dio);

  RewardCubit rewardCubit = RewardCubit();
  getIt.registerLazySingleton(() => rewardCubit);

  FreePointCubit freePointCubit = FreePointCubit();
  getIt.registerLazySingleton(() => freePointCubit);

  PopupCubit popupCubit = PopupCubit();
  getIt.registerLazySingleton(() => popupCubit);

  FirestoreDB firestoreDB = FirestoreDB();
  getIt.registerLazySingleton(() => firestoreDB);

  NotificationCubit _notificationCubit = NotificationCubit(db: getIt.call());
  getIt.registerLazySingleton(() => _notificationCubit);

  GetFollowCubit _getFollowCubit = GetFollowCubit(firestoreDb: getIt.call());
  getIt.registerLazySingleton(() => _getFollowCubit);

  Box<ResumeModel> resumeBox = Hive.box<ResumeModel>('resume');
  getIt.registerLazySingleton(() => resumeBox);

  ResumeCubit resumeCubit = ResumeCubit(getIt.call());
  getIt.registerLazySingleton(() => resumeCubit);

  ApiService apiService = ApiService(getIt.call());
  getIt.registerLazySingleton(() => apiService);

  ApiRepository apiRepository = ApiRepository(getIt.call());
  getIt.registerLazySingleton(() => apiRepository);

  Box<AuthResponseModel> authBox = Hive.box<AuthResponseModel>('auth');
  getIt.registerLazySingleton(() => authBox);

  LoginCubit _loginCubit =
      LoginCubit(apiRepository: getIt.call(), authBox: getIt.call());
  getIt.registerLazySingleton(() => _loginCubit);

  SignUpCubit _signUpCubit =
      SignUpCubit(apiRepository: getIt.call(), authBox: getIt.call());
  getIt.registerLazySingleton(() => _signUpCubit);

  VersionCubit versionCubit = VersionCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => versionCubit);

  PointPurchaseStatusCubit pointPurchaseStatusCubit =
      PointPurchaseStatusCubit(getIt.call());
  getIt.registerLazySingleton(() => pointPurchaseStatusCubit);

  GetRecommendMangaCubit _getRecommendMangaCubit =
      GetRecommendMangaCubit(getIt.call());
  getIt.registerLazySingleton(() => _getRecommendMangaCubit);

  GetFavMangaBloc _getFavMangaBloc =
      GetFavMangaBloc(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _getFavMangaBloc);

  GetAllMangaCubit _getAllMangaCubit =
      GetAllMangaCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _getAllMangaCubit);

  GetMangaByNameBloc _getMangaByNameBloc =
      GetMangaByNameBloc(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _getMangaByNameBloc);

  GetMangaByUpdateBloc _getMangaByUpdateBloc =
      GetMangaByUpdateBloc(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _getMangaByUpdateBloc);

  GetAllUserBloc _getAllUserBloc = GetAllUserBloc(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _getAllUserBloc);

  DBHelper dbHelper = DBHelper();
  getIt.registerLazySingleton(() => dbHelper);

  GetAllChapterCubit _getAllChapterCubit =
      GetAllChapterCubit(apiRepository: getIt.call(), dbHelper: getIt.call());
  getIt.registerLazySingleton(() => _getAllChapterCubit);

  DownloadCubit _downloadCubit =
      DownloadCubit(apiRepository: getIt.call(), dbHelper: getIt.call());
  getIt.registerLazySingleton(() => _downloadCubit);

  GetDownloadMangaCubit _getDownloadMangaCubit =
      GetDownloadMangaCubit(dbHelper: getIt.call());
  getIt.registerLazySingleton(() => _getDownloadMangaCubit);

  GetLatestChaptersCubit _getLatestChaptesCubit = GetLatestChaptersCubit(
      apiRepository: getIt.call(), dbHelper: getIt.call());
  getIt.registerLazySingleton(() => _getLatestChaptesCubit);

  GetMangaByGenreIdCubit _getMangaByGenreIdCubit =
      GetMangaByGenreIdCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _getMangaByGenreIdCubit);

  GetUserProfileCubit _getUserProfileCubit =
      GetUserProfileCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _getUserProfileCubit);

  UpdateUserInfoCubit _updateUserInfoModel =
      UpdateUserInfoCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _updateUserInfoModel);

  GetAllGenreCubit _getAllGenreCubit =
      GetAllGenreCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _getAllGenreCubit);

  SearchMangaByNameCubit _searchMangaByNameCubit =
      SearchMangaByNameCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _searchMangaByNameCubit);

  PurchaseChapterCubit _purchase =
      PurchaseChapterCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _purchase);

  GetRecentChapterCubit _getRecentChapterCubit =
      GetRecentChapterCubit(dbHelper: getIt.call());
  getIt.registerLazySingleton(() => _getRecentChapterCubit);

  GetUploadedMangaBloc _getUploadedMangaCubit =
      GetUploadedMangaBloc(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _getUploadedMangaCubit);

  EditMangaCubit _editMangaCubit = EditMangaCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _editMangaCubit);

  EditChapterCubit _editChapterCubit =
      EditChapterCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _editChapterCubit);

  EditCharactersCubit _editCharactersCubit = EditCharactersCubit(getIt.call());
  getIt.registerLazySingleton(() => _editCharactersCubit);

  BuyPointCubit _buyPointCubit = BuyPointCubit(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => _buyPointCubit);

  GetLastetCommentCubit getLatestComment = GetLastetCommentCubit(getIt.call());
  getIt.registerLazySingleton(() => getLatestComment);

  GetAllCommentBloc getAllCommentBloc =
      GetAllCommentBloc(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => getAllCommentBloc);

  GetMentionedCommentBloc getMentionedBloc =
      GetMentionedCommentBloc(apiRepository: getIt.call());
  getIt.registerLazySingleton(() => getMentionedBloc);

  PostCommentCubit postCommentCubit = PostCommentCubit(getIt.call());
  getIt.registerLazySingleton(() => postCommentCubit);

  GetUnreadCmtCountCubit getUnreadCmtCountCubit =
      GetUnreadCmtCountCubit(getIt.call());
  getIt.registerLazySingleton(() => getUnreadCmtCountCubit);

  GetUnreadCommentByAdminCubit getUnreadCommentByAdminCubit =
      GetUnreadCommentByAdminCubit(getIt.call());
  getIt.registerLazySingleton(() => getUnreadCommentByAdminCubit);
}
