import 'package:flutter/material.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/chapter_models/page_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:photo_view/photo_view.dart';

class MangaViewer extends StatefulWidget {
  final ChapterModel chapterModel;
  final String token;
  final Function(bool hide) hide;
  final String direction;
  final Axis scrollDirection;
  final bool leftToRight;

  MangaViewer(
      {required this.chapterModel,
      required this.token,
      required this.hide,
      required this.direction,
      required this.scrollDirection,
        required this.leftToRight,
      });

  @override
  _MangaViewerState createState() => _MangaViewerState();
}

class _MangaViewerState extends State<MangaViewer> {
  late ScrollController controller;
  late ChapterModel chapterModel;
  late String token;
  late ApiRepository _apiRepository;
  int page = -1;
  bool scrollLoading = false;
  bool isLoading = false;
  bool noChapter = false;
  List<PageModel> pageLists = [];
  PageController _controller = PageController(
    viewportFraction: 1,
    keepPage: false,
  );
  bool hideControls = false;

  late PhotoViewScaleStateController scaleStateController;

  ScrollPhysics scrollPhy = BouncingScrollPhysics();

  void getData() {
    if (!isLoading) {
      setState(() {
        page++;
        isLoading = true;
      });

      _apiRepository
          .getAllPages(chapterModel.id, 5, page, token)
          .then((_pages) {
        if (mounted) {
          setState(() {
            isLoading = false;
            scrollLoading = false;
            pageLists.addAll(_pages);
          });
        }
      });
    }
  }

  @override
  void initState() {
    chapterModel = widget.chapterModel;
    token = widget.token;
    scaleStateController = PhotoViewScaleStateController();
    _apiRepository = new ApiRepository(getIt.call());
    getData();
    super.initState();
  }

  @override
  void dispose() {
    scaleStateController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          hideControls = !hideControls;
        });
        widget.hide(hideControls);
      },
      child: PageView.builder(
        reverse: widget.direction == "Axis.horizontal" && widget.leftToRight? true : false,
        controller: _controller,
        allowImplicitScrolling: true,
        physics: scrollPhy,
        pageSnapping: true,
        clipBehavior: Clip.hardEdge,
        scrollDirection: widget.scrollDirection,
        itemCount: pageLists.length,
        onPageChanged: (page) {
          if (page + 4 == pageLists.length) {
            getData();
          }
        },
        itemBuilder: (context, page) {
          NetworkImage data = NetworkImage(pageLists[page].contentPath);

          return PhotoView(
            scaleStateController: scaleStateController,
            errorBuilder: (_, ___, ____) => Center(
                child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Image Error',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          data = NetworkImage(pageLists[page].contentPath);
                        });
                      },
                      child: Text(
                        'Retry',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      )),
                ],
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
            scaleStateChangedCallback: (v) {
              if (scaleStateController.scaleState ==
                  PhotoViewScaleState.initial) {
                setState(() {
                  scrollPhy = BouncingScrollPhysics();
                });
              } else {
                setState(() {
                  scrollPhy = NeverScrollableScrollPhysics();
                });
              }
            },
            tightMode: false,
            filterQuality: FilterQuality.high,
            imageProvider: data,
            gaplessPlayback: true,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            initialScale: PhotoViewComputedScale.contained,
          );
        },
      ),
    );
  }
}
