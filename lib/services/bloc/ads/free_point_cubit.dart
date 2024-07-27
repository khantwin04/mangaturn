import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:mangaturn/config/constants.dart';

part 'free_point_state.dart';

class FreePointCubit extends Cubit<FreePointState> {
  FreePointCubit() : super(FreePointInitial());

  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;

  bool watched = false;

  set setWatch(bool data) => watched = data;

  bool get getWatch => watched;

  void createRewardedAd() {
    emit(FreePointLoading());

    RewardedAd.load(
        adUnitId: Constant.downloadRewardId,
        request: AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            _rewardedAd = ad;
            _numRewardedLoadAttempts = 0;
            setWatch = true;
            emit(FreePointSuccess());
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
            _rewardedAd = null;
            _numRewardedLoadAttempts += 1;
            if (_numRewardedLoadAttempts <= 3) {
              createRewardedAd();
            }
            setWatch = true;
            emit(FreePointFail('Thank You Very Much!'));
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
        emit(FreePointFail("Ads Fail to load"));
      },
    );

    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        emit(FreePointFail('Thank You Very Much!'));

        print('$ad with reward $RewardItem(${reward.amount}, ${reward.type}');
      },
    );
    _rewardedAd = null;
  }
}
