import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/config/custom_colors.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/services/bloc/firestore/notification_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_all_manga_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_latest_chapters_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/ui/all_comic/all.dart';
import 'package:mangaturn/ui/all_comic/all_comic_tab_nav.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:mangaturn/ui/home/disover/discover.dart';
import 'package:mangaturn/ui/home/reader_notification.dart';
import 'package:mangaturn/ui/home/search.dart';
import 'package:mangaturn/ui/home/uploaders/uploader_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/ui/home/your_choice.dart';
import 'package:mangaturn/ui/more/purchase_method.dart';
import 'package:mangaturn/ui/my_list/favourite_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'customer_support.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _tabIndex = 0;
  List<Widget> _homeTab = [];

  @override
  void initState() {
    _homeTab = [
      DiscoverView(),
      AllComicTabNav(),
      UploaderView(),
    ];
    super.initState();
  }

  int totalManga = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.0),
          child: AppBar(
            elevation: 0.0,
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Browse',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
                Text(
                  'All',
                  style: TextStyle(
                      color: Colors.indigo, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => Search(),
                  ));
                },
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              unselectedLabelColor: Colors.black,
              automaticIndicatorColorAdjustment: true,
              indicatorSize: TabBarIndicatorSize.tab,
              physics: BouncingScrollPhysics(),
              onTap: (index) {
                setState(() {
                  _tabIndex = index;
                });
                if (index == 1) {
                  setState(() {
                    totalManga = BlocProvider.of<GetAllMangaCubit>(context)
                        .totalElements;
                  });
                }
              },
              tabs: [
                Tab(
                  child: Row(
                    children: [
                      Icon(
                        Icons.explore,
                        size: 16,
                        color: Colors.blue,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text('Discover'),
                    ],
                  ),
                ),
                Tab(
                  child: totalManga == 0
                      ? Row(
                          children: [
                            Icon(
                              Icons.list_alt_outlined,
                              size: 16,
                              color: Colors.indigo,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('All Manga'),
                          ],
                        )
                      : Row(
                          children: [
                            Icon(
                              Icons.list_alt_outlined,
                              size: 16,
                              color: Colors.indigo,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text('All Manga ($totalManga)'),
                          ],
                        ),
                ),
                Tab(
                  child: Row(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Uploaders',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(children: _homeTab),
      ),
    );
  }
}
