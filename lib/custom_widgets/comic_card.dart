import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/models/manga_models/manga_model.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget ComicCard(BuildContext context, MangaModel manga,
    {bool smallCard = false, bool loading = false}) {
  if(loading){
    return Shimmer.fromColors(
      baseColor: Colors.grey[200]!,
      highlightColor: Colors.grey[50]!,
      enabled: true,
      child: Container(
        margin: EdgeInsets.only(left: 10.0),
        width: smallCard ? 150 : 200,
        height: smallCard ? 200 : 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: Container(
            color: Colors.grey[100],
          ),
        ),
      ),
    );
  }else {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, ComicDetail.routeName,
            arguments: [manga, manga.id]);
      },
      child: Hero(
        tag: manga.id,
        child: Container(
          margin: EdgeInsets.only(left: 10.0),
          width: smallCard ? 150 : 200,
          height: smallCard ? 200 : 300,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: CachedNetworkImage(
              imageUrl: manga.coverImagePath!,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) =>
                  Center(
                    child: Icon(Icons.error),
                  ),
              placeholder: (_, __) =>
                  Center(
                    child: CircularProgressIndicator(),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
