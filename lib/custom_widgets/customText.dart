import 'package:flutter/material.dart';

class CustomTextBox extends StatelessWidget {
  CustomTextBox(
      {required this.text,
      required this.color1,
      required this.color2,
      required this.align,
      required this.fontSize});

  final String text;
  final Color color1;
  final Color color2;
  final TextAlign align;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(
          color: color1,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(5.0),
        boxShadow: [BoxShadow(color: color2, offset: Offset(0, 1))],
      ),
      padding: EdgeInsets.all(5.0),
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize),
        textAlign: align,
      ),
    );
  }
}
