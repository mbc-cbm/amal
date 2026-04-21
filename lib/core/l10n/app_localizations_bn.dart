// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Bengali Bangla (`bn`).
class AppLocalizationsBn extends AppLocalizations {
  AppLocalizationsBn([String locale = 'bn']) : super(locale);

  @override
  String get appName => 'আমাল';

  @override
  String get tagline => 'প্রতিটি নেক কাজ গুরুত্বপূর্ণ';

  @override
  String get welcomeTagline => 'প্রতিটি কাজ। প্রতিটি নিয়ত। প্রতিটি দিন।';

  @override
  String get tapAnywhereToContinue => 'চালিয়ে যেতে যেকোনো জায়গায় ট্যাপ করুন';

  @override
  String get noorCoins => 'নূর কয়েন';

  @override
  String noorCoinBalance(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString নূর কয়েন';
  }

  @override
  String get signInTitle => 'আমালে যোগ দিন';

  @override
  String get signInSubtitle => 'শুরু করতে আপনার অ্যাকাউন্ট তৈরি করুন';

  @override
  String get signIn => 'সাইন ইন';

  @override
  String get signUp => 'সাইন আপ';

  @override
  String get signOut => 'সাইন আউট';

  @override
  String get continueWithGoogle => 'গুগল দিয়ে চালিয়ে যান';

  @override
  String get continueWithApple => 'অ্যাপল দিয়ে চালিয়ে যান';

  @override
  String get emailAndPassword => 'ইমেইল ও পাসওয়ার্ড';

  @override
  String get emailLabel => 'ইমেইল';

  @override
  String get passwordLabel => 'পাসওয়ার্ড';

  @override
  String get confirmPasswordLabel => 'পাসওয়ার্ড নিশ্চিত করুন';

  @override
  String get createAccount => 'অ্যাকাউন্ট তৈরি করুন';

  @override
  String get alreadyHaveAccount => 'ইতিমধ্যে অ্যাকাউন্ট আছে? সাইন ইন করুন';

  @override
  String get noAccount => 'অ্যাকাউন্ট নেই? সাইন আপ করুন';

  @override
  String get forgotPassword => 'পাসওয়ার্ড ভুলে গেছেন?';

  @override
  String get resetPassword => 'পাসওয়ার্ড রিসেট করুন';

  @override
  String resetPasswordSent(String email) {
    return '$email-এ রিসেট লিংক পাঠানো হয়েছে';
  }

  @override
  String get biometricSignIn => 'ফেস আইডি / ফিঙ্গারপ্রিন্ট দিয়ে সাইন ইন করুন';

  @override
  String get enableBiometric => 'ফেস আইডি / ফিঙ্গারপ্রিন্ট চালু করুন';

  @override
  String get enableBiometricSubtitle => 'পরের বার দ্রুত সাইন ইন করুন';

  @override
  String get biometricPrompt => 'আমালে প্রবেশ করতে যাচাই করুন';

  @override
  String get usePinInstead => 'পিন ব্যবহার করুন';

  @override
  String get selectLanguageTitle => 'আপনার ভাষা বেছে নিন';

  @override
  String get selectLanguageSubtitle => 'সেটিংসে যেকোনো সময় পরিবর্তন করা যাবে';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBengali => 'বাংলা';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get languageArabic => 'العربية';

  @override
  String get prayerTraditionTitle => 'আপনার নামাজের ঐতিহ্য';

  @override
  String get prayerTraditionSubtitle =>
      'এটি আপনার আযান অডিও এবং নামাজের সময় গণনা পদ্ধতি নির্ধারণ করে';

  @override
  String get sunni => 'সুন্নি';

  @override
  String get shia => 'শিয়া';

  @override
  String get continueButton => 'চালিয়ে যান';

  @override
  String get calculationMethodTitle => 'গণনা পদ্ধতি';

  @override
  String get calculationMethodSubtitle =>
      'আপনার অঞ্চলে নামাজের সময় গণনার পদ্ধতি বেছে নিন';

  @override
  String get profileSetupTitle => 'আপনার প্রোফাইল সেট করুন';

  @override
  String get profileSetupSubtitle =>
      'আপনার নাম দিন — পরে যেকোনো সময় পরিবর্তন করা যাবে';

  @override
  String get nameLabel => 'আপনার নাম';

  @override
  String get addPhoto => 'ছবি যোগ করুন';

  @override
  String get changePhoto => 'ছবি পরিবর্তন করুন';

  @override
  String get skip => 'এড়িয়ে যান';

  @override
  String get saveAndContinue => 'সংরক্ষণ করুন ও চালিয়ে যান';

  @override
  String get notificationTitle => 'সংযুক্ত থাকুন';

  @override
  String get notificationDescription =>
      'নামাজের সময়, সোল স্ট্যাক রিমাইন্ডার, YWTL ইম্প্যাক্ট ভিডিও, স্ট্রিক রিমাইন্ডার এবং গার্ডেন সতর্কতা';

  @override
  String get allowNotifications => 'নোটিফিকেশন অনুমতি দিন';

  @override
  String get maybeLater => 'হয়তো পরে';

  @override
  String welcomeToAmalTitle(String name) {
    return 'স্বাগতম, $name';
  }

  @override
  String get impactMessage =>
      'প্রতিবার আপনি আমাল ব্যবহার করলে, বাস্তব মানুষেরা সদকা পান। আপনার দেখার সময় বাস্তব পরিবর্তন আনে।';

