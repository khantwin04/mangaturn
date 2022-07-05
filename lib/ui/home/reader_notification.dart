import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/config/utility.dart';
import 'package:mangaturn/services/bloc/firestore/notification_cubit.dart';

class ReaderNotification extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        actions: [
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                BlocProvider.of<NotificationCubit>(context)
                    .deleteAllNotification();
              })
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoading) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else if (state is NotificationSuccess) {
                final notifications = state.notifications;

                notifications.sort((nt1, nt2) => nt2.id!.compareTo(nt1.id!));
                return ListView.builder(
                  itemCount: notifications.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    print(notification.title);
                    return Container(
                      color: notification.see == 'true'
                          ? Colors.grey[100]
                          : Colors.transparent,
                      child: ListTile(
                        onLongPress: () {
                          BlocProvider.of<NotificationCubit>(context)
                              .deleteNotificationById(notification.id!);
                        },
                        onTap: () {
                          Utility.routeOnNoti(notification, context);
                        },
                        leading: ClipRRect(
                          borderRadius:
                          BorderRadius.all(Radius.circular(5.0)),
                          child: CachedNetworkImage(
                            width: 50,
                            imageUrl: notification.mangaCover,
                            errorWidget: (_, __, ___) =>
                                Center(
                                  child: Icon(Icons.error),
                                ),
                            placeholder: (_, __) =>
                                Center(
                                  child: CircularProgressIndicator(),
                                ),
                            fit: BoxFit.cover,
                          ),
                        ),
                        title: Text(notification.title),
                        subtitle: Text(notification.body),
                      ),
                    );
                  },
                );
              } else if (state is NotificationFail) {
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
