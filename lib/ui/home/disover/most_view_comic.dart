import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/custom_widgets/bottom_sheet/more_comic_bt_sheet.dart';
import 'package:mangaturn/custom_widgets/comic_card.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class MostViewComic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GetAllMangaCubit, GetAllMangaState>(
        builder: (context, state) {
      if (state is GetAllMangaSuccess) {
        return Column(
          children: state.mangaList
              .map((e) => ListTile(
            onTap: () {
              Navigator.pushNamed(context, ComicDetail.routeName,
                  arguments: [null, e.id]);
            },
            leading: ClipRRect(
              borderRadius:
              BorderRadius.all(Radius.circular(5.0)),
              child: CachedNetworkImage(
                width: 50,
                imageUrl: e.coverImagePath!,
                errorWidget: (_, __, ___) => Center(
                  child: Icon(Icons.error),
                ),
                placeholder: (_, __) => Center(
                  child: CircularProgressIndicator(),
                ),
                fit: BoxFit.cover,
              ),
            ),
            title: Text(e.name!),
            subtitle: Text('${e.uploadedBy}  |  ${e.update==null?"Normal":e.update}'),
            trailing: IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                MoreComicInfo(context, e);
              },
            ),
          ))
              .toList(),
        );
      } else if (state is GetAllMangaFail) {
        return Center(
          child: Text(state.error),
        );
      }
      return Center(
        child: CircularProgressIndicator(),
      );
    });
  }
}