  @override
  String get enterAmal => 'আমালে প্রবেশ করুন';

  @override
  String get errorEmailAlreadyInUse =>
      'এই ইমেইলটি ইতিমধ্যে নিবন্ধিত। সাইন ইন করার চেষ্টা করুন।';

  @override
  String get errorWeakPassword => 'পাসওয়ার্ড কমপক্ষে ৮ অক্ষরের হতে হবে।';

  @override
  String get errorInvalidEmail => 'একটি বৈধ ইমেইল ঠিকানা লিখুন।';

  @override
  String get errorWrongPassword => 'ভুল পাসওয়ার্ড। আবার চেষ্টা করুন।';

  @override
  String get errorUserNotFound => 'এই ইমেইলে কোনো অ্যাকাউন্ট পাওয়া যায়নি।';

  @override
  String get errorNetworkRequest =>
      'সংযোগ ত্রুটি। আপনার ইন্টারনেট পরীক্ষা করুন।';

  @override
  String get errorSignInFailed => 'সাইন ইন ব্যর্থ হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get passwordsDoNotMatch => 'পাসওয়ার্ড মিলছে না।';

  @override
  String get errorGeneric => 'কিছু একটা ভুল হয়েছে। আবার চেষ্টা করুন।';

  @override
  String get loading => 'লোড হচ্ছে…';

  @override
  String get retry => 'আবার চেষ্টা করুন';

  @override
  String get home => 'হোম';

  @override
  String get quickActions => 'দ্রুত কার্যক্রম';

  @override
  String get earn => 'আয় করুন';

  @override
  String get garden => 'বাগান';

  @override
  String get community => 'সম্প্রদায়';

  @override
  String get prayerTime => 'নামাজের সময়';

  @override
  String get qibla => 'কিবলা';

  @override
  String get qiblaPermissionNeeded =>
      'কিবলার দিক নির্ধারণের জন্য লোকেশন অনুমতি প্রয়োজন। অনুগ্রহ করে লোকেশন সার্ভিস চালু করুন।';

  @override
  String get qiblaOpenSettings => 'সেটিংস খুলুন';

  @override
  String get qiblaCalibrationPrompt =>
      'কম্পাসের নির্ভুলতা কম। ক্যালিব্রেট করতে ফোনটি ৮ আকৃতিতে নাড়ান।';

  @override
  String get qiblaKaabaLabel => 'কাবা';

  @override
  String get qiblaBearingLabel => 'কিবলার দিক';

  @override
  String get tasbeeh => 'তাসবিহ';

  @override
  String get jannahGarden => 'জান্নাত গার্ডেন';

  @override
  String get noorWallet => 'নূর ওয়ালেট';

  @override
  String get soulStack => 'সোল স্ট্যাক';

  @override
  String get ywtl => 'তুমি দেখো, তারা বাঁচে';

  @override
  String get amalTracker => 'আমাল ট্র্যাকার';

  @override
  String get amalGallery => 'আমাল গ্যালারি';

  @override
  String get ramadan => 'রমজান';

  @override
  String get ramadanCountdown => 'রমজান কাউন্টডাউন';

  @override
  String ramadanDaysRemaining(int days, int hours, int minutes) {
    return 'রমজান শুরু হতে $days দিন, $hours ঘণ্টা, $minutes মিনিট বাকি';
  }

  @override
  String get ramadanSuhoor => 'সেহরি';

  @override
  String get ramadanIftar => 'ইফতার';

  @override
  String get ramadanLogFast => 'আজকের রোজা লগ করুন';

  @override
  String get ramadanFastLogged => 'রোজা লগ হয়েছে';

  @override
  String get ramadanTarawih => 'তারাবীহ';

  @override
  String get ramadanTarawihLogged => 'তারাবীহ সম্পন্ন';

  @override
  String ramadanFastsCompleted(int count) {
    return '$count রোজা সম্পন্ন';
  }

  @override
  String get ramadanLastTenNights => 'শেষ ১০ রাত';

  @override
  String ramadanDay(int day) {
    return 'দিন $day';
  }

  @override
  String get ramadanMubarak => 'রমজান মোবারক';

  @override
  String get ramadanLogTarawih => 'তারাবীহ লগ করুন';

  @override
  String get ramadanSeekLaylatulQadr => 'বেজোড় রাতে লাইলাতুল কদর তালাশ করুন';

  @override
  String get profile => 'প্রোফাইল';

  @override
  String get settings => 'সেটিংস';

  @override
  String prayerLogged(int coins) {
    return 'নামাজ লগ হয়েছে! +$coins নূর কয়েন';
  }

  @override
  String fastLogged(int coins) {
    return 'রোজা লগ হয়েছে! +$coins নূর কয়েন';
  }

  @override
  String tasbeehComplete(int coins) {
    return 'তাসবিহ সম্পন্ন! +$coins নূর কয়েন';
  }

  @override
  String get fajr => 'ফজর';

  @override
  String get dhuhr => 'যোহর';

  @override
  String get asr => 'আসর';

  @override
  String get maghrib => 'মাগরিব';

  @override
  String get isha => 'ইশা';

  @override
  String get sunrise => 'সূর্যোদয়';

  @override
  String homeGreeting(String name) {
    return 'আস্সালামু আলাইকুম, $name';
  }

  @override
  String get yourBalance => 'আপনার ব্যালেন্স';

  @override
  String get setLocationPrompt => 'নামাজের সময়ের জন্য আপনার অবস্থান সেট করুন';

