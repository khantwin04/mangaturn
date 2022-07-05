import 'package:cached_network_image/cached_network_image.dart';
import 'package:mangaturn/models/manga_models/manga_user_model.dart';
import 'package:flutter/material.dart';


Future<dynamic> UploaderInfo(BuildContext context, UploadedByUserModel user) {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(icon: Icon(Icons.report), onPressed: (){

            },),
            Text(
              user.username,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18
              ),
            ),
            IconButton(icon: Icon(Icons.verified_outlined), onPressed: (){},),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: CachedNetworkImage(
                imageUrl: user.profileUrl!,
                placeholder: (_, __) => Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (_, __, ___) => Center(
                  child: Icon(Icons.error),
                ),
              ),
            ),
            Divider(
              indent: 10,
              endIndent: 10,
              thickness: 2,
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                user.description!,
                textAlign: TextAlign.justify,
              ),
            ),
            Card(
              elevation: 2.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextButton(
                      onPressed: () {},
                      child: Text(
                        'Message',
                        style: TextStyle(color: Colors.black),
                      )),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Follow',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Share',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
