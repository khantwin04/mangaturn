import 'dart:io';
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:mangaturn/config/local_storage.dart';
import 'package:mangaturn/custom_widgets/purchase_chapter_confirm.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/firestore_models/noti_model.dart';
import 'package:mangaturn/services/bloc/firestore/notification_cubit.dart';
import 'package:mangaturn/services/bloc/post/purchase_chapter_cubit.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/detail/chapter_list.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:mangaturn/ui/detail/get_manga_by_name.dart';
import 'package:mangaturn/ui/detail/offline_reader.dart';
import 'package:mangaturn/ui/detail/reader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class Utility {

  static void nextScreen(BuildContext context, Widget screen) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }
  
  static String get serverKey => 'AIzaSyD8ZQtevAGHCCvkKdMm_Ewwk47pcU7qICA';

  static String get versionNo => "2.0.0";

  static Future<String> createDynamicLink(
      {bool userInfo = false,
      required int id,
      required String name,
      required String cover}) async {
    print(id);

    Map<String, dynamic> createLink = userInfo
        ? {
            "dynamicLinkInfo": {
              "domainUriPrefix": "https://mangaturnctt.page.link",
              "link":
                  "https://mangaturn.games/files/web/#/index.html?userId=$id",
              "androidInfo": {
                "androidPackageName": "com.codetotalk.mangaturn",
                "androidFallbackLink":
                    "https://mangaturn.games/files/web/#/index.html?userId=$id"
              },
              "navigationInfo": {"enableForcedRedirect": true},
              "socialMetaTagInfo": {
                "socialTitle": "$name",
                "socialDescription": "Follow me to get updates.",
                "socialImageLink": cover
              }
            },
            "suffix": {"option": "SHORT"}
          }
        : {
            "dynamicLinkInfo": {
              "domainUriPrefix": "https://mangaturnctt.page.link",
              "link":
                  "https://mangaturn.games/files/web/#/index.html?mangaId=$id",
              "androidInfo": {
                "androidPackageName": "com.codetotalk.mangaturn",
                "androidFallbackLink":
                    "https://mangaturn.games/files/web/#/index.html?mangaId=$id"
              },
              "iosInfo": {
                "iosFallbackLink":
                    "https://mangaturn.games/files/web/#/index.html?mangaId=$id",
                "iosIpadFallbackLink":
                    "https://mangaturn.games/files/web/#/index.html?mangaId=$id",
              },
              "navigationInfo": {"enableForcedRedirect": true},
              "socialMetaTagInfo": {
                "socialTitle": "Check this out.",
                "socialDescription": "Read now $name",
                "socialImageLink": cover
              }
            },
            "suffix": {"option": "SHORT"}
          };
    final response = await http.post(
      Uri.parse(
          'https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=AIzaSyD8ZQtevAGHCCvkKdMm_Ewwk47pcU7qICA'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(createLink),
    );

    print(response.body);
    final map = jsonDecode(response.body);
    return map['shortLink'].toString();
  }

  static Future<String> createChapterLink(
      {required ChapterModel chapterModel, required String cover}) async {
    print(chapterModel.id);

    String chapterData =
        "chapterId=${chapterModel.id}&chapterName=${chapterModel.chapterName}&type=${chapterModel.type}&point=${chapterModel.point}&isPurchase=${chapterModel.isPurchase}";

    Map<String, dynamic> createLink = {
      "dynamicLinkInfo": {
        "domainUriPrefix": "https://mangaturnctt.page.link",
        "link": "https://mangaturn.games/files/web/#/index.html?$chapterData",
        "androidInfo": {
          "androidPackageName": "com.codetotalk.mangaturn",
          "androidFallbackLink":
              "https://mangaturn.games/files/web/#/index.html?$chapterData"
        },
        "iosInfo": {
          "iosFallbackLink":
              "https://mangaturn.games/files/web/#/index.html?$chapterData",
          "iosIpadFallbackLink":
              "https://mangaturn.games/files/web/#/index.html?$chapterData",
        },
        "navigationInfo": {"enableForcedRedirect": true},
        "socialMetaTagInfo": {
          "socialTitle": "${chapterModel.chapterName}",
          "socialDescription": "Read now",
          "socialImageLink": cover
        }
      },
      "suffix": {"option": "SHORT"}
    };
    final response = await http.post(
      Uri.parse(
          'https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=AIzaSyD8ZQtevAGHCCvkKdMm_Ewwk47pcU7qICA'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(createLink),
    );

    print(response.body);
    final map = jsonDecode(response.body);
    return map['shortLink'].toString();
  }

  static Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('$path');
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  static launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  static routeOnNoti(NotiModel notification, BuildContext context) {
    if (notification.mangaId == 0) {
      final updateNoti = NotiModel(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        mangaId: notification.mangaId,
        mangaName: notification.mangaName,
        mangaCover: notification.mangaCover,
        see: 'true',
      );
      BlocProvider.of<NotificationCubit>(context)
          .updateNotification(updateNoti);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => GetMangaByName(
          mangaName: notification.mangaName,
        ),
      ));
    } else if (notification.mangaName == 'newVersion') {
      final updateNoti = NotiModel(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        mangaId: notification.mangaId,
        mangaName: notification.mangaName,
        mangaCover: notification.mangaCover,
        see: 'true',
      );
      BlocProvider.of<NotificationCubit>(context)
          .updateNotification(updateNoti);
      launchURL(notification.body);
    } else {
      final updateNoti = NotiModel(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        mangaId: notification.mangaId,
        mangaName: notification.mangaName,
        mangaCover: notification.mangaCover,
        see: 'true',
      );
      BlocProvider.of<NotificationCubit>(context)
          .updateNotification(updateNoti);
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => ChapterList(
            mangaId: notification.mangaId,
            manga_name: notification.mangaName,
            manga_cover: notification.mangaCover),
      ));
    }
  }

  static registerOnFirebase(String channel) async {
    print('registering');

    await FirebaseMessaging.instance
        .subscribeToTopic(channel)
        .then((value) => print('$channel follow'))
        .catchError((e) {
      print(e.toString());
    });
  }

  static unregisterOnFirebase(String channel) async {
    print('unregister');
    await FirebaseMessaging.instance.unsubscribeFromTopic(channel);
  }

  // static void getMessage(FirebaseMessaging fcm, GlobalKey<NavigatorState> key) {
  //   fcm.(onMessage: (Map<String, dynamic> message) async {
  //     if (message['data']['mangaId'] != null) {
  //       key.currentState.pushNamed(ComicDetail.routeName,
  //           arguments: [null, int.parse(message['data']['mangaId'])]);
  //     }
  //     print(message['data']['mangaId']);
  //   }, onResume: (Map<String, dynamic> message) async {
  //     print('on resume $message');
  //     print(message["notification"]["body"]);
  //   }, onLaunch: (Map<String, dynamic> message) async {
  //     print('on launch $message');
  //   });
  // }

  static Image imageFromBase64String(String base64String) {
    return Image.memory(
      base64Decode(base64String),
      fit: BoxFit.fill,
    );
  }

  static Uint8List dataFromBase64String(String base64String) {
    return base64Decode(base64String);
  }

  static String base64String(Uint8List data) {
    String base64 = base64Encode(data);
    return "data:image/png;base64," + base64;
  }

  static Future<String> NetworkImageToBase64(String networkImage) async {
    http.Response response = await http.get(
      Uri.parse(networkImage),
    );
    Uint8List byteImage = response.bodyBytes;
    String base64 = base64Encode(byteImage);
    return base64;
  }

  static Future deleteImageFromCache(String url) async {
    await CachedNetworkImage.evictFromCache(url);
  }

  static Future<String> NetworkImageToBase64Prefix(String networkImage) async {
    http.Response response = await http.get(
      Uri.parse(networkImage),
    );
    Uint8List byteImage = response.bodyBytes;
    String base64 = base64String(byteImage);
    return base64;
  }

  static Future<String> getAppPath() async {
    var androidPath = await getApplicationDocumentsDirectory();
    print(androidPath.path);
    return androidPath.path;
  }

  static void requestPermission() async {
    await Permission.storage.request();
  }

  static Future<void> onTapChapter(int mangaId, String mangaName,
      ChapterModel model, BuildContext context) async {
    if (model.type == "PAID") {
      if (model.isPurchase == true) {
        await LocalStorage.saveReadChapterId(model.id);

        Navigator.pushNamed(context, Reader.routeName,
            arguments: [model, <ChapterModel>[], 0, 'desc', mangaId, '']);
      } else {
        //  Navigator.pushNamed(context, Reader.routeName,
        //     arguments: [model, <ChapterModel>[], 0, 'desc', mangaId]);
        bool result = await confirmPurchase(context);
        if (result) {
          BlocProvider.of<PurchaseChapterCubit>(context)
              .purchaseChapter(model.id, context);
          PurchaseChapter(context, model.chapterName);
        }
      }
    } else {
      await LocalStorage.saveReadChapterId(model.id);
      Navigator.pushNamed(context, Reader.routeName,
          arguments: [model, <ChapterModel>[], 0, 'desc', mangaId, '']);
    }
  }
}
