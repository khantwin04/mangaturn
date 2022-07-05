import 'package:flutter/material.dart';

Widget Header(BuildContext context, String title,
    {bool seeMore = false,
    Widget? button,
    Color color = Colors.black,
    TextAlign align = TextAlign.left,
    bool mm = false}) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(10.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          textAlign: align,
          style: TextStyle(
              fontSize: mm ? 15 : 18,
              color: color,
              fontWeight: FontWeight.w400),
        ),
        seeMore ? button ?? Icon(Icons.swap_horiz) : Container(),
      ],
    ),
  );
}
