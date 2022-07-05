import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:mangaturn/services/bloc/ads/free_point_cubit.dart';
import 'package:mangaturn/services/bloc/ads/popup_cubit.dart';
import 'package:mangaturn/services/bloc/ads/reward_cubit.dart';
import 'package:mangaturn/services/bloc/choice/resume_cubit.dart';
import 'package:mangaturn/services/bloc/choice/version_cubit.dart';
import 'package:mangaturn/services/bloc/comment/get_all_comment/get_all_comment_bloc.dart';
import 'package:mangaturn/services/bloc/comment/get_mentioned_comment/get_mentioned_bloc.dart';
import 'package:mangaturn/services/bloc/comment/get_unread_cmt_count/get_unread_cmt_count_cubit.dart';
import 'package:mangaturn/services/bloc/comment/get_unread_comment_by_admin/get_unread_comment_by_admin_cubit.dart';
import 'package:mangaturn/services/bloc/comment/post_comment/post_comment_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recommend_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/manga/get_fav_manga_bloc.dart';
import 'package:mangaturn/services/bloc/get/point_purchase_status_cubit.dart';
import 'package:mangaturn/services/bloc/post/buy_point_cubit.dart';
import 'package:path_provider/path_provider.dart' as pathProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mangaturn/authenticated_screen.dart';
import 'package:mangaturn/landing_screen.dart';
import 'package:mangaturn/services/bloc/firestore/get_follow_cubit.dart';
import 'package:mangaturn/services/bloc/firestore/notification_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_download_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_recent_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/get/manga/get_all_user_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_name_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_update_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_uploaded_manga_bloc.dart';
import 'package:mangaturn/services/bloc/post/edit_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/post/edit_characters_cubit.dart';
import 'package:mangaturn/services/bloc/post/login_cubit.dart';
import 'package:mangaturn/services/bloc/post/sign_up_cubit.dart';
import 'package:mangaturn/services/bloc/put/update_user_info_cubit.dart';
import 'package:mangaturn/services/firestore_db.dart';
import 'package:mangaturn/ui/auth/welcome.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:mangaturn/ui/detail/offline_reader.dart';
import 'package:mangaturn/ui/detail/reader.dart';
import 'package:mangaturn/ui/home/search_with_genre.dart';
import 'package:mangaturn/ui/workspace/comic_detail.dart';
import 'package:mangaturn/ui/workspace/edit_manga.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_chapter_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_genre_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_manga_by_genre_id_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/bloc/get/search_manga_by_name_cubit.dart';
import 'package:mangaturn/services/bloc/post/edit_manga_cubit.dart';
import 'package:mangaturn/services/bloc/post/purchase_chapter_cubit.dart';
import 'config/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'models/your_choice_models/resume_model.dart';
import 'services/bloc/comment/get_latest_comment/get_lastest_comment_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey(debugLabel: "MainNavigator");

AndroidNotificationChannel? channel;

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('appicon');

final InitializationSettings initializationSettings = InitializationSettings(
  android: initializationSettingsAndroid,
);

