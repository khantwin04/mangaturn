import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangaturn/ui/home/comment/new_comments.dart';
import 'package:mangaturn/ui/home/home.dart';
import 'package:mangaturn/ui/home/search.dart';
import 'package:mangaturn/ui/home/your_choice.dart';
import 'package:mangaturn/ui/my_list/myList_view.dart';
import 'package:mangaturn/ui/workspace/workspace_view.dart';
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import 'more/more.dart';

// ignore: must_be_immutable
class RoutesBottomNav extends StatefulWidget {
  static const String routeName = '/navigate';
  bool? isAdmin;

  RoutesBottomNav({this.isAdmin});

  @override
  _RoutesBottomNavState createState() => _RoutesBottomNavState();
}

class _RoutesBottomNavState extends State<RoutesBottomNav> {
  int _currentIndex = 0;
  List<Widget> _routesList = [];
  SalomonBottomBar? _navigationBar;

  void checkUser(bool isAdmin) {
    if (isAdmin) {
      _routesList = [
        YourChoice(),
        Home(),
        WorkspaceView(),
        MyListView(),
        MoreView(),
      ];
      _navigationBar = SalomonBottomBar(
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
              icon: FaIcon(FontAwesomeIcons.home), title: Text('My Feed')),
          SalomonBottomBarItem(
            icon: FaIcon(FontAwesomeIcons.edge),
            title: Text('Discover'),
            selectedColor: Colors.redAccent,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.upload_rounded, size: 25),
            title: Text('My Work'),
            selectedColor: Colors.deepPurple,
          ),
          SalomonBottomBarItem(
            icon: FaIcon(FontAwesomeIcons.list),
            title: Text('My List'),
            selectedColor: Colors.orange,
          ),
          SalomonBottomBarItem(
            icon: Icon(Icons.more_vert_outlined, size: 25),
            title: Text('More'),
            selectedColor: Colors.teal,
          ),
        ],
      );
    } else {
      _routesList = [
        YourChoice(),
        Home(),
        MyListView(),
        MoreView(),
      ];
      _navigationBar = SalomonBottomBar(
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.black,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          SalomonBottomBarItem(
              icon: FaIcon(FontAwesomeIcons.home), title: Text('My Feed')),
          SalomonBottomBarItem(
            icon: FaIcon(FontAwesomeIcons.edge),
            title: Text('Discover'),
            selectedColor: Colors.redAccent,
          ),
          SalomonBottomBarItem(
            icon: FaIcon(FontAwesomeIcons.list),
            title: Text('My List'),
            selectedColor: Colors.orange,
          ),
          
          SalomonBottomBarItem(
            icon: Icon(Icons.more_vert_outlined, size: 25),
            title: Text('More'),
            selectedColor: Colors.teal,
          ),
        ],
      );
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    checkUser(widget.isAdmin!);

    //  _routesList = [
    //     YourChoice(),
    //     Home(),
    //     MyListView(),
    //     MoreView(),
    //   ];
    //   _navigationBar = SalomonBottomBar(
    //     selectedItemColor: Colors.indigo,
    //     unselectedItemColor: Colors.black,
    //     currentIndex: _currentIndex,
    //     onTap: (index) {
    //       setState(() {
    //         _currentIndex = index;
    //       });
    //     },
    //     items: [
    //       SalomonBottomBarItem(
    //           icon: FaIcon(FontAwesomeIcons.home), title: Text('My Feed')),
    //       SalomonBottomBarItem(
    //         icon: FaIcon(FontAwesomeIcons.edge),
    //         title: Text('Discover'),
    //         selectedColor: Colors.redAccent,
    //       ),
    //       SalomonBottomBarItem(
    //         icon: FaIcon(FontAwesomeIcons.list),
    //         title: Text('My List'),
    //         selectedColor: Colors.orange,
    //       ),
    //       SalomonBottomBarItem(
    //         icon: Icon(Icons.more_vert_outlined, size: 25),
    //         title: Text('More'),
    //         selectedColor: Colors.teal,
    //       ),
    //     ],
    //   );

    return Scaffold(
      body: _routesList[_currentIndex],
      bottomNavigationBar: _navigationBar,
    );
  }
}
