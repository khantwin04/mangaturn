import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_name_bloc.dart';
import 'package:mangaturn/services/bloc/get/manga/get_manga_by_update_bloc.dart';
import 'package:mangaturn/ui/all_comic/all.dart';
import 'package:mangaturn/ui/all_comic/all_admin_list.dart';
import 'package:mangaturn/ui/all_comic/latest_manga.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AllComicTabNav extends StatefulWidget {
  @override
  _AllComicTabNavState createState() => _AllComicTabNavState();
}

class _AllComicTabNavState extends State<AllComicTabNav> {
  bool sortByDate = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<GetMangaByUpdateBloc>(context).setPage = 0;

            BlocProvider.of<GetMangaByUpdateBloc>(context)
                .add(GetMangaByUpdateReload());
            BlocProvider.of<GetMangaByNameBloc>(context).setPage = 0;
            BlocProvider.of<GetMangaByNameBloc>(context)
                .add(GetMangaByNameReload());
          },
          child: sortByDate ? LatestMangaView() : AllComicView()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: sortByDate
            ? Icon(
                Icons.sort_by_alpha,
                color: Colors.black,
              )
            : Icon(
                Icons.update,
                color: Colors.black,
              ),
        onPressed: () {
          setState(() {
            sortByDate = !sortByDate;
          });
        },
      ),
    );
  }
}
