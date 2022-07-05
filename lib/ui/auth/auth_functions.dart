import 'package:hive/hive.dart';
import 'package:mangaturn/authenticated_screen.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/services/bloc/choice/version_cubit.dart';
import 'package:mangaturn/services/bloc/comment/get_all_comment/get_all_comment_bloc.dart';
import 'package:mangaturn/services/bloc/comment/get_latest_comment/get_lastest_comment_cubit.dart';
import 'package:mangaturn/services/bloc/comment/get_mentioned_comment/get_mentioned_bloc.dart';
import 'package:mangaturn/services/bloc/comment/get_unread_cmt_count/get_unread_cmt_count_cubit.dart';
import 'package:mangaturn/services/bloc/comment/get_unread_comment_by_admin/get_unread_comment_by_admin_cubit.dart';
import 'package:mangaturn/services/bloc/comment/post_comment/post_comment_cubit.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_genre_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_manga_by_genre_id_cubit.dart';
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
import 'package:mangaturn/services/bloc/put/update_user_info_cubit.dart';
import 'package:mangaturn/ui/auth/login.dart';
import 'package:mangaturn/ui/auth/sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthFunction {
  static void createAcc(BuildContext context) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUp(),
        ));
  }

  static void loginAcc(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => Login()));
  }

  static void GotoHome(BuildContext context, String token, bool isAdmin) {
    Navigator.pushNamedAndRemoveUntil(
        context, AuthenticatedScreen.routeName, (route) => false,
        arguments: [token, isAdmin]);
  }

  static void preLoadData(BuildContext context, String token) async {
    BlocProvider.of<VersionCubit>(context).setToken = token;
    BlocProvider.of<VersionCubit>(context).checkVersion();
    BlocProvider.of<GetAllMangaCubit>(context).setToken = token;
    BlocProvider.of<GetAllMangaCubit>(context).clear();

    BlocProvider.of<PointPurchaseStatusCubit>(context).setToken = token;
    BlocProvider.of<PointPurchaseStatusCubit>(context)
        .getLatestPurchaseStatus();

    // var box = Hive.box('lastReadGenreList');
    // int? firstGenreId = box.get('firstGenreId');
    // int? similarGenreId = box.get('similarGenreId');
    // if (firstGenreId != null)
    //   BlocProvider.of<GetAllMangaCubit>(context)
    //       .fetchRelatedGenreManga(firstGenreId, 'first');

    // if (similarGenreId != null)
    //    BlocProvider.of<GetAllMangaCubit>(context)
    //       .fetchRelatedGenreManga(similarGenreId, 'similar');
    BlocProvider.of<GetAllMangaCubit>(context)
        .fetchAllManga("views", "desc", 0);
    BlocProvider.of<GetAllMangaCubit>(context).fetchAllManga("name", "asc", 0);

    BlocProvider.of<GetRecommendMangaCubit>(context).setToken = token;

    var box = Hive.box('lastReadGenreList');
    List<int>? genreList = box.get('genreList');

    if (genreList != null && genreList.isNotEmpty)
      BlocProvider.of<GetRecommendMangaCubit>(context)
          .fetchRelatedGenreManga(genreList);

    BlocProvider.of<GetFavMangaBloc>(context).setToken = token;
    BlocProvider.of<GetFavMangaBloc>(context).add(GetFavMangaFetched());

    BlocProvider.of<GetMangaByNameBloc>(context).setToken = token;
    BlocProvider.of<GetMangaByNameBloc>(context).add(GetMangaByNameFetched());

    BlocProvider.of<GetAllUserBloc>(context).setToken = token;
    BlocProvider.of<GetAllUserBloc>(context).add(GetAllUserFetched());

    BlocProvider.of<GetMangaByUpdateBloc>(context).setToken = token;
    BlocProvider.of<GetMangaByUpdateBloc>(context)
        .add(GetMangaByUpdateFetched());

    BlocProvider.of<GetAllChapterCubit>(context).setToken = token;

    BlocProvider.of<DownloadCubit>(context).setToken = token;

    BlocProvider.of<GetLatestChaptersCubit>(context).setToken = token;
    BlocProvider.of<GetLatestChaptersCubit>(context).getLatestChapters();

    BlocProvider.of<GetMangaByGenreIdCubit>(context).setToken = token;
    BlocProvider.of<GetMangaByGenreIdCubit>(context).clear();
    BlocProvider.of<GetMangaByGenreIdCubit>(context).fetchMMManga([29769], 0);

    BlocProvider.of<GetUserProfileCubit>(context).setToken = token;
    BlocProvider.of<GetUserProfileCubit>(context).getUserProfile();

    BlocProvider.of<GetUploadedMangaBloc>(context).setToken = token;

    BlocProvider.of<UpdateUserInfoCubit>(context).setToken = token;

    BlocProvider.of<GetAllGenreCubit>(context).setToken = token;
    BlocProvider.of<GetAllGenreCubit>(context).getAllGenre();

    BlocProvider.of<SearchMangaByNameCubit>(context).setToken = token;

    BlocProvider.of<PurchaseChapterCubit>(context).setToken = token;

    BlocProvider.of<EditMangaCubit>(context).setToken = token;
    BlocProvider.of<EditChapterCubit>(context).setToken = token;
    BlocProvider.of<EditCharactersCubit>(context).setToken = token;

    BlocProvider.of<BuyPointCubit>(context).setToken = token;

    //comment
     BlocProvider.of<GetLastetCommentCubit>(context).setToken = token;
      BlocProvider.of<GetAllCommentBloc>(context).setToken = token;
      BlocProvider.of<PostCommentCubit>(context).setToken = token;
      BlocProvider.of<GetMentionedCommentBloc>(context).setToken = token;
       BlocProvider.of<GetUnreadCmtCountCubit>(context).setToken = token;
       BlocProvider.of<GetUnreadCommentByAdminCubit>(context).setToken = token;

  }

  static String? getToken() {
    AuthResponseModel? auth = getAuthData();
    return auth == null ? null : "Bearer ${auth.accessToken}";
  }

  static AuthResponseModel? getAuthData() {
    final authBox = Hive.box<AuthResponseModel>('auth');
    print('auth box');
    print(authBox.get('0'));
    AuthResponseModel? auth = authBox.get('0') ?? null;
    return auth;
  }
}
