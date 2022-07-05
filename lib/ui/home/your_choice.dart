import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mangaturn/custom_widgets/limit_manga_view_alert_box.dart';
import 'package:mangaturn/custom_widgets/notification_type.dart';
import 'package:mangaturn/custom_widgets/point_purchase_card.dart';
import 'package:mangaturn/custom_widgets/reward_alertBox.dart';
import 'package:mangaturn/custom_widgets/versionAlertBox.dart';
import 'package:mangaturn/services/bloc/ads/reward_cubit.dart';
import 'package:mangaturn/services/bloc/choice/version_cubit.dart';
import 'package:mangaturn/services/bloc/comment/get_unread_cmt_count/get_unread_cmt_count_cubit.dart';
import 'package:mangaturn/services/bloc/get/manga/get_fav_manga_bloc.dart';
import 'package:mangaturn/services/bloc/get/point_purchase_status_cubit.dart';
import 'package:mangaturn/ui/detail/comic_detail.dart';
import 'package:mangaturn/ui/detail/reader.dart';
import 'package:mangaturn/custom_widgets/bottom_sheet/latest_chapters_bt_sheet.dart';
import 'package:mangaturn/custom_widgets/header.dart';
import 'package:mangaturn/models/chapter_models/chapter_model.dart';
import 'package:mangaturn/models/firestore_models/follow_uploader_model.dart';
import 'package:mangaturn/models/user_models/update_userInfo_model.dart';
import 'package:mangaturn/models/your_choice_models/feed_model.dart';
import 'package:mangaturn/models/your_choice_models/resume_model.dart';
import 'package:mangaturn/services/bloc/choice/resume_cubit.dart';
import 'package:mangaturn/services/bloc/firestore/get_follow_cubit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:mangaturn/ui/all_comic/all_admin_list.dart';
import 'package:mangaturn/ui/detail/uploader_info.dart';
import 'package:mangaturn/ui/home/comment/new_comments.dart';
import 'package:mangaturn/ui/home/free_point.dart';
import 'package:mangaturn/ui/home/reader_notification.dart';
import 'package:mangaturn/ui/more/purchase_history.dart';
import 'package:mangaturn/ui/more/purchase_method.dart';
import 'package:mangaturn/ui/more/update_user_info.dart';
import 'package:mangaturn/ui/my_list/favourite_list.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:readmore/readmore.dart';
import 'package:url_launcher/url_launcher.dart';
import 'customer_support.dart';
import 'package:getwidget/getwidget.dart';

class YourChoice extends StatefulWidget {
  @override
  _YourChoiceState createState() => _YourChoiceState();
}

