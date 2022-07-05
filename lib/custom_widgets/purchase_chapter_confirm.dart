import 'package:mangaturn/services/bloc/post/purchase_chapter_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<dynamic> confirmPurchase(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Purchase this chapter?'),
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

Future<dynamic> PurchaseChapter(BuildContext context, String chapterName) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      content: BlocBuilder<PurchaseChapterCubit, PurchaseChapterState>(
        builder: (context, state) {
          if (state is PurchaseChapterSuccess) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Successfully purchased $chapterName', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
                SizedBox(height: 20,),
                ElevatedButton(
                  child: Text('Okay'),
                  onPressed: (){
                    Navigator.of(context).pop(true);
                  },
                ),
              ],
            );
          } else if (state is PurchaseChapterFail) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(state.error, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
                SizedBox(height: 20,),
                ElevatedButton(
                  child: Text('Okay'),
                  onPressed: (){
                    Navigator.of(context).pop(false);
                  },
                ),
              ],
            );
          }
          return Container(
            height: 50,
              child: Center(child: CircularProgressIndicator()));
        },
      ),
    ),
  );
}
