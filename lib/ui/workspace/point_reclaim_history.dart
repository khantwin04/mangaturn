import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/custom_widgets/customText.dart';
import 'package:mangaturn/models/point_model/point_relcaim_model.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';
import 'package:mangaturn/ui/workspace/new_request_point_reclaim.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PointReclaimHistory extends StatefulWidget {
  final int point;
  PointReclaimHistory(this.point, {Key? key}) : super(key: key);

  @override
  _PointReclaimHistoryState createState() => _PointReclaimHistoryState();
}

class _PointReclaimHistoryState extends State<PointReclaimHistory> {
  List<PointReclaimModel> historyList = [];
  late ApiRepository api;
  late String token;
  int page = 0;
  bool loading = false;
  bool hasReachMax = false;

  late ScrollController _controller;

  bool get isEnd {
    if (!_controller.hasClients) return false;
    final maxScroll = _controller.position.maxScrollExtent;
    final currentScroll = _controller.offset;
    return currentScroll >= (maxScroll * 1);
  }

  _scrollListener() {
    if (isEnd && hasReachMax == false) {
      setState(() {
        loading = true;
      });
      api.getAllPointReclaimList(page++, token).then((value) {
        if (value.isEmpty) {
          setState(() {
            hasReachMax = true;
            loading = false;
          });
        } else {
          BlocProvider.of<GetUserProfileCubit>(context).getUserProfile();
          setState(() {
            loading = false;
            historyList.addAll(value);
          });
        }
      });
    }
  }

  bool getData = false;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void getToken() async {
    final data = AuthFunction.getToken();
    setState(() {
      token = data!;
    });
    api = ApiRepository(getIt.call());
    BlocProvider.of<GetUserProfileCubit>(context).getUserProfile();
    api.getAllPointReclaimList(page++, token).then((value) {
      print(value);
      setState(() {
        getData = true;
        historyList.addAll(value);
      });
    }).catchError((e) {
      print('error');
      print(e.toString());
    });
  }

  @override
  void initState() {
    getToken();
    _controller =
        ScrollController(initialScrollOffset: 0.0, keepScrollOffset: true);
    _controller.addListener(_scrollListener);
    super.initState();
  }

  Widget getHistoryList() {
    if (getData == false) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return ListView.builder(
        controller: _controller,
        itemCount: historyList.length,
        itemBuilder: (context, index) {
          final model = historyList[index];
          if (model.status.toLowerCase() == "pending") {
            return Card(
              child: ExpansionTile(
                leading: Icon(Icons.pending_actions_outlined),
                title: Text('Your request is pending',
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Point ${model.point}'),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.swap_horiz_sharp,
                      color: Colors.indigo,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('${model.point} MMK'),
                    SizedBox(
                      width: 10,
                    ),
                    Chip(
                      label: Text("${model.remark!.split(',').first}",
                          style: TextStyle(
                            color: model.remark!.split(',').first == "WavePay"
                                ? Colors.black
                                : Colors.white,
                          )),
                      backgroundColor:
                          model.remark!.split(',').first == "WavePay"
                              ? Colors.yellow
                              : Colors.blue,
                    ),
                  ],
                ),
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.phone_android,
                      color: Colors.teal,
                    ),
                    title: Text('Your phone number'),
                    subtitle: model.remark == null
                        ? Text('Default phone number')
                        : Text('${model.remark!.split(',').last}'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.reply,
                      color: Colors.red,
                    ),
                    title: Text('Reply from Manga Turn'),
                    subtitle: model.adminRemark == null
                        ? Text('Still waiting for the reply')
                        : Text('${model.adminRemark}'),
                  ),
                ],
              ),
            );
          } else if (model.status.toLowerCase() == "confirm") {
            return Card(
              child: ExpansionTile(
                leading: Icon(Icons.pending_actions_outlined),
                title: Text('Your request is confirmed',
                    style: TextStyle(
                        color: Colors.indigo,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('- ${model.point} point'),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.forward,
                      color: Colors.indigo,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Chip(
                      label: Text("${model.remark!.split(',').first}",
                          style: TextStyle(
                            color: model.remark!.split(',').first == "WavePay"
                                ? Colors.black
                                : Colors.white,
                          )),
                      backgroundColor:
                          model.remark!.split(',').first == "WavePay"
                              ? Colors.yellow
                              : Colors.blue,
                    ),
                  ],
                ),
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.phone_android,
                      color: Colors.teal,
                    ),
                    title: Text('Your phone number'),
                    subtitle: model.remark == null
                        ? Text('Default phone number')
                        : Text('${model.remark!.split(',').last}'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.reply,
                      color: Colors.red,
                    ),
                    title: Text('Reply from Manga Turn'),
                    subtitle: model.adminRemark == null
                        ? Text('Still waiting for the reply')
                        : Text('${model.adminRemark}'),
                  ),
                ],
              ),
            );
          } else {
            return Card(
              child: ExpansionTile(
                leading: Icon(Icons.pending_actions_outlined),
                title: Text('Your request is rejected',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.w500)),
                subtitle: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Point ${model.point}'),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      Icons.swap_horiz_sharp,
                      color: Colors.indigo,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text('${model.point} MMK'),
                    SizedBox(
                      width: 10,
                    ),
                    Chip(
                      label: Text("${model.remark!.split(',').first}",
                          style: TextStyle(
                            color: model.remark!.split(',').first == "WavePay"
                                ? Colors.black
                                : Colors.white,
                          )),
                      backgroundColor:
                          model.remark!.split(',').first == "WavePay"
                              ? Colors.yellow
                              : Colors.blue,
                    ),
                  ],
                ),
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.phone_android,
                      color: Colors.teal,
                    ),
                    title: Text('Your phone number'),
                    subtitle: model.remark == null
                        ? Text('Default phone number')
                        : Text('${model.remark!.split(',').last}'),
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.reply,
                      color: Colors.red,
                    ),
                    title: Text('Reply from Manga Turn'),
                    subtitle: model.adminRemark == null
                        ? Text('Still waiting for the reply')
                        : Text('${model.adminRemark}'),
                  ),
                ],
              ),
            );
          }
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Point Transition History'),
          actions: [
            IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          NewRequestPointReclaim(widget.point),
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      page = 0;
                      getData = false;
                      historyList = [];
                      hasReachMax = false;
                    });
                    getToken();
                  }
                })
          ],
        ),
        body: Column(
          children: [
            Expanded(child: getHistoryList()),
            loading ? Container(child: LinearProgressIndicator()) : Container(),
          ],
        ));
  }
}