  @override
  String prayerProgress(int done, int total) {
    return '$totalটির মধ্যে $doneটি নামাজ';
  }

  @override
  String get viewAllPrayers => 'সব নামাজ দেখুন';

  @override
  String get prayerTimesTitle => 'নামাজের সময়সূচী';

  @override
  String get todaysPrayers => 'আজকের নামাজ';

  @override
  String get modeSilent => 'নীরব';

  @override
  String get modeNotification => 'বিজ্ঞপ্তি';

  @override
  String get modeAzan => 'আযান';

  @override
  String get notificationSettings => 'বিজ্ঞপ্তি সেটিংস';

  @override
  String get changeLocation => 'পরিবর্তন';

  @override
  String get useGps => 'GPS ব্যবহার করুন';

  @override
  String get cityLabel => 'শহর';

  @override
  String get countryLabel => 'দেশ';

  @override
  String get search => 'অনুসন্ধান';

  @override
  String get usingCachedData => 'ক্যাশ ডেটা ব্যবহার হচ্ছে';

  @override
  String lastUpdated(String age) {
    return 'আপডেট হয়েছে $age';
  }

  @override
  String get tasbeehSubhanallah => 'সুবহানাল্লাহ';

  @override
  String get tasbeehAlhamdulillah => 'আলহামদুলিল্লাহ';

  @override
  String get tasbeehAllahuAkbar => 'আল্লাহু আকবার';

  @override
  String get tasbeehAstaghfirullah => 'আস্তাগফিরুল্লাহ';

  @override
  String get tasbeehTarget => 'লক্ষ্য';

  @override
  String get tasbeehReset => 'রিসেট';

  @override
  String get tasbeehSessionComplete => 'সেশন সম্পন্ন';

  @override
  String get tasbeehSessionHistory => 'সেশন ইতিহাস';

  @override
  String get tasbeehTotalCount => 'মোট গণনা';

  @override
  String get tasbeehLongestSession => 'দীর্ঘতম সেশন';

  @override
  String tasbeehCoinsAwarded(int coins) {
    return '+$coins নূর কয়েন';
  }

  @override
  String get amalCategoryAll => 'সব';

  @override
  String get amalCategoryPrayer => 'নামাজ';

  @override
  String get amalCategoryFamily => 'পরিবার';

  @override
  String get amalCategoryCommunity => 'সম্প্রদায়';

  @override
  String get amalCategorySelf => 'নিজ';

  @override
  String get amalCategoryKnowledge => 'জ্ঞান';

  @override
  String get amalCategoryCharity => 'দান';

  @override
  String get amalSearchHint => 'ভালো কাজ খুঁজুন...';

  @override
  String get amalNoResults => 'কোনো আমাল পাওয়া যায়নি';

  @override
  String amalNoorCoinsReward(int coins) {
    return '$coins NC';
  }

  @override
  String get amalCompleteButton => 'এই আমাল সম্পন্ন করুন';

  @override
  String get amalCompleted => 'সম্পন্ন';

  @override
  String amalCompletedTimes(int count) {
    return '$count বার সম্পন্ন';
  }

  @override
  String get amalSource => 'সূত্র';

  @override
  String get amalDifficultyEasy => 'সহজ';

  @override
  String get amalDifficultyMedium => 'মাঝারি';

  @override
  String get amalDifficultyHigh => 'কঠিন';

  @override
  String get amalOneTime => 'একবার';

  @override
  String get amalDaily => 'দৈনিক';

  @override
  String get amalWeekly => 'সাপ্তাহিক';

  @override
  String get amalOngoing => 'চলমান';

  @override
  String get amalWatchToComplete => 'সম্পন্ন করতে দেখুন';

  @override
  String get trackerMyTracker => 'আমার ট্র্যাকার';

  @override
  String get trackerFavourites => 'প্রিয়';

  @override
  String get trackerTodaysAmal => 'আজকের আমাল';

  @override
  String get trackerDailyGoal => 'দৈনিক লক্ষ্য';

  @override
  String get trackerSetGoal => 'একটি দৈনিক লক্ষ্য নির্ধারণ করুন';

  @override
  String trackerGoalProgress(int done, int total) {
    return 'আজ $totalটির মধ্যে $doneটি সম্পন্ন';
  }

  @override
  String get trackerTotalAmals => 'মোট আমাল';

  @override
  String get trackerTotalCoins => 'অর্জিত নূর কয়েন';

  @override
  String get trackerDailyStreak => 'দৈনিক ধারা';

  @override
  String get trackerLongestDaily => 'সর্বোচ্চ দৈনিক';

  @override
  String get trackerWeeklyStreak => 'সাপ্তাহিক ধারা';

  @override
  String get trackerLongestWeekly => 'সর্বোচ্চ সাপ্তাহিক';

  @override
  String get trackerRecentActivity => 'সাম্প্রতিক কার্যকলাপ';

  @override
  String get trackerEncouragement =>
      'প্রতিটি ভালো কাজ গুরুত্বপূর্ণ। আজই শুরু করুন!';

  @override
  String get trackerNoCompletions =>
      'এখনো কোনো সম্পন্নতা নেই। আপনার যাত্রা শুরু করুন!';

  @override
  String get trackerNoFavourites =>
      'এখনো কোনো প্রিয় নেই। যেকোনো আমালে হার্ট ট্যাপ করে এখানে সংরক্ষণ করুন।';

  @override
  String get soulStackRise => 'রাইজ — সকাল';

  @override
  String get soulStackShine => 'শাইন — দুপুর';