FirestoreDB db = FirestoreDB();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp();
    Directory directory = await pathProvider.getApplicationDocumentsDirectory();
    Hive.init(directory.path);
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(FeedModelAdapter());

    try {
      if (!Hive.isBoxOpen('feed')) await Hive.openBox<FeedModel>('feed');
    } catch (error) {
      await Hive.deleteBoxFromDisk('feed');
      await Hive.openBox('feed');
    }

    //Map<String, dynamic> data = message.data;
    flutterLocalNotificationsPlugin?.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel!.id,
          channel!.name,
          channel!.description,
          icon: '@mipmap/icon',
          playSound: true,
        ),
      ),
      //payload: action,
    );
    RemoteNotification header = message.notification!;
    Map<String, dynamic> feedData =
        json.decode(message.data['feedModel']) as Map<String, dynamic>;
    if (feedData.containsKey('updateType')) {
      FeedModel feedModel = FeedModel(
          uploaderName: feedData['uploaderName'],
          title: header.title!,
          body: header.body!,
          uploaderCover: feedData['uploaderCover'],
          mangaId: feedData['mangaId'],
          mangaName: feedData['mangaName'],
          mangaCover: feedData['mangaCover'],
          mangaDescription: feedData['mangaDescription'],
          chapterId: feedData['chapterId'],
          chapterName: feedData['chapterName'],
          isFree: feedData['isFree'],
          point: feedData['point'],
          isPurchase: feedData['isPurchase'],
          updateType: feedData['updateType'],
          chapterNo: feedData['chapterNo'],
          totalPages: feedData['totalPages'],
          timeStamp: DateTime.now());
      Box<FeedModel> box = Hive.box<FeedModel>('feed');
      box.add(feedModel);
    }
  } else {
    flutterLocalNotificationsPlugin?.show(
      message.hashCode,
      message.notification!.title,
      message.notification!.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel!.id,
          channel!.name,
          channel!.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          icon: '@mipmap/icon',
          playSound: true,
        ),
      ),
      //payload: action,
    );
    RemoteNotification header = message.notification!;
    Map<String, dynamic> feedData =
        json.decode(message.data['feedModel']) as Map<String, dynamic>;
    if (feedData.containsKey('updateType')) {
      FeedModel feedModel = FeedModel(
          uploaderName: feedData['uploaderName'],
          title: header.title!,
          body: header.body!,
          uploaderCover: feedData['uploaderCover'],
          mangaId: feedData['mangaId'],
          mangaName: feedData['mangaName'],
          mangaCover: feedData['mangaCover'],
          mangaDescription: feedData['mangaDescription'],
          chapterId: feedData['chapterId'],
          chapterName: feedData['chapterName'],
          isFree: feedData['isFree'],
          point: feedData['point'],
          isPurchase: feedData['isPurchase'],
          updateType: feedData['updateType'],
          chapterNo: feedData['chapterNo'],
          totalPages: feedData['totalPages'],
          timeStamp: DateTime.now());
      Box<FeedModel> box = Hive.box<FeedModel>('feed');
      box.add(feedModel);
    }
    print('Handling a background message ${message.messageId}');
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory directory = await pathProvider.getApplicationDocumentsDirectory();
  Hive.init(directory.path);

  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(FeedModelAdapter());

  try {
    if (!Hive.isBoxOpen('feed')) await Hive.openBox<FeedModel>('feed');
  } catch (error) {
    await Hive.deleteBoxFromDisk('feed');
    await Hive.openBox('feed');
  }

  Hive.registerAdapter(ResumeModelAdapter());
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(AuthResponseModelAdapter());

  await Hive.openBox<ResumeModel>('resume');
  await Hive.openBox<FeedModel>('feedHistory');
  await Hive.openBox<AuthResponseModel>('auth');
  await Hive.openBox('lastReadGenreList');

  await Firebase.initializeApp();
  await MobileAds.instance.updateRequestConfiguration(RequestConfiguration(
      testDeviceIds: [
        "E0DEB41AE938BDFB4293C854DEC70EEE",
        "524E37430B48033FBB01FC806B254833"
      ]));

  if (!kIsWeb) {
    channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      'This channel is used for important notifications.', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin!
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .createNotificationChannel(channel!);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
  locator();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<RewardCubit>(create: (_) => getIt.call()),
        BlocProvider<FreePointCubit>(create: (_) => getIt.call()),
        BlocProvider<PopupCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<NotificationCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetFollowCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<LoginCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<SignUpCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetDownloadMangaCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<ResumeCubit>(create: (_) => getIt.call()),
        BlocProvider<GetRecentChapterCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<VersionCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<PointPurchaseStatusCubit>(create: (_) => getIt.call()),
        BlocProvider<GetRecommendMangaCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetFavMangaBloc>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetMangaByNameBloc>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetMangaByUpdateBloc>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetAllUserBloc>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetAllMangaCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetMangaByGenreIdCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetAllChapterCubit>(create: (_) => getIt.call()),
        BlocProvider<DownloadCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetLatestChaptersCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetUserProfileCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetAllGenreCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<SearchMangaByNameCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<PurchaseChapterCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<UpdateUserInfoCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetUploadedMangaBloc>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<EditMangaCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<EditChapterCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<EditCharactersCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<BuyPointCubit>(create: (_) => getIt.call()),
        BlocProvider<GetLastetCommentCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetAllCommentBloc>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetMentionedCommentBloc>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<PostCommentCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetUnreadCmtCountCubit>(
          create: (_) => getIt.call(),
        ),
        BlocProvider<GetUnreadCommentByAdminCubit>(
          create: (_) => getIt.call(),
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Manga Turn',
        color: Colors.indigo,
        theme: ThemeData(
          fontFamily: 'baloo2',
          scaffoldBackgroundColor: Colors.white,
          cardColor: Colors.white,
          cardTheme: CardTheme(elevation: 1.0),
          primaryColor: Colors.white,
          appBarTheme: AppBarTheme(
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontFamily: 'baloo2',
              ),
              color: Colors.white,
              iconTheme: IconThemeData(color: Colors.black)),
        ),
        home: LandingScreen(),
        routes: {
          Welcome.routeName: (ctx) => Welcome(),
          AuthenticatedScreen.routeName: (ctx) => AuthenticatedScreen(),
          ComicDetail.routeName: (ctx) => ComicDetail(),
          OfflineReader.routeName: (ctx) => OfflineReader(),
          Reader.routeName: (ctx) => Reader(),
          SearchWithGenre.routeName: (ctx) => SearchWithGenre(),
          EditManga.routeName: (ctx) => EditManga(),
          ComicDetailAdminView.routeName: (ctx) => ComicDetailAdminView(),
        },
      ),
    );
  }
}
