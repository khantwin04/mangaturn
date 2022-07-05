import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/chapter_models/page_model.dart';
import 'package:mangaturn/services/repo/api_repository.dart';

class WebtoonViewer extends StatefulWidget {
  final ChapterModel chapterModel;
  final String token;
  final Function(bool hide) hide;
  WebtoonViewer(
      {required this.chapterModel, required this.token, required this.hide});

  @override
  _WebtoonViewerState createState() => _WebtoonViewerState();
}

class _WebtoonViewerState extends State<WebtoonViewer> {
  late ChapterModel chapterModel;
  late ApiRepository _apiRepository;
  late String token;
  static const _pageSize = 10;
  bool hideControls = false;
  PagingController<int, PageModel> _pagingController =
      PagingController(firstPageKey: 0);

  @override
  void initState() {
    chapterModel = widget.chapterModel;
    token = widget.token;
    _apiRepository = new ApiRepository(getIt.call());
    _pagingController.addPageRequestListener((pageKey) {
      print(pageKey.toString() + " Page Key");
      _fetchPage(pageKey);
    });
    super.initState();
  }

  Future<void> _fetchPage(int pageKey) async {
    print('fetching');
    try {
      final newItems = await _apiRepository.getAllPages(
          chapterModel.id, _pageSize, pageKey, token);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        final nextPageKey = pageKey + 1;
        _pagingController.appendPage(newItems, nextPageKey);
      }
    } catch (error) {
      print(error);
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
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
      child: InteractiveViewer(
        minScale: 1.0,
        maxScale: 5.0,
        child: PagedListView<int, PageModel>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<PageModel>(
              itemBuilder: (context, item, index) {
            return Image(
              filterQuality: FilterQuality.high,
              image: CachedNetworkImageProvider(
                item.contentPath,
              ),
              gaplessPlayback: true,
              loadingBuilder: (BuildContext context, Widget child,
                  ImageChunkEvent? loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