  @override
  String get soulStackGlow => 'গ্লো — রাত';

  @override
  String soulStackProgress(int done) {
    return '$done/৫ ভিডিও';
  }

  @override
  String soulStackCompletedTimes(int count) {
    return 'আজ $count বার সম্পন্ন';
  }

  @override
  String get soulStackStartStack => 'স্ট্যাক শুরু করুন';

  @override
  String get soulStackStart => 'শুরু';

  @override
  String get soulStackReady => 'প্রস্তুত';

  @override
  String get soulStackSwipeUp => 'চালিয়ে যেতে উপরে সোয়াইপ করুন';

  @override
  String get soulStackWhatIsRise =>
      'রাইজ আপনার সকালের দোয়া স্ট্যাক। ৫টি সুন্দর দোয়ার ভিডিও দেখে নিয়তের সাথে দিন শুরু করুন। আপনার দেখার সময় সদকা তৈরি করে।';

  @override
  String get soulStackWhatIsShine =>
      'শাইন আপনার দুপুরের দোয়া স্ট্যাক। ৫টি দোয়ার সাথে একটু বিরতি নিন। আপনার প্রতিটি মুহূর্ত সদকা হিসেবে কাজ করে।';

  @override
  String get soulStackWhatIsGlow =>
      'গ্লো আপনার সন্ধ্যার দোয়া স্ট্যাক। ৫টি সুন্দর দোয়ার মাধ্যমে দিন শেষ করুন। আপনার দেখার সময় বাস্তব জীবন পরিবর্তন করে।';

  @override
  String get soulStackMashaAllah => 'মাশাআল্লাহ!';

  @override
  String soulStackCoinsEarned(int coins) {
    return '+$coins নূর কয়েন';
  }

  @override
  String get soulStackGardenAccess =>
      '৬ ঘণ্টা জান্নাত গার্ডেন অ্যাক্সেস যোগ হয়েছে';

  @override
  String get soulStackSadaqaMessage =>
      'আপনার দেখার সময় বাস্তব সদকায় অবদান রেখেছে';

  @override
  String get soulStackWatchYwtl => 'আজকের ইম্প্যাক্ট ভিডিও দেখুন';

  @override
  String get soulStackDone => 'সম্পন্ন';

  @override
  String get gardenLocked =>
      'আপনার বাগানে প্রবেশ করতে একটি সোল স্ট্যাক সম্পন্ন করুন (প্রতি স্ট্যাকে ৬ ঘণ্টা)';

  @override
  String get gardenGoToSoulStack => 'সোল স্ট্যাকে যান';

  @override
  String get gardenLocalSaveWarning =>
      'আপনার বাগান এই ডিভাইসে সংরক্ষিত। অ্যাপ মুছে ফেললে বাগান হারাবেন। ক্লাউড ব্যাকআপ শীঘ্রই আসছে।';

  @override
  String get gardenIUnderstand => 'আমি বুঝেছি';

  @override
  String gardenAccessRemaining(String time) {
    return 'বাগানে প্রবেশ: $time বাকি';
  }

  @override
  String get gardenPremiumOpen => 'প্রিমিয়াম — সর্বদা খোলা';

  @override
  String get gardenInnerCircle => 'ইনার সার্কেল';

  @override
  String get gardenOuterCircle => 'আউটার সার্কেল';

  @override
  String get gardenAssetStore => 'অ্যাসেট স্টোর';

  @override
  String get gardenRestoreWithCoins => 'নূর কয়েন দিয়ে পুনরুদ্ধার';

  @override
  String get gardenRestoreInstantly => 'তাৎক্ষণিক পুনরুদ্ধার';

  @override
  String get gardenInsufficientCoins =>
      'পর্যাপ্ত নূর কয়েন নেই — আরও উপার্জনে সোল স্ট্যাক সম্পন্ন করুন';

  @override
  String get gardenShareAmal => 'আমাল শেয়ার করুন';

  @override
  String get gardenReferralCode => 'আপনার রেফারেল কোড';

  @override
  String get gardenIntensityLow =>
      'বীজ রোপণ করুন। অন্যদের যাত্রা শুরু করতে আমন্ত্রণ জানান।';

  @override
  String get gardenIntensityMedium =>
      'আপনার সদকায়ে জারিয়াহ বাড়ছে। মাশাআল্লাহ।';

  @override
  String get gardenIntensityHigh =>
      'একটি সুন্দর রেইনফরেস্ট, যাদের আমালে এনেছেন তাদের দ্বারা জীবিত।';

  @override
  String get gardenIntensityMax =>
      'সুবহানআল্লাহ। আপনার সদকায়ে জারিয়াহ মহানদীর মতো প্রবাহিত।';

  @override
  String get gardenPlace => 'রাখুন';

  @override
  String get walletBalance => 'ব্যালেন্স';

  @override
  String walletTotalEarned(int coins) {
    return 'সর্বকালের মোট উপার্জন: $coins';
  }

  @override
  String get walletTransactionHistory => 'লেনদেনের ইতিহাস';

  @override
  String get walletLoadMore => 'আরও দেখুন';

  @override
  String get walletHowToEarn => 'কীভাবে নূর কয়েন উপার্জন করবেন';

  @override
  String get walletHowToSpend => 'নূর কয়েন দিয়ে কী কিনতে পারেন?';

  @override
  String get walletOpenGarden => 'জান্নাত গার্ডেন খুলুন';

