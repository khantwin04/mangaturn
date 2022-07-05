import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/services/bloc/ads/free_point_cubit.dart';
import 'package:mangaturn/services/bloc/ads/popup_cubit.dart';
import 'package:mangaturn/services/bloc/ads/reward_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';

Future<dynamic> rewardAlertBox(BuildContext context) async {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return BlocConsumer<RewardCubit, RewardState>(
        listener: (context, state) {
          if (state is RewardSuccess) {
            BlocProvider.of<RewardCubit>(context).showRewardedAd();
          }
        },
        builder: (context, state) {
          if (state is RewardSuccess) {
            return AlertDialog(
                title: Text('ခဏလေးပါ'), content: Text('Showing ads for you.'));
          } else if (state is RewardFail) {
            return AlertDialog(
              title: Text('ပွိုင့်ယူမှုအခြေအနေ'),
              content: Text(state.error.toString()),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      BlocProvider.of<GetUserProfileCubit>(context)
                          .getUserProfile();
                    },
                    child: Text('နားလည်ပါပြီ'))
              ],
            );
          } else {
            return AlertDialog(
                title: Text('ခဏစောင့်ပါ'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                        child: Text(
                      'ကြော်ငြာ Loading လုပ်နေပါပြီ',
                      textAlign: TextAlign.center,
                    )),
                  ],
                ));
          }
        },
      );
    },
  );
}

Future<dynamic> downloadAlertBox(BuildContext context) async {
  return showDialog(
    barrierDismissible: false,
    context: context,
    builder: (context) {
      return BlocConsumer<PopupCubit, PopupState>(
        listener: (context, state) {
          if (state is PopUpSuccess) {
            BlocProvider.of<PopupCubit>(context).showInterstitialAd();
          }
        },
        builder: (context, state) {
          if (state is PopUpSuccess) {
            return AlertDialog(
                title: Text('ခဏလေးပါ'), content: Text('Showing ads for you.'));
          } else if (state is PopUpFail) {
            return AlertDialog(
              title: Text('Dear Reader,'),
              content: Text("Failed to load ads."),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('နားလည်ပါပြီ'))
              ],
            );
          } else {
            return AlertDialog(
                title: Text('ခဏစောင့်ပါ'),
                content: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                        child: Text(
                      'ကြော်ငြာ Loading လုပ်နေပါပြီ',
                      textAlign: TextAlign.center,
                    )),
                  ],
                ));
          }
        },
      );
    },
  );
}
