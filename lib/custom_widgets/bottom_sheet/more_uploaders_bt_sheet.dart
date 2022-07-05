import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

Future<dynamic> MoreUploadersInfo(BuildContext context){
  return showMaterialModalBottomSheet(
    isDismissible: true,
    useRootNavigator: true,
    context: context,
    builder: (context) => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: Icon(Icons.read_more),
          title: Text("View Info"),
        ),
        ListTile(
          leading: Icon(Icons.mark_email_read),
          title: Text("Subscribe"),
          subtitle: Text("You will get notification when new chapter or new comic is updated."),
        ),
        ListTile(
          leading: Icon(Icons.share),
          title: Text("Share"),
        ),
      ],
    ),
  );
}