  @override
  String get walletNoTransactions =>
      'এখনো কোনো লেনদেন নেই। নূর কয়েন উপার্জন শুরু করুন!';

  @override
  String get ywtlWatchToday => 'আজকের প্রভাব দেখুন';

  @override
  String get ywtlWatchAgain => 'আবার দেখুন';

  @override
  String get ywtlCollectCoins => 'আপনার নূর কয়েন সংগ্রহ করুন';

  @override
  String ywtlCoinsCollected(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return '+$coinsString নূর কয়েন সংগৃহীত!';
  }

  @override
  String ywtlAvailableIn(int days) {
    return '$days দিনে';
  }

  @override
  String get ywtlPreviousWeeks =>
      'আগের সপ্তাহগুলো আমাদের ইউটিউব চ্যানেলে পাওয়া যায়';

  @override
  String get ywtlThisWeek => 'এই সপ্তাহ';

  @override
  String get ywtlMonday => 'সোম';

  @override
  String get ywtlTuesday => 'মঙ্গল';

  @override
  String get ywtlWednesday => 'বুধ';

  @override
  String get ywtlThursday => 'বৃহ';

  @override
  String get ywtlFriday => 'শুক্র';

  @override
  String get ywtlSaturday => 'শনি';

  @override
  String get ywtlSunday => 'রবি';

  @override
  String get settingsNotifications => 'বিজ্ঞপ্তি';

  @override
  String get settingsPrayerReminders => 'নামাজের রিমাইন্ডার';

  @override
  String get settingsSoulStackReminders => 'সোল স্ট্যাক রিমাইন্ডার';

  @override
  String get settingsYwtlVideo => 'YWTL নতুন ভিডিও';

  @override
  String get settingsStreakAtRisk => 'স্ট্রিক ঝুঁকিতে';

  @override
  String get settingsAssetFading => 'অ্যাসেট ম্লান সতর্কতা';

  @override
  String get settingsPrayerSettings => 'নামাজ সেটিংস';

  @override
  String get settingsPrayerTradition => 'নামাজের ঐতিহ্য';

  @override
  String get settingsCalculationMethod => 'গণনা পদ্ধতি';

  @override
  String get settingsLocation => 'অবস্থান';

  @override
  String get settingsUpdateLocation => 'অবস্থান আপডেট করুন';

  @override
  String get settingsAzanAudio => 'আযান অডিও';

  @override
  String get settingsAppSettings => 'অ্যাপ সেটিংস';

  @override
  String get settingsLanguage => 'ভাষা';

  @override
  String get settingsTheme => 'থিম';

  @override
  String get settingsThemeLight => 'লাইট';

  @override
  String get settingsThemeDark => 'ডার্ক';

  @override
  String get settingsThemeSystem => 'সিস্টেম';

  @override
  String get settingsHaptic => 'হ্যাপটিক ফিডব্যাক';

  @override
  String get settingsSound => 'সাউন্ড ইফেক্ট';

  @override
  String get settingsBiometric => 'বায়োমেট্রিক লগইন';

  @override
  String get settingsStreakAtRiskDesc =>
      'স্ট্রিক ঝুঁকিতে থাকলে রাত ৮টায় জানাবে';

  @override
  String get settingsAssetFadingDesc => 'বাগানের অ্যাসেট ম্লান হলে সতর্ক করবে';

  @override
  String get settingsAzanMakkah => 'মক্কা কারী';

  @override
  String get settingsAzanMadinah => 'মদিনা কারী';

  @override
  String get settingsAzanAlAqsa => 'আল-আকসা কারী';

  @override
  String get settingsAzanMishary => 'মিশারি রাশিদ';

  @override
  String get profileMemberSince => 'সদস্য হয়েছেন';

  @override
  String get profileFree => 'ফ্রি';

  @override
  String get profilePremium => 'প্রিমিয়াম';

  @override
  String get profileReferralCode => 'রেফারেল কোড';

  @override
  String get profileTotalEarned => 'মোট অর্জিত নূর কয়েন';

  @override
  String get profileCommunityImpact => 'সম্প্রদায়ের প্রভাব';

  @override
  String get profileDataUpdated => 'ডেটা আপডেট হয়েছে';

  @override
  String get profileSubscribe => 'সাবস্ক্রাইব করুন';

  @override
  String get profileManageSubscription => 'সাবস্ক্রিপশন পরিচালনা';

  @override
  String get profileRestorePurchases => 'ক্রয় পুনরুদ্ধার';

  @override
  String get profileMonthly => 'মাসিক';

  @override
  String get profileAnnual => 'বার্ষিক';

  @override
  String get profileLogOut => 'লগ আউট';

  @override
  String get profileLogOutConfirm => 'আপনি কি নিশ্চিতভাবে লগ আউট করতে চান?';

  @override
  String get profileDeleteAccount => 'অ্যাকাউন্ট মুছুন';

  @override
  String get profileDeleteWarning =>
      'এই কাজটি স্থায়ী। আপনার সমস্ত ডেটা, নূর কয়েন এবং অগ্রগতি হারিয়ে যাবে। আপনি কি নিশ্চিত?';

  @override
  String get profileDeleteConfirmType =>
      'অ্যাকাউন্ট মুছে ফেলা নিশ্চিত করতে DELETE টাইপ করুন';

  @override
  String get profileCancel => 'বাতিল';

  @override
  String get profileSaveDiscount => '১৭% সাশ্রয়';

  @override
  String get or => 'অথবা';

  @override
  String get timeJustNow => 'এইমাত্র';

