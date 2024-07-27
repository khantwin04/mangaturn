import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:mangaturn/ui/detail/reader.dart';
import 'package:mangaturn/ui/detail/uploader_info.dart';
import 'package:mangaturn/ui/routes_bottom_nav.dart';
import 'package:flutter/material.dart';

class AuthenticatedScreen extends StatefulWidget {
  static const String routeName = "/authencticated";
  String? token;
  bool? isAdmin;

  AuthenticatedScreen({this.token, this.isAdmin});

  @override
  _AuthenticatedScreenState createState() => _AuthenticatedScreenState();
}

class _AuthenticatedScreenState extends State<AuthenticatedScreen> {
  String? token;
  bool? isAdmin;

  _handleDynamicLink(PendingDynamicLinkData? data) async {
    if (data != null) {
      print(data.link.toString() + " handling..");
      final Uri? deepLink = data.link;
      if (deepLink == null) {
        return;
      }
      if (data.link.toString().contains("mangaId")) {
        var rawData = data.link.toString().split("=").last;
        int mangaId = int.parse(rawData);
        print("mangaId=$mangaId is printing");
        Navigator.pushNamed(context, ComicDetail.routeName,
            arguments: [null, mangaId]);
      } else if (data.link.toString().contains("userId")) {
        var rawData = data.link.toString().split("=").last;
        int userId = int.parse(rawData);
        print(userId.toString() + " userID");
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UploaderInfo(
                id: userId,
                uploader: null,
              ),
            ));
      } else if (data.link.toString().contains("chapterId")) {
        List<String> rawData = data.link.toString().split('&');
        print(rawData);
        ChapterModel chapterModel = ChapterModel(
          id: int.parse(rawData[0].split("=").last),
          chapterName: rawData[1].split("=").last.replaceAll('%20', ' '),
          type: rawData[2].split("=").last,
          point: int.parse(rawData[3].split("=").last),
          isPurchase: rawData[4].split("=").last == "null" ||
                  rawData[4].split("=").last == "false"
              ? false
              : true,
          totalPages: 0,
          chapterNo: 0,
        );
        print(chapterModel.id.toString() + " chapterId");
        Navigator.pushNamed(context, Reader.routeName,
            arguments: [chapterModel, <ChapterModel>[], 0, 'asc', 0, '']);
      } else {
        return null;
      }
    }
  }

  Future<void> initDynamicLinks() async {
    print('listening');
    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();

    _handleDynamicLink(data);

    FirebaseDynamicLinks.instance.onLink;
  }

  @override
  void initState() {
    initDynamicLinks();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final args = ModalRoute.of(context)!.settings.arguments;
      if (args != null) {
        List data = args as List;
        token = data[0];
        isAdmin = data[1];
        AuthFunction.preLoadData(context, "Bearer " + data[0]);
      } else {
        AuthFunction.preLoadData(context, widget.token!);
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return RoutesBottomNav(isAdmin: isAdmin == null ? widget.isAdmin : isAdmin);
  }
}
