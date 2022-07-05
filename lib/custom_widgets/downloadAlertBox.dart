import 'package:mangaturn/services/bloc/get/download_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<dynamic> confirmDownload(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Download Now ?'),
      actions: [
        ElevatedButton(onPressed: (){
          Navigator.of(context).pop(true);
        }, child: Text('Okay')),
        ElevatedButton(onPressed: (){
          Navigator.of(context).pop(false);
        }, child: Text('Cancel')),
      ],
    ),
  );
}
