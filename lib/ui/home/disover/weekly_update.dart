import 'package:mangaturn/custom_widgets/comic_card.dart';
import 'package:flutter/material.dart';

class WeeklyUpdateComic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 20,
        itemBuilder: (context, index) {
          //return ComicCard(context, MsmallCard: true);
          return Text('weekly');
        },
      ),
    );
  }
}