class _YourChoiceState extends State<YourChoice> {
  @override
  void initState() {
    BlocProvider.of<GetUnreadCmtCountCubit>(context).getUnreadCmtCount();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            BlocProvider.of<GetUserProfileCubit>(context).getUserProfile();
            BlocProvider.of<GetFavMangaBloc>(context).add(GetFavMangaReload());
          },
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            //padding: EdgeInsets.all(10.0),
            child: Column(
              children: [
                BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
                  builder: (context, state) {
                    if (state is GetUserProfileSuccess) {
                      if (state.user.role == 'USER') {
                        return Column(
                          children: [
                            Card(
                              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                              child: Column(
                                children: [
                                  AppBar(
                                      elevation: 0.0,
                                      title: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Manga',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Turn',
                                            style: TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      automaticallyImplyLeading: false,
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            limitMangaViewAlertBox(context);
                                          },
                                          child: Text('Filter Manga',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  NewComments(),
                                            ));
                                          },
                                          child: GFIconBadge(
                                            position: GFBadgePosition.topStart(
                                              top: 0,
                                            ),
                                            child: FaIcon(
                                              FontAwesomeIcons.comment,
                                              color: Colors.blue,
                                            ),
                                            counterChild: BlocBuilder<
                                                GetUnreadCmtCountCubit,
                                                GetUnreadCmtCountState>(
                                              builder: (context, state) {
                                                if (state
                                                    is GetUnreadCmtCountSuccess) {
                                                  return Text(
                                                    state.count,
                                                    style: TextStyle(
                                                        color: Colors.indigo,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ]),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PurchaseMethod(
                                                    user: state.user),
                                          ));
                                    },
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.account_balance_wallet,
                                        size: 30,
                                      ),
                                    ),
                                    title: Text('You have'),
                                    subtitle: Text(
                                        state.user.point.toString() + " Point"),
                                    trailing: Container(
                                      margin: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        color: Colors.blue[50],
                                      ),
                                      child: TextButton(
                                          child: Text(
                                            'Edit Profile',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          onPressed: () {
                                            UpdateUserInfoModel update =
                                                UpdateUserInfoModel(
                                                    id: state.user.id,
                                                    username:
                                                        state.user.username);
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateUserInfoView(
                                                      update, false),
                                            ));
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                      child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            GetFreePointScreen(),
                                      ));
                                    },
                                    child: Card(
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Get Free Point',
                                          style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  )),
                                  Expanded(
                                      child: InkWell(
                                    onTap: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) =>
                                            PurchaseMethod(user: state.user),
                                      ));
                                    },
                                    child: Card(
                                      child: Container(
                                        padding: EdgeInsets.all(8.0),
                                        alignment: Alignment.center,
                                        child: Text(
                                          'Buy Point',
                                          style: TextStyle(
                                              color: Colors.indigo,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ),
                                    ),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            Card(
                              margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                              child: Column(
                                children: [
                                  AppBar(
                                      elevation: 0.0,
                                      title: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Manga',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'Turn',
                                            style: TextStyle(
                                                color: Colors.indigo,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                      automaticallyImplyLeading: false,
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            limitMangaViewAlertBox(context);
                                          },
                                          child: Text('Filter Manga',
                                              style: TextStyle(
                                                fontSize: 15,
                                              )),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  NewComments(),
                                            ));
                                          },
                                          child: GFIconBadge(
                                              position:
                                                  GFBadgePosition.topStart(
                                                top: 0,
                                              ),
                                              child: FaIcon(
                                                FontAwesomeIcons.comment,
                                                color: Colors.blue,
                                              ),
                                              counterChild: BlocBuilder<
                                                GetUnreadCmtCountCubit,
                                                GetUnreadCmtCountState>(
                                              builder: (context, state) {
                                                if (state
                                                    is GetUnreadCmtCountSuccess) {
                                                  return Text(
                                                    state.count,
                                                    style: TextStyle(
                                                        color: Colors.indigo,
                                                        fontWeight:
                                                            FontWeight.w600),
                                                  );
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            ),
                                              ),
                                        ),
                                      ]),
                                  ListTile(
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                PurchaseMethod(
                                                    user: state.user),
                                          ));
                                    },
                                    leading: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(
                                        Icons.account_balance_wallet,
                                        size: 30,
                                      ),
                                    ),
                                    title: Text('You have'),
                                    subtitle: Text(
                                        state.user.point.toString() + " Point"),
                                    trailing: Container(
                                      margin: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(50.0),
                                        color: Colors.blue[50],
                                      ),
                                      child: TextButton(
                                          child: Text(
                                            'Edit Profile',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          onPressed: () {
                                            UpdateUserInfoModel update =
                                                UpdateUserInfoModel(
                                                    id: state.user.id,
                                                    username:
                                                        state.user.username);
                                            Navigator.of(context)
                                                .push(MaterialPageRoute(
                                              builder: (context) =>
                                                  UpdateUserInfoView(
                                                      update, false),
                                            ));
                                          }),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => GetFreePointScreen(),
                                ));
                              },
                              child: Card(
                                margin: EdgeInsets.all(0.0),
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  alignment: Alignment.center,
                                  child: Text(
                                    'Get Free Point',
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ),
                            )
                          ],
                        );
                      }
                    } else if (state is GetUserProfileFail) {
                      return Center(
                        child: Text(state.error),
                      );
                    } else {
                      return Card(
                        margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 5.0),
                        child: Column(
                          children: [
                            AppBar(
                              elevation: 0.0,
                              title: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Manga',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    'Turn',
                                    style: TextStyle(
                                        color: Colors.indigo,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              automaticallyImplyLeading: false,
                            ),
                            ListTile(
                              leading: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.account_balance_wallet,
                                  size: 30,
                                ),
                              ),
                              title: Text('You have'),
                              subtitle: Text('0 Point'),
                              trailing: IconButton(
                                icon: Icon(Icons.arrow_forward_ios),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),

                Card(
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: BlocBuilder<PointPurchaseStatusCubit,
                      PointPurchaseStatusState>(
                    builder: (context, state) {
                      if (state is PointPurchaseStatusSuccess) {
                        if (state.purchaseModel == null) {
                          return Container();
                        } else {
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 8.0),
                                child: Header(
                                    context, 'Latest Point Purchase Status',
                                    mm: true),
                              ),
                              ListTile(
                                leading: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Icon(
                                    Icons.monetization_on,
                                    size: 30,
                                  ),
                                ),
                                title: state.purchaseModel!.status == "PENDING"
                                    ? Text(
                                        'Request is pending',
                                        style: TextStyle(
                                            fontSize: 14, color: Colors.black),
                                      )
                                    : state.purchaseModel!.status == "REJECT"
                                        ? Text(
                                            'Purchased Rejected',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.red),
                                          )
                                        : Text(
                                            'Purchased Successfully',
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.green),
                                          ),
                                subtitle: Text(
                                  'Point - ${state.purchaseModel!.point} | ${timeago.format(DateTime.fromMicrosecondsSinceEpoch(state.purchaseModel!.requestedDateInMilliSeconds * 1000))}',
                                  style: TextStyle(fontSize: 12),
                                ),
                                trailing: IconButton(
                                  icon: Icon(Icons.more_vert),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title: Text('Purchase History'),
                                          ),
                                          body: PurchaseHistory()),
                                    ));
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                      } else if (state is PointPurchaseStatusFail) {
                        return Container();
                      } else {
                        return Container();
                      }
                    },
                  ),
                ),

                BlocBuilder<ResumeCubit, ResumeState>(
                  builder: (context, state) {
                    if (state is ResumeSuccess) {
                      List<ResumeModel> resumeList =
                          state.resumeList.values.toList();
                      resumeList
                          .sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

                      return Container(
                        height: state.resumeList.values.length == 0 ? 0 : 250,
                        child: Card(
                          shape: BeveledRectangleBorder(),
                          margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                          clipBehavior: Clip.antiAlias,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                        child: Header(context, 'Reading List')),
                                    IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () {
                                          BlocProvider.of<ResumeCubit>(context)
                                              .removeAll();
                                        })
                                  ],
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ListView.separated(
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                        width: 10,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount: resumeList.length,
                                      itemBuilder: (context, index) {
                                        ResumeModel model = resumeList[index];

                                        return InkWell(
                                          onTap: () {
                                            Navigator.pushNamed(
                                                context, ComicDetail.routeName,
                                                arguments: [
                                                  null,
                                                  model.mangaId
                                                ]);
                                          },
                                          child: Column(
                                            children: [
                                              ClipRRect(
                                                child: CachedNetworkImage(
                                                  imageUrl: model.cover,
                                                  height: 100,
                                                  width: 100,
                                                  fit: BoxFit.cover,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(5.0),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Container(
                                                width: 100,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      "${model.title}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    Text(
                                                      "${model.chapterName}",
                                                      textAlign:
                                                          TextAlign.center,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    } else if (state is ResumeFail) {
                      return Center(child: Text(state.error));
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                ),
                // Card(
                //   elevation: 0.0,
                //   shape: BeveledRectangleBorder(),
                //   margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                //   clipBehavior: Clip.antiAlias,
                //   child: Padding(
                //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //     child: Header(context, 'Notification'),
                //   ),
                // ),
                Container(
                    height: 250,
                    child: Card(
                        child: Column(
                      children: [
                        Header(context, 'Your Favourite List'),
                        Expanded(child: FavMangaView()),
                      ],
                    ))),
                ValueListenableBuilder(
                  valueListenable: Hive.box<FeedModel>('feed').listenable(),
                  builder: (context, Box<FeedModel> box, _) {
                    if (box.values.isEmpty)
                      return Container(
                        height: 100,
                        child: Center(child: Text("Your feed is empty.")),
                      );

                    List<FeedModel> boxValues = box.values.toList();
                    if (boxValues.length > 30) box.deleteAt(0);
                    boxValues
                        .sort((a, b) => a.timeStamp!.compareTo(b.timeStamp!));
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: boxValues.length,
                      itemBuilder: (context, index) {
                        FeedModel feed =
                            box.getAt(boxValues.length - index - 1)!;
                        if (feed.updateType ==
                            UpdateType.mangaInsert.toString()) {
                          return MangaInsertNotiWidget(
                              feed, box, boxValues.length, index, context);
                        } else if (feed.updateType ==
                            UpdateType.chapterInsert.toString()) {
                          return ChapterInsertNotiWidget(
                              feed, box, boxValues.length, index, context);
                        } else if (feed.updateType ==
                            UpdateType.chapterUpdate.toString()) {
                          return ChapterUpdateNotiWidget(
                              feed, box, boxValues.length, index, context);
                        } else {
                          return PostNotiWidget(
                              feed, box, boxValues.length, index, context);
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