  @override
  String timeMinutesAgo(int count) {
    return '$count মিনিট আগে';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count ঘণ্টা আগে';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count দিন আগে';
  }

  @override
  String get walletSourcePrayer => 'দৈনিক নামাজ';

  @override
  String get walletSourceFast => 'রমজানের রোজা';

  @override
  String get walletSourceTasbeeh => 'তাসবীহ সেশন';

  @override
  String get walletSourceSoulStack => 'সোল স্ট্যাক';

  @override
  String get walletSourceYwtl => 'YWTL ভিডিও';

  @override
  String get walletSourceAmal => 'আমল সম্পন্ন';

  @override
  String get walletSourceGarden => 'বাগান সম্পদ';

  @override
  String get walletSpendGarden => 'জান্নাহ বাগান সম্পদ';

  @override
  String get walletSpendRestore => 'বিবর্ণ সম্পদ পুনরুদ্ধার';

  @override
  String get countdownDays => 'দিন';

  @override
  String get countdownHours => 'ঘণ্টা';

  @override
  String get countdownMinutes => 'মিনিট';

  @override
  String get remove => 'সরান';

  @override
  String get restore => 'পুনরুদ্ধার';

  @override
  String get info => 'তথ্য';

  @override
  String get ok => 'ঠিক আছে';

  @override
  String get restoreAsset => 'সম্পদ পুনরুদ্ধার';

  @override
  String get copiedToClipboard => 'ক্লিপবোর্ডে কপি হয়েছে';

  @override
  String ywtlWatchFullVideo(int coins) {
    return 'পূর্ণ ভিডিও দেখুন $coins নূর কয়েন সংগ্রহ করতে';
  }

  @override
  String get comingSoon => 'শীঘ্রই আসছে';

  @override
  String get forgotPasswordTitle => 'পাসওয়ার্ড রিসেট';

  @override
  String get forgotPasswordSubtitle =>
      'আপনার ইমেইল ঠিকানা লিখুন এবং আমরা আপনাকে পাসওয়ার্ড রিসেট লিঙ্ক পাঠাব';

  @override
  String get sendResetLink => 'রিসেট লিঙ্ক পাঠান';

  @override
  String get resetLinkSent =>
      'পাসওয়ার্ড রিসেট লিঙ্ক পাঠানো হয়েছে! আপনার ইমেইল চেক করুন।';

  @override
  String get resetLinkError =>
      'রিসেট লিঙ্ক পাঠাতে ব্যর্থ। আপনার ইমেইল যাচাই করে আবার চেষ্টা করুন।';

  @override
  String get gardenVisit => 'আপনার জান্নাহ বাগান দেখুন';

  @override
  String get soulStackSubtitle =>
      'দৈনিক দোয়া স্ট্যাকের মাধ্যমে নূর কয়েন অর্জন করুন';

  @override
  String get amalTrackerSubtitle =>
      'আপনার সৎকর্ম ট্র্যাক করুন এবং ধারাবাহিকতা তৈরি করুন';

  @override
  String get gardenAwaitsTitle => 'আপনার বাগান অপেক্ষা করছে';

  @override
  String get gardenAwaitsBody =>
      'সোল স্ট্যাক সম্পূর্ণ করুন বা একটি ভিডিও দেখুন আপনার বাগান ৬ ঘণ্টার জন্য খুলতে।';

  @override
  String get gardenSubscribe => 'সাবস্ক্রাইব';

  @override
  String get gardenCompleteSoulStack => 'সোল স্ট্যাক সম্পূর্ণ করুন';

  @override
  String get gardenWatchVideo => 'ভিডিও দেখুন';

  @override
  String get gardenNotNow => 'এখন না';

  @override
  String get gardenPremiumBadge => 'প্রিমিয়াম — সম্পূর্ণ অ্যাক্সেস';

  @override
  String get gardenWatchToUnlock => 'বাগান খুলতে ভিডিও দেখুন';

  @override
  String get shopGalleryTitle => 'পবিত্র বাগান গ্যালারি';

  @override
  String get shopFeatured => 'বিশেষ';

  @override
  String get shopAddToGarden => 'বাগানে যোগ করুন';

  @override
  String get shopInGarden => 'বাগানে আছে';

  @override
  String get shopEarnMoreNc => 'আরও অর্জন করুন';

  @override
  String get shopAll => 'সব';

  @override
  String get shopTrees => 'গাছ';

  @override
  String get shopWater => 'পানি';

  @override
  String get shopFruits => 'ফল';

  @override
  String get shopCreatures => 'প্রাণী';

  @override
  String get shopStructures => 'স্থাপনা';

  @override
  String get shopSacred => 'পবিত্র';

  @override
  String get shopUnderwater => 'পানির নিচে';

  @override
  String get shopSky => 'আকাশ';

  @override
  String get shopHayatTitle => 'আপনার জান্নাত পুনরুজ্জীবিত করুন';

  @override
  String get shopHayatDrop => 'হায়াত ড্রপ';

  @override
  String get shopHayatBloom => 'হায়াত ব্লুম';

  @override
  String get shopNcTitle => 'নূর কয়েন যোগ করুন';

  @override
  String get shopStarterNoor => 'স্টার্টার নূর';

  @override
  String get shopHandfulNoor => 'এক মুঠো নূর';

  @override
  String get shopGardensWorth => 'একটি বাগানের মূল্য';

  @override
  String get shopBlessedHarvest => 'বরকতময় ফসল';

