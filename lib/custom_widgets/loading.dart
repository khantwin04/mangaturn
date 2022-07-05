import 'package:flutter/material.dart';


Future<bool> back() async {
  return false;
}

Future<dynamic> Loading(BuildContext context){
  return showDialog(
    context: context,
    builder: (context) => WillPopScope(
      onWillPop: back,
      child: AbsorbPointer(
        absorbing: true,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    ),
  );
}