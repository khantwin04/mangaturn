import 'package:clipboard/clipboard.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/services/bloc/firestore/get_follow_cubit.dart';
import 'package:mangaturn/ui/detail/uploader_info.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher.dart';

class FollowedList extends StatefulWidget {
  FollowedList({Key? key}) : super(key: key);

  @override
  _FollowedListState createState() => _FollowedListState();
}

class _FollowedListState extends State<FollowedList> {
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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

  @override
  void initState() {
    fToast = FToast();
    fToast.init(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Followed Uploaders'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<GetFollowCubit, GetFollowState>(
          builder: (context, state) {
            if (state is GetFollowLoading) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (state is GetFollowSuccess) {
              return ListView.builder(
                  itemCount: state.followList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => UploaderInfo(
                                  id: state.followList[index].userId,
                                  uploader: null,
                                )));
                      },
                      child: ListTile(
                        title: Text(state.followList[index].userName),
                        subtitle: Card(
                          elevation: 2.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () {
                                    BlocProvider.of<GetFollowCubit>(context)
                                        .unfollow(
                                            state.followList[index].userId);
                                  },
                                  icon: Icon(
                                    Icons.notification_important,
                                    size: 18,
                                  ),
                                  label: Text(
                                    'Unfollow',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: TextButton.icon(
                                  onPressed: () async {
                                    print('ok tap');
                                    Loading(context);
                                    String link =
                                        await Utility.createDynamicLink(
                                            userInfo: true,
                                            id: state.followList[index].userId,
                                            name: state
                                                .followList[index].userName,
                                            cover: state
                                                .followList[index].userCover);
                                    print(link);
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Share it or copy it.'),
                                        content: Text(link),
                                        actions: [
                                          IconButton(
                                              icon: Icon(Icons.copy),
                                              onPressed: () async {
                                                await FlutterClipboard.copy(
                                                    link);
                                                _showToast("Copied the link");
                                              }),
                                          IconButton(
                                              icon: Icon(Icons.share),
                                              onPressed: () {
                                                Share.share(link);
                                              }),
                                        ],
                                      ),
                                    );
                                  },
                                  icon: FaIcon(
                                    FontAwesomeIcons.share,
                                    size: 13,
                                  ),
                                  label: Text(
                                    'Share',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            } else if (state is GetFollowFail) {
              return Center(
                child: Text(state.error),
              );
            }
            return Container();
          },
        ),
      ),
    );
  }
}
