import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/models/manga_models/character_model.dart';
import 'package:photo_view/photo_view.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewCharacter extends StatefulWidget {
  final int index;
  final List<CharacterModel> characterList;
  ViewCharacter({required this.index, required this.characterList});

  @override
  _ViewCharacterState createState() => _ViewCharacterState();
}

class _ViewCharacterState extends State<ViewCharacter> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = PageController(
      viewportFraction: 1,
      keepPage: false,
      initialPage: widget.index,
    );

    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  late FToast fToast;

  _showToast(String text) {
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.grey[100],
      ),
      child: Text(text),
    );

    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  // void makeWallpaper() async {
  //   Loading(context);
  //   int location = WallpaperManager
  //       .HOME_SCREEN; // or location = WallpaperManager.LOCK_SCREEN;
  //   var file = await DefaultCacheManager().getSingleFile(widget.imgPath);
  //   try {
  //     await WallpaperManager.ViewCharacterFromFile(
  //         file.path, location);
  //     Navigator.of(context).pop();
  //     _showToast("Success!");
  //   } on PlatformException {
  //     print('Failed to get wallpaper.');
  //     Navigator.of(context).pop();
  //     _showToast("Error");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView.builder(
      controller: _pageController,
      itemCount: widget.characterList.length,
      scrollDirection: Axis.horizontal,
      itemBuilder: (context, index) {
        return Hero(
          tag: widget.index,
          child: PhotoView(
            errorBuilder: (_, ___, ____) => Center(
                child: Center(
              child: Text(
                'Image Error',
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            )),
            loadingBuilder: (_, img) => img == null
                ? Center(child: CircularProgressIndicator())
                : Center(
                    child: CircularProgressIndicator(
                      value: img.expectedTotalBytes != null
                          ? img.cumulativeBytesLoaded / img.expectedTotalBytes!
                          : null,
                    ),
                  ),
            tightMode: false,
            filterQuality: FilterQuality.high,
            imageProvider: CachedNetworkImageProvider(
                widget.characterList[index].profileImagePath),
            gaplessPlayback: true,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            initialScale: PhotoViewComputedScale.contained,
          ),
        );
      },
    ));
  }
}