  @override
  String get hayatLife => 'হায়াত · জীবন';

  @override
  String get hayatTagline =>
      'প্রতিটি বাগানের যত্ন দরকার। হায়াত আপনার বাগানকে পুনরুজ্জীবিত করে।';

  @override
  String get hayatDropTitle => 'হায়াত ড্রপ';

  @override
  String get hayatDropEffect => 'একটি নির্বাচিত সম্পদ পুনরুদ্ধার করে';

  @override
  String get hayatBloomTitle => 'হায়াত ব্লুম';

  @override
  String get hayatBloomEffect => 'আপনার পুরো বাগান পুনরুদ্ধার করে';

  @override
  String get hayatRestoreOne => 'একটি সম্পদ পুনরুদ্ধার';

  @override
  String get hayatRestoreAll => 'পুরো বাগান পুনরুদ্ধার';

  @override
  String get hayatOr => 'অথবা';

  @override
  String hayatYourBalance(int balance) {
    return 'আপনার ব্যালেন্স: $balance নূর কয়েন';
  }

  @override
  String get hayatSelectAsset => 'পুনরুদ্ধারের জন্য একটি সম্পদ নির্বাচন করুন';

  @override
  String get hayatRestoreThis => 'এটি পুনরুদ্ধার করবেন?';

  @override
  String plantConfirmTitle(String name, int price) {
    return '$price নূর কয়েনে $name লাগাবেন?';
  }

  @override
  String get plantIt => 'লাগান';

  @override
  String get notNow => 'এখন না';

  @override
  String get earnMorePrompt => 'এই উপহার লাগাতে আরও নূর কয়েন অর্জন করুন';

  @override
  String sellConfirmTitle(String name, int price) {
    return '$price নূর কয়েনে $name বিক্রি করবেন?';
  }

  @override
  String get sellConfirmBody => 'এটি আপনার বাগান থেকে সরিয়ে ফেলা হবে।';

  @override
  String get sellButton => 'বিক্রি';

  @override
  String get tapSlotToPlace => 'আপনার সম্পদ রাখতে একটি খালি স্লটে ট্যাপ করুন';

  @override
  String get moveAsset => 'সরান';

  @override
  String get sellAsset => 'বিক্রি';

  @override
  String get qmDua => 'দোয়া';

  @override
  String get qmHistory => 'ইসলামি ইতিহাস';

  @override
  String get qmWatchToDiscover => 'আপনার উপহার আবিষ্কার করতে দেখুন';

  @override
  String get qmMomentPassed => 'এই মুহূর্তটি পার হয়ে গেছে। নতুন একটি আসবে।';

  @override
  String get qmDiscoveryWaiting => 'আপনার আবিষ্কার এখনো অপেক্ষা করছে';

  @override
  String get qmDiscoveryBody =>
      'আপনার সময় আছে। আপনার বাগানে একটি পবিত্র উপহার আপনার জন্য অপেক্ষা করছে।';

  @override
  String get jazakAllahuKhairan => 'জাযাকাল্লাহু খাইরান';

  @override
  String get sacredContentComingSoon =>
      'পবিত্র বিষয়বস্তু শীঘ্রই আসছে। জাযাকাল্লাহু খাইরান।';

  @override
  String get returnToGarden => 'বাগানে ফিরুন';

  @override
  String get outerGardenTitle => 'আপনার বহিঃবাগান';

  @override
  String get outerGardenExplainerBody =>
      'আপনি যাকে আমলে আমন্ত্রণ জানান তার প্রতিটি কাজ আপনার বহিঃবাগানে একটি বীজ রোপণ করে। তারা যে আমল করে — আপনার বাগানে বৃষ্টি হয়। তারা যাকে আমন্ত্রণ জানায় — তাদের আমলও আপনার কাছে পৌঁছায়। এটি সাদাকা জারিয়া। যে সৎকর্ম কখনো থামে না।';

  @override
  String get outerGardenExplainerSubtext =>
      'আপনার রেফারেল নেটওয়ার্ক অসীম। প্রতিটি কাজের প্রতিধ্বনি হয়।';

  @override
  String get outerGardenEnterButton => 'আমার বাগানে প্রবেশ';

  @override
  String get myNetwork => 'আমার নেটওয়ার্ক';

  @override
  String get copyLink => 'লিঙ্ক কপি করুন';

  @override
  String get linkCopied => 'কপি হয়েছে!';

  @override
  String get shareInvite => 'শেয়ার করুন';

  @override
  String get shareInviteMessage =>
      'জান্নাহ নির্মাণে আমার সাথে যোগ দিন। প্রতিটি সৎকর্মের প্রতিধ্বনি হয়। এখানে আপনার জান্নাহ বাগান শুরু করুন:';

  @override
  String get directInvites => 'সরাসরি আমন্ত্রণ';

  @override
  String get directInvitesDesc => 'আপনার লিঙ্কের মাধ্যমে সরাসরি যোগদানকারী';

  @override
  String get theirInvites => 'তাদের আমন্ত্রণ';

  @override
  String get theirInvitesDesc =>
      'আপনার আমন্ত্রিতদের দ্বারা আমন্ত্রিত ব্যক্তিরা';

  @override
  String get totalNetwork => 'মোট নেটওয়ার্ক';

  @override
  String get totalNetworkDesc => 'প্রতিটি স্তরে আপনার সম্পূর্ণ নেটওয়ার্ক';

  @override
  String get totalNetworkAmals => 'মোট আমল';

