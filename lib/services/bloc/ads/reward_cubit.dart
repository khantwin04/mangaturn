import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mangaturn/config/constants.dart';
import 'package:mangaturn/services/bloc/get/get_user_profile_cubit.dart';
import 'package:path/path.dart';

part 'reward_state.dart';

class RewardCubit extends Cubit<RewardState> {
  RewardCubit() : super(RewardInitial());

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  bool watched = false;

  set setWatch(bool data) => watched = data;

  bool get getWatch => watched;

  void createRewardedAd(int userId) {
    emit(RewardLoading());

    RewardedAd.load(
        adUnitId: Constant.helpServerRewardId,
        request: AdRequest(),
        serverSideVerificationOptions: ServerSideVerificationOptions(
          userId: userId.toString(),
        ),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
            setWatch = true;
            emit(RewardSuccess());
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= 3) {
              createRewardedAd(userId);
            }
            setWatch = true;
            emit(RewardFail(
                'အကြိမ်အရေအတွက်ပြည့်သွားပါပြီ။ နောက်၂နာရီမှ ပြန်ကြည့်ပေးပါ'));
          },
        ));
  }

  void showRewardedAd() {
    if (_rewardedAd == null) {
      print('Warning: attempt to show rewarded before loaded.');
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        // createRewardedAd();
        print('User canceled');
        // emit(RewardFail("User Canceled"));
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        // createRewardedAd();
        print('ads fail to load');
        emit(RewardFail("Ads Fail to load"));
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
      emit(RewardFail('( ${reward.amount} )ပွိုင့် ရရှိပါပြီ'));
      
      print('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
    });
    _rewardedAd = null;
  }
}
