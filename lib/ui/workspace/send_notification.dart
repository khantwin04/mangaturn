import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/config/service_locator.dart';
import 'package:mangaturn/custom_widgets/custom_text_field.dart';
import 'package:mangaturn/custom_widgets/error_alert.dart';
import 'package:mangaturn/custom_widgets/loading.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/firestore_models/customPayload.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/services/repo/api_repository.dart';
import 'package:mangaturn/ui/workspace/notification_history.dart';

class SendNotification extends StatefulWidget {
  final int mangaId;
  final String mangaName;
  final String mangaCover;
  final String mangaDescription;
  final String updateType;
  final ChapterModel chaperModel;

  SendNotification(
      {required this.mangaId,
      required this.mangaName,
      required this.mangaCover,
      required this.mangaDescription,
      required this.updateType,
      required this.chaperModel});

  @override
  _SendNotificationState createState() => _SendNotificationState();
}

class _SendNotificationState extends State<SendNotification> {
  late ApiRepository apiRepository;
  final formKey = GlobalKey<FormState>();
  String title = '';
  late String body;
  String? uploaderName;
  int? uploaderId;
  String? uploaderCover;

  @override
  void initState() {
    apiRepository = getIt.call();
    super.initState();
  }

  void sendNoti(int userId) async {
    if (formKey.currentState!.validate()) {
      print(body.characters.length);
      if (title.length > 500 || body.characters.length > 500) {
        AlertError(
            context: context,
            title: 'Error',
            content: '500 characters limited.');
      } else {
        Loading(context);
        PayloadNotification notification = PayloadNotification(
          title: title,
          body: body,
          image: widget.mangaCover,
          sound: 'default',
        );

        print(widget.chaperModel.point == 0);

        FeedModel feedModel = FeedModel(
            uploaderName: uploaderName!,
            uploaderCover: uploaderCover!,
            mangaId: widget.mangaId,
            mangaName: widget.mangaName,
            mangaCover: widget.mangaCover,
            mangaDescription: widget.mangaDescription,
            chapterId: widget.chaperModel.id,
            chapterName: widget.chaperModel.chapterName,
            isFree: widget.chaperModel.type == "PAID" ? false : true,
            point: widget.chaperModel.point,
            isPurchase: widget.chaperModel.isPurchase == null ||
                    widget.chaperModel.isPurchase == false
                ? false
                : true,
            updateType: widget.updateType,
            title: title,
            body: body,
            chapterNo: widget.chaperModel.chapterNo,
            totalPages: widget.chaperModel.totalPages);

        PayloadData data = PayloadData(
          click_action: "FLUTTER_NOTIFICATION_CLICK",
          feedModel: feedModel,
        );

        print(widget.updateType);
        print(UpdateType.mangaInsert.toString());

        CustomPayload payload = CustomPayload(
          to: widget.updateType == UpdateType.mangaInsert.toString()
              ? '/topics/feed'
              : '/topics/$uploaderId',
          priority: "high",
          notification: notification,
          data: data,
        );
        await apiRepository.sendCustomNotification(payload);
        Navigator.of(context).pop();
        var box = Hive.box<FeedModel>('feedHistory');
        feedModel.timeStamp = DateTime.now();
        box.add(feedModel);
        Navigator.of(context).pop();
      }
    }
  }

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: currentIndex,
      child: Scaffold(
          appBar: AppBar(
            toolbarHeight: 150,
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Send Notification'),
                Text(
                  'You can\'t delete notification history of readers. So don\'t miuse this feature.',
                  maxLines: 3,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            ),
            bottom: TabBar(
              onTap: (index) {
                setState(() {
                  currentIndex = index;
                });
              },
              tabs: [
                Tab(child: Text('Form')),
                Tab(
                  child: Text('History'),
                )
              ],
            ),
          ),
          body: TabBarView(children: [
            BlocConsumer<GetUserProfileCubit, GetUserProfileState>(
              listener: (context, state) {
                if (state is GetUserProfileSuccess) {
                  print(state.user.username);
                  setState(() {
                    title = "From : ${state.user.username}";
                    uploaderName = state.user.username;
                    uploaderCover = state.user.profileUrl;
                    uploaderId = state.user.id;
                  });
                }
              },
              builder: (context, state) {
                if (state is GetUserProfileSuccess) {
                  title = "From : ${state.user.username}";
                  uploaderName = state.user.username;
                  uploaderCover = state.user.profileUrl;
                  uploaderId = state.user.id;
                  return SingleChildScrollView(
                    padding: EdgeInsets.all(16.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          CustomTextField(
                              initialVal: "From : " + state.user.username,
                              label: 'From (Read Only)',
                              readOnly: true,
                              context: context,
                              action: TextInputAction.next,
                              onChange: (data) {
                                setState(() {
                                  title = "From : ${state.user.username}";
                                });
                              }),
                          SizedBox(height: 10),
                          CustomTextField(
                              hintText:
                                  'What do you want to tell your followers?',
                              context: context,
                              maxLines: 10,
                              inputType: TextInputType.multiline,
                              action: TextInputAction.newline,
                              maxLength: 500,
                              onChange: (data) {
                                setState(() {
                                  body = data;
                                });
                              }),
                          Container(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: Icon(Icons.send),
                              label: Text('Send'),
                              onPressed: () {
                                sendNoti(state.user.id);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is GetUserProfileFail) {
                  return Center(
                    child: Text(state.error.toString()),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
            NotificationHistory(),
          ])),
    );
  }
}
