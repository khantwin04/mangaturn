import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/authenticated_screen.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/main.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/models/user_models/get_user_model.dart';
import 'package:mangaturn/services/bloc/firestore/notification_cubit.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/my_list/myList_view.dart';
import 'package:mangaturn/unauthenticated_screen.dart';
import 'package:flutter/material.dart';

import 'models/your_choice_models/feed_model.dart';

class LandingScreen extends StatefulWidget {
  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  AuthResponseModel? authData;
  late ApiRepository apiRepository;
  late bool loginAgain;
  late bool noInternet = false;
  late bool firstTime = true;
  late Future<GetUserModel> checkToken;

  // Future<dynamic> onSelectNotification(String? payload) async {
  //   print(payload);
  //   if (payload != null) {
  //     List<String> list = payload.split(',');
  //     int mangaId = int.parse(list[0]);
  //     String mangaName = list[1];
  //     String mangaCover = list[2];
  //     if (mangaId == 0) {
  //       navigatorKey.currentState!.push(MaterialPageRoute(
  //         builder: (context) => GetMangaByName(
  //           mangaName: mangaName,
  //         ),
  //       ));
  //     } else if (mangaName == 'newVersion') {
  //       Utility.launchURL(mangaCover);
  //     } else {
  //       // navigatorKey.currentState.push(MaterialPageRoute(builder: (context) => GetMangaByName(mangaName: mangaName,),));

  //       navigatorKey.currentState!.push(MaterialPageRoute(
  //         builder: (context) => ChapterList(
  //             mangaId: mangaId, manga_name: mangaName, manga_cover: mangaCover),
  //       ));
  //     }
  //   }
  // }

  @override
  void didChangeDependencies() {
    BlocProvider.of<NotificationCubit>(context).getAllReaderNotification();
    super.didChangeDependencies();
  }

  @override
  void initState() {
    apiRepository = getIt.call();
    Utility.registerOnFirebase('1');
    Utility.registerOnFirebase('feed');
    flutterLocalNotificationsPlugin!.initialize(
      initializationSettings,
    );
    //onSelectNotification: onSelectNotification
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        print('got message');
      }
    });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification!.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin?.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              channelDescription: channel!.description,
              playSound: true,
              icon: '@mipmap/icon',
            ),
          ),
          //payload: action,
        );
      }
    }).onData((data) {
      Map<String, dynamic> feedData =
          json.decode(data.data['feedModel']) as Map<String, dynamic>;
      RemoteNotification? notification = data.notification;
      AndroidNotification? android = data.notification!.android;
      if (notification != null && android != null && !kIsWeb) {
        flutterLocalNotificationsPlugin?.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel!.id,
              channel!.name,
              channelDescription: channel!.description,
              // TODO add a proper drawable resource to android, for now using
              //      one that already exists in example app.
              icon: '@mipmap/icon',
              playSound: true,
            ),
          ),
          //payload: action,
        );
        if (feedData.containsKey('updateType')) {
          print(feedData['isFree'].runtimeType);
          FeedModel feedModel = FeedModel(
              uploaderName: feedData['uploaderName'],
              title: data.notification!.title!,
              body: data.notification!.body!,
              uploaderCover: feedData['uploaderCover'],
              mangaId: feedData['mangaId'],
              mangaName: feedData['mangaName'],
              mangaCover: feedData['mangaCover'],
              mangaDescription: feedData['mangaDescription'],
              chapterId: feedData['chapterId'],
              chapterName: feedData['chapterName'],
              isFree: feedData['isFree'] == true ? true : false,
              point: feedData['point'],
              isPurchase: feedData['isPurchase'] == true ? true : false,
              updateType: feedData['updateType'],
              chapterNo: feedData['chapterNo'],
              totalPages: feedData['totalPages'],
              timeStamp: DateTime.now());
          Box<FeedModel> box = Hive.box<FeedModel>('feed');
          box.add(feedModel);
        }
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('A new onMessageOpenedApp event was published!');
      print("one message open");
    }).onData((data) {
      Map<String, dynamic> feedData =
          json.decode(data.data['feedModel']) as Map<String, dynamic>;

      flutterLocalNotificationsPlugin?.show(
        data.notification.hashCode,
        data.notification!.title,
        data.notification!.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel!.id,
            channel!.name,
            channelDescription: channel!.description,
            // TODO add a proper drawable resource to android, for now using
            //      one that already exists in example app.
            icon: '@mipmap/icon',
            playSound: true,
          ),
        ),
        //payload: action,
      );

      if (feedData.containsKey('updateType')) {
        print(feedData['isFree'].runtimeType);
        FeedModel feedModel = FeedModel(
            uploaderName: feedData['uploaderName'],
            title: data.notification!.title!,
            body: data.notification!.body!,
            uploaderCover: feedData['uploaderCover'],
            mangaId: feedData['mangaId'],
            mangaName: feedData['mangaName'],
            mangaCover: feedData['mangaCover'],
            mangaDescription: feedData['mangaDescription'],
            chapterId: feedData['chapterId'],
            chapterName: feedData['chapterName'],
            isFree: feedData['isFree'] == true ? true : false,
            point: feedData['point'],
            isPurchase: feedData['isPurchase'] == true ? true : false,
            updateType: feedData['updateType'],
            chapterNo: feedData['chapterNo'],
            totalPages: feedData['totalPages'],
            timeStamp: DateTime.now());
        Box<FeedModel> box = Hive.box<FeedModel>('feed');
        box.add(feedModel);
      }
    });
    apiRepository = ApiRepository(getIt.call());
    authData = AuthFunction.getAuthData();
    super.initState();
  }

  final authBox = Hive.box<AuthResponseModel>('auth');

  Widget getNewToken(AuthResponseModel _authData) {
    Future<AuthResponseModel> refreshingToken =
        apiRepository.refreshToken(_authData.refreshToken);
    return FutureBuilder<AuthResponseModel>(
      future: refreshingToken,
      builder: (context, newAuthData) {
        if (newAuthData.hasData) {
          authBox.put('0', newAuthData.data!);
          return AuthenticatedScreen(
            token: "Bearer " + newAuthData.data!.accessToken,
            isAdmin: newAuthData.data!.user.role == "USER" ? false : true,
          );
        } else if (newAuthData.hasError) {
          if (newAuthData.error.toString().contains('SocketException')) {
            return MyListView(
              noInternet: true,
            );
          } else {
            print(newAuthData.error.toString());
            print(newAuthData.stackTrace);
            return UnauthenticatedScreen();
          }
        } else {
          return Scaffold(body: Center(child: Text('Refreshing token..')));
        }
      },
    );
  }

  Widget checkingAccessToken(AuthResponseModel _authData) {
    String token = "Bearer " + _authData.accessToken;
    checkToken = apiRepository.getUserProfile(token);
    print(_authData.refreshToken);
    return FutureBuilder<GetUserModel>(
      future: checkToken,
      builder: (context, checking) {
        if (checking.hasData) {
          print(_authData.toJson());
          return AuthenticatedScreen(
            token: token,
            isAdmin: _authData.user.role == "USER" ? false : true,
          );
        } else if (checking.hasError) {
          if (checking.error.toString().contains('SocketException')) {
            return MyListView(
              noInternet: true,
            );
          } else {
            //get new token using refresh token
            print(checking.stackTrace);
            return getNewToken(_authData);
          }
        } else {
          return Scaffold(body: Center(child: Text('checking token..')));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (authData == null) {
      return UnauthenticatedScreen();
    } else {
      return checkingAccessToken(authData!);
    }
  }
}
