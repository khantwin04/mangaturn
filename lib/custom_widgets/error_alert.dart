import 'package:flutter/material.dart';

Future<void> AlertError({required BuildContext context,required String title, required String content}){
  return showDialog(
    barrierDismissible: false,
      context: context, builder: (BuildContext context){
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        RaisedButton(
          onPressed: (){
            Navigator.of(context).pop();
          },
          child: Text('Okay',),
          color: Colors.red,
        ),
      ],
    );
  });
}