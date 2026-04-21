import 'dart:async';
import 'dart:io';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  // Test ad unit IDs — NEVER use real IDs during development
  static String get interstitialAdUnitId {
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/4411468910';
    return 'ca-app-pub-3940256099942544/1033173712';
  }

  static String get rewardedAdUnitId {
    if (Platform.isIOS) return 'ca-app-pub-3940256099942544/1712485313';
    return 'ca-app-pub-3940256099942544/5224354917';
  }

  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoaded = false;

  /// Preloads an interstitial ad.
  Future<void> loadInterstitial() async {
    final completer = Completer<void>();

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialLoaded = true;
          completer.complete();
        },
        onAdFailedToLoad: (error) {
          _isInterstitialLoaded = false;
          completer.complete(); // graceful degradation
        },
      ),
    );

    return completer.future;
  }

  /// Shows the loaded interstitial ad.
  /// Returns a Future that completes when the ad is dismissed.
  /// If the ad isn't loaded, completes immediately (graceful degradation).
  Future<void> showInterstitial() async {
    if (!_isInterstitialLoaded || _interstitialAd == null) return;

    final completer = Completer<void>();

    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
        completer.complete();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        _isInterstitialLoaded = false;
        completer.complete();
      },
    );

    await _interstitialAd!.show();
    return completer.future;
  }

  /// Shows two interstitial ads back-to-back (for Soul Stack ad slots).
  Future<void> showDoubleInterstitial() async {
    await showInterstitial();
    await loadInterstitial();
    await showInterstitial();
  }

  void dispose() {
    _interstitialAd?.dispose();
  }
}