  @override
  String get totalNetworkAmalsDesc => 'আপনার নেটওয়ার্কের সকলের সম্পন্ন আমল';

  @override
  String get rainfallToday => 'আজকের বৃষ্টি';

  @override
  String get rainfallTodayDesc =>
      'আপনার নেটওয়ার্কের আজকের কার্যকলাপ থেকে বৃষ্টি';

  @override
  String get howItWorks => 'এটি কিভাবে কাজ করে?';

  @override
  String get howItWorksBody =>
      'আপনার নেটওয়ার্কের প্রতিটি আমল আপনার বাগানে বৃষ্টি পাঠায়। আপনি যত গভীর শিকড় রোপণ করবেন — আপনার জান্নাত তত বেশি বাড়বে।';

  @override
  String get levelAlRawdah => 'আর-রওদাহ';

  @override
  String get levelAlFirdaws => 'আল-ফিরদাউস';

  @override
  String get levelAlNaim => 'আন-নাঈম';

  @override
  String get levelJannatAlMawa => 'জান্নাতুল মাওয়া';

  @override
  String welcomeToLevel(String levelName) {
    return '$levelName এ স্বাগতম';
  }

  @override
  String get verseLevel2En => 'এবং যারা ঈমান এনেছে তাদের সুসংবাদ দিন';

  @override
  String get verseLevel3En => 'নিশ্চয়ই মুত্তাকীরা থাকবে জান্নাতসমূহে';

  @override
  String get verseLevel4En => 'তাতে আছে নির্মল পানির নদীসমূহ';

  @override
  String get architectViewLabel => 'আর্কিটেক্ট ভিউ';

  @override
  String get immersionViewLabel => 'নিমগ্ন';

  @override
  String get plantSomething => 'কিছু লাগান';

  @override
  String get accessPromptTitle => 'আপনার বাগান অপেক্ষা করছে';

  @override
  String get accessPromptBody =>
      'সোল স্ট্যাক সম্পূর্ণ করুন বা ভিডিও দেখুন আপনার বাগান ৬ ঘণ্টার জন্য খুলতে।';

  @override
  String get accessSubscribeButton => 'সাবস্ক্রাইব';

  @override
  String get accessSoulStackButton => 'সোল স্ট্যাক সম্পূর্ণ করুন';

  @override
  String get accessYwtlButton => 'ভিডিও দেখুন';

  @override
  String get shopFeaturedLabel => 'এই সপ্তাহের বিশেষ';

  @override
  String get shopFilterAll => 'সব';

  @override
  String get shopFilterTrees => 'গাছ';

  @override
  String get shopFilterWater => 'পানি';

  @override
  String get shopFilterFruits => 'ফল';

  @override
  String get shopFilterCreatures => 'প্রাণী';

  @override
  String get shopFilterStructures => 'স্থাপনা';

  @override
  String get shopFilterSacred => 'পবিত্র';

  @override
  String get shopFilterUnderwater => 'পানির নিচে';

  @override
  String get shopFilterSky => 'আকাশ';

  @override
  String get shopHayatTagline =>
      'প্রতিটি বাগানের যত্ন দরকার। হায়াত আপনার বাগানকে পুনরুজ্জীবিত করে।';

  @override
  String get hayatRestoreFull => 'পুরো বাগান পুনরুদ্ধার';

  @override
  String get plantingConfirmTitle => 'আপনার জান্নাতে লাগাবেন?';

  @override
  String get plantingConfirmButton => 'লাগান';

  @override
  String get plantingNotNow => 'এখন না';

  @override
  String assetSellConfirm(String name, int nc) {
    return '$nc নূর কয়েনে $name বিক্রি করবেন?';
  }

  @override
  String get assetSellRemovalWarning => 'এটি আপনার বাগান থেকে সরিয়ে ফেলা হবে।';

  @override
  String get assetSellButton => 'বিক্রি নিশ্চিত করুন';

  @override
  String get questionMarkDua => 'দোয়া';

  @override
  String get questionMarkHistory => 'ইসলামি ইতিহাস';

  @override
  String get questionMarkWatchToDiscover => 'আপনার উপহার আবিষ্কার করতে দেখুন';

  @override
  String get questionMarkExpired =>
      'এই মুহূর্তটি পার হয়ে গেছে। নতুন একটি আসবে।';

  @override
  String get questionMarkPending =>
      'আপনার আবিষ্কার এখনো অপেক্ষা করছে। আপনার সময় আছে।';

  @override
  String get discoveryJazakAllah => 'জাযাকাল্লাহু খাইরান';

  @override
  String get outerGardenSubtitle => 'সাদাকা জারিয়া';

  @override
  String get outerGardenSkip => 'এড়িয়ে যান';

  @override
  String get referralCopied => 'কপি হয়েছে!';

  @override
  String get referralShareText => 'আমলে আমার সাথে যোগ দিন';

  @override
  String get networkDirectInvites => 'সরাসরি আমন্ত্রণ';

  @override
  String get networkTheirInvites => 'তাদের আমন্ত্রণ';

  @override
  String get networkTotal => 'মোট নেটওয়ার্ক';

  @override
  String get networkAmals => 'মোট আমল';

  @override
  String get networkRainfallToday => 'আজকের বৃষ্টি';

  @override
  String get myNetworkButton => 'আমার নেটওয়ার্ক';

  @override
  String levelUpWelcome(String name) {
    return '$name এ স্বাগতম';
  }

  @override
  String get gateSkip => 'এড়িয়ে যান';
}
