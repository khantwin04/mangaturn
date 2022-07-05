import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:mangaturn/config/local_storage.dart';
import 'package:mangaturn/models/auth_models/sign_up_model.dart';
import 'package:mangaturn/ui/auth/auth_functions.dart';

Future<dynamic> limitMangaViewAlertBox(BuildContext context) async {
  bool show = await LocalStorage.getMangaShowLimit() ?? true;
  return showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(builder: (context, setState) {
        return AlertDialog(
          title: Text(
            'ပြသမှုကန့်သတ်ရန်ရွေးပါ',
            style: TextStyle(fontSize: 15),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                  title: Text('18+တွေပြလို့ရပါတယ်။'),
                  value: true,
                  groupValue: show,
                  onChanged: (bool? data) {
                    setState(() {
                      show = data ?? true;
                    });
                  }),
              RadioListTile(
                  title: Text('18+တွေမပြပါနဲ့။'),
                  value: false,
                  groupValue: show,
                  onChanged: (bool? data) {
                    setState(() {
                      show = data ?? false;
                    });
                  })
            ],
          ),
          actions: [
            TextButton(
                onPressed: () async {
                  await LocalStorage.saveMangaShowLimit(show);
                  final authData = AuthFunction.getAuthData();
                  String token = "Bearer " + authData!.accessToken;
                  AuthFunction.preLoadData(context, token);
                  Navigator.of(context).pop();
                },
                child: Text('ပြင်ဆင်မှုကိုသိမ်းဆည်းပါ'))
          ],
        );
      });
    },
  );
}
