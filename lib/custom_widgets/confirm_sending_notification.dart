import 'package:flutter/material.dart';

Future<dynamic> confirmSendNoti(BuildContext context) {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Send Notification to Reader?'),
      content: Text(
          'Reader will get a new notification about your uploaded new chapter or new manga.'),
      actions: [
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text('I want to send')),
        ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text('I don\'t')),
      ],
    ),
  );
}
