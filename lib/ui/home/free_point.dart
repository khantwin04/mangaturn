import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mangaturn/custom_widgets/reward_alertBox.dart';
import 'package:mangaturn/services/bloc/ads/reward_cubit.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';

class GetFreePointScreen extends StatefulWidget {
  const GetFreePointScreen({Key? key}) : super(key: key);

  @override
  _GetFreePointScreenState createState() => _GetFreePointScreenState();
}

class _GetFreePointScreenState extends State<GetFreePointScreen> {
  Future<dynamic> getPoint(int userId) async {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('မင်္ဂလာပါဗျာ'),
          content: Text('ကြော်ငြာကြည့်တော့မလား။'),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  BlocProvider.of<RewardCubit>(context)
                      .createRewardedAd(userId);

                  rewardAlertBox(context);
                },
                child: Text('ဟုတ်ကဲ့။')),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('မှားနှိပ်တာပါ။')),
          ],
        );
      },
    );
  }

  // void checkUserWatchedAds() {
  //   bool check = BlocProvider.of<RewardCubit>(context).getWatch;
  //   if (!check) {
  //     Future.delayed(Duration.zero, () => showHelp());
  //   }
  // }

  @override
  void initState() {
    //checkUserWatchedAds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'သိရှိရမည့်အချက်များ',
          style: TextStyle(fontSize: 15),
        ),
        elevation: 0.0,
      ),
      bottomNavigationBar:
          BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
        builder: (context, state) {
          if (state is GetUserProfileSuccess) {
            return ElevatedButton(
                onPressed: () {
                  getPoint(state.user.id);
                },
                child: Text('ကြော်ငြာကြည့်မယ်'));
          } else if (state is GetUserProfileFail) {
            return Container(
              child: Center(
                child: Text(state.error),
              ),
            );
          } else {
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
      body: ListView(
        children: [
          BlocBuilder<GetUserProfileCubit, GetUserProfileState>(
            builder: (context, state) {
              if (state is GetUserProfileSuccess) {
                return Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Card(
                    elevation: 5.0,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('သင့်မှာရှိသောပွိုင့်ပမာဏ : '),
                          Text(state.user.point.toString()),
                        ],
                      ),
                    ),
                  ),
                );
              } else if (state is GetUserProfileFail) {
                return Container(
                  height: 100,
                  child: Center(
                    child: Text(state.error),
                  ),
                );
              } else {
                return Container(
                  height: 100,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text('၁'),
            ),
            title: Text(
                '၂နာရီအတွင်း ကြော်ငြာသုံးခါဆက်တိုက်ကြည့်ပြီး ပွိုင့်ရယူနိုင်ပါသည်။'),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text('၂'),
            ),
            title: Text(
                '၂နာရီအတွင်း ကြော်ငြာသုံးခါပြည့်အောင်ကြည့်ပြီးပါက နောက်ထပ်၂နာရီနေမှ ကြော်ငြာပြန်ကြည့်လို့ရမည်ဖြစ်ပါသည်။'),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text('၃'),
            ),
            title: Text(
                'ကြော်ငြာကို ပြီးဆုံးသည်အထိ ကြည့်မှ ပွိုင့်ရမှာဖြစ်ပါတယ်။ မပြီးသေးဘဲပိတ်လိုက်လျှင် ပွိုင့်မရဘဲ အခွင့်အရေးတစ်ခါဆုံးရှုံးမှာဖြစ်ပါတယ်။'),
          ),
          ListTile(
            leading: CircleAvatar(
              child: Text('၄'),
            ),
            title: Text('ကြော်ငြာတစ်ခါကြည့်လျှင် (၂)ပွိုင့်ရရှိမည်ဖြစ်ပါသည်။'),
          ),
        ],
      ),
    );
  }
}
