// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'عمل';

  @override
  String get tagline => 'ہر نیک عمل اہم ہے';

  @override
  String get welcomeTagline => 'ہر عمل۔ ہر نیت۔ ہر دن۔';

  @override
  String get tapAnywhereToContinue => 'جاری رکھنے کے لیے کہیں بھی ٹیپ کریں';

  @override
  String get noorCoins => 'نور سکے';

  @override
  String noorCoinBalance(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString نور سکے';
  }

  @override
  String get signInTitle => 'عمل میں شامل ہوں';

  @override
  String get signInSubtitle => 'شروع کرنے کے لیے اپنا اکاؤنٹ بنائیں';

  @override
  String get signIn => 'سائن ان';

  @override
  String get signUp => 'سائن اپ';

  @override
  String get signOut => 'سائن آؤٹ';

  @override
  String get continueWithGoogle => 'گوگل سے جاری رکھیں';

  @override
  String get continueWithApple => 'ایپل سے جاری رکھیں';

  @override
  String get emailAndPassword => 'ای میل اور پاس ورڈ';

  @override
  String get emailLabel => 'ای میل';

  @override
  String get passwordLabel => 'پاس ورڈ';

  @override
  String get confirmPasswordLabel => 'پاس ورڈ کی تصدیق کریں';

  @override
  String get createAccount => 'اکاؤنٹ بنائیں';

  @override
  String get alreadyHaveAccount => 'پہلے سے اکاؤنٹ ہے؟ سائن ان کریں';

  @override
  String get noAccount => 'اکاؤنٹ نہیں ہے؟ سائن اپ کریں';

  @override
  String get forgotPassword => 'پاس ورڈ بھول گئے؟';

  @override
  String get resetPassword => 'پاس ورڈ ری سیٹ کریں';

  @override
  String resetPasswordSent(String email) {
    return '$email پر ری سیٹ لنک بھیج دیا گیا';
  }

  @override
  String get biometricSignIn => 'فیس آئی ڈی / فنگر پرنٹ سے سائن ان کریں';

  @override
  String get enableBiometric => 'فیس آئی ڈی / فنگر پرنٹ فعال کریں';

  @override
  String get enableBiometricSubtitle => 'اگلی بار تیزی سے سائن ان کریں';

  @override
  String get biometricPrompt => 'عمل میں داخل ہونے کے لیے تصدیق کریں';

  @override
  String get usePinInstead => 'اس کے بجائے پن استعمال کریں';

  @override
  String get selectLanguageTitle => 'اپنی زبان منتخب کریں';

  @override
  String get selectLanguageSubtitle =>
      'آپ اسے کبھی بھی ترتیبات میں تبدیل کر سکتے ہیں';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBengali => 'বাংলা';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get languageArabic => 'العربية';

  @override
  String get prayerTraditionTitle => 'آپ کا نماز کا طریقہ';

  @override
  String get prayerTraditionSubtitle =>
      'یہ آپ کی اذان آڈیو اور نماز کا وقت حساب لگانے کا طریقہ طے کرتا ہے';

  @override
  String get sunni => 'سنی';

  @override
  String get shia => 'شیعہ';

  @override
  String get continueButton => 'جاری رکھیں';

  @override
  String get calculationMethodTitle => 'حساب کا طریقہ';

  @override
  String get calculationMethodSubtitle =>
      'اپنے علاقے میں نماز کے اوقات کے حساب کے لیے طریقہ منتخب کریں';

  @override
  String get profileSetupTitle => 'اپنی پروفائل ترتیب دیں';

  @override
  String get profileSetupSubtitle =>
      'اپنا نام بتائیں — بعد میں کبھی بھی تبدیل کر سکتے ہیں';

  @override
  String get nameLabel => 'آپ کا نام';

  @override
  String get addPhoto => 'تصویر شامل کریں';

  @override
  String get changePhoto => 'تصویر تبدیل کریں';

  @override
  String get skip => 'چھوڑیں';

  @override
  String get saveAndContinue => 'محفوظ کریں اور جاری رکھیں';

  @override
  String get notificationTitle => 'جڑے رہیں';

  @override
  String get notificationDescription =>
      'نماز کے اوقات، سوُل اسٹیک یاددہانیاں، YWTL اثر ویڈیوز، اسٹریک یاددہانیاں، اور باغ کے الرٹ';

  @override
  String get allowNotifications => 'اطلاعات کی اجازت دیں';

  @override
  String get maybeLater => 'شاید بعد میں';

  @override
  String welcomeToAmalTitle(String name) {
    return 'خوش آمدید، $name';
  }

  @override
  String get impactMessage =>
      'ہر بار جب آپ عمل استعمال کرتے ہیں، حقیقی لوگوں کو صدقہ ملتا ہے۔ آپ کا دیکھنے کا وقت حقیقی تبدیلی لاتا ہے۔';

  @override
  String get enterAmal => 'عمل میں داخل ہوں';

  @override
  String get errorEmailAlreadyInUse =>
      'یہ ای میل پہلے سے رجسٹرڈ ہے۔ سائن ان کرنے کی کوشش کریں۔';

  @override
  String get errorWeakPassword => 'پاس ورڈ کم از کم 8 حروف کا ہونا چاہیے۔';

  @override
  String get errorInvalidEmail => 'براہ کرم ایک درست ای میل پتہ درج کریں۔';

  @override
  String get errorWrongPassword => 'غلط پاس ورڈ۔ دوبارہ کوشش کریں۔';

  @override
  String get errorUserNotFound => 'اس ای میل سے کوئی اکاؤنٹ نہیں ملا۔';

  @override
  String get errorNetworkRequest => 'کنکشن کی خرابی۔ اپنا انٹرنیٹ چیک کریں۔';

  @override
  String get errorSignInFailed => 'سائن ان ناکام ہوا۔ دوبارہ کوشش کریں۔';

  @override
  String get passwordsDoNotMatch => 'پاس ورڈ مطابقت نہیں رکھتا۔';

  @override
  String get errorGeneric => 'کچھ غلط ہو گیا۔ دوبارہ کوشش کریں۔';

  @override
  String get loading => 'لوڈ ہو رہا ہے…';

  @override
  String get retry => 'دوبارہ کوشش کریں';

  @override
  String get home => 'ہوم';

  @override
  String get quickActions => 'فوری اقدامات';

  @override
  String get earn => 'کمائیں';

  @override
  String get garden => 'باغ';

  @override
  String get community => 'برادری';

  @override
  String get prayerTime => 'نماز کا وقت';

  @override
  String get qibla => 'قبلہ';

  @override
  String get qiblaPermissionNeeded =>
      'قبلے کی سمت معلوم کرنے کے لیے مقام کی اجازت درکار ہے۔ براہ کرم لوکیشن سروسز فعال کریں۔';

  @override
  String get qiblaOpenSettings => 'سیٹنگز کھولیں';

  @override
  String get qiblaCalibrationPrompt =>
      'قطب نما کی درستگی کم ہے۔ کیلیبریٹ کرنے کے لیے فون کو 8 کی شکل میں حرکت دیں۔';

  @override
  String get qiblaKaabaLabel => 'کعبہ';

  @override
  String get qiblaBearingLabel => 'قبلے کا رُخ';

  @override
  String get tasbeeh => 'تسبیح';

  @override
  String get jannahGarden => 'جنت کا باغ';

  @override
  String get noorWallet => 'نور والٹ';

  @override
  String get soulStack => 'روح اسٹیک';

  @override
  String get ywtl => 'آپ دیکھیں، وہ جئیں';

  @override
  String get amalTracker => 'عمل ٹریکر';

  @override
  String get amalGallery => 'عمل گیلری';

  @override
  String get ramadan => 'رمضان';

  @override
  String get ramadanCountdown => 'رمضان کا کاؤنٹ ڈاؤن';

  @override
  String ramadanDaysRemaining(int days, int hours, int minutes) {
    return 'رمضان شروع ہونے میں $days دن، $hours گھنٹے، $minutes منٹ باقی';
  }

  @override
  String get ramadanSuhoor => 'سحری';

  @override
  String get ramadanIftar => 'افطار';

  @override
  String get ramadanLogFast => 'آج کا روزہ لاگ کریں';

  @override
  String get ramadanFastLogged => 'روزہ لاگ ہو گیا';

  @override
  String get ramadanTarawih => 'تراویح';

  @override
  String get ramadanTarawihLogged => 'تراویح مکمل';

  @override
  String ramadanFastsCompleted(int count) {
    return '$count روزے مکمل';
  }

  @override
  String get ramadanLastTenNights => 'آخری ۱۰ راتیں';

  @override
  String ramadanDay(int day) {
    return 'دن $day';
  }

  @override
  String get ramadanMubarak => 'رمضان مبارک';

  @override
  String get ramadanLogTarawih => 'تراویح لاگ کریں';

  @override
  String get ramadanSeekLaylatulQadr => 'طاق راتوں میں شبِ قدر تلاش کریں';

  @override
  String get profile => 'پروفائل';

  @override
  String get settings => 'ترتیبات';

  @override
  String prayerLogged(int coins) {
    return 'نماز ریکارڈ ہوئی! +$coins نور سکے';
  }

  @override
  String fastLogged(int coins) {
    return 'روزہ ریکارڈ ہوا! +$coins نور سکے';
  }

  @override
  String tasbeehComplete(int coins) {
    return 'تسبیح مکمل! +$coins نور سکے';
  }

  @override
  String get fajr => 'فجر';

  @override
  String get dhuhr => 'ظہر';

  @override
  String get asr => 'عصر';

  @override
  String get maghrib => 'مغرب';

  @override
  String get isha => 'عشاء';

  @override
  String get sunrise => 'طلوع آفتاب';

  @override
  String homeGreeting(String name) {
    return 'السلام علیکم، $name';
  }

  @override
  String get yourBalance => 'آپ کا بیلنس';

  @override
  String get setLocationPrompt => 'نماز کے اوقات کے لیے اپنا مقام سیٹ کریں';

  @override
  String prayerProgress(int done, int total) {
    return '$total میں سے $done نمازیں';
  }

  @override
  String get viewAllPrayers => 'تمام نمازیں دیکھیں';

  @override
  String get prayerTimesTitle => 'نماز کے اوقات';

  @override
  String get todaysPrayers => 'آج کی نمازیں';

  @override
  String get modeSilent => 'خاموش';

  @override
  String get modeNotification => 'اطلاع';

  @override
  String get modeAzan => 'اذان';

  @override
  String get notificationSettings => 'اطلاع کی ترتیبات';

  @override
  String get changeLocation => 'تبدیل';

  @override
  String get useGps => 'GPS استعمال کریں';

  @override
  String get cityLabel => 'شہر';

  @override
  String get countryLabel => 'ملک';

  @override
  String get search => 'تلاش';

  @override
  String get usingCachedData => 'کیشڈ ڈیٹا استعمال ہو رہا ہے';

  @override
  String lastUpdated(String age) {
    return 'اپڈیٹ ہوا $age';
  }

  @override
  String get tasbeehSubhanallah => 'سبحان اللہ';

  @override
  String get tasbeehAlhamdulillah => 'الحمد للہ';

  @override
  String get tasbeehAllahuAkbar => 'اللہ اکبر';

  @override
  String get tasbeehAstaghfirullah => 'استغفراللہ';

  @override
  String get tasbeehTarget => 'ہدف';

  @override
  String get tasbeehReset => 'ری سیٹ';

  @override
  String get tasbeehSessionComplete => 'سیشن مکمل';

  @override
  String get tasbeehSessionHistory => 'سیشن ہسٹری';

  @override
  String get tasbeehTotalCount => 'کل تعداد';

  @override
  String get tasbeehLongestSession => 'طویل ترین سیشن';

  @override
  String tasbeehCoinsAwarded(int coins) {
    return '+$coins نور سکے';
  }

  @override
  String get amalCategoryAll => 'سب';

  @override
  String get amalCategoryPrayer => 'نماز';

  @override
  String get amalCategoryFamily => 'خاندان';

  @override
  String get amalCategoryCommunity => 'معاشرہ';

  @override
  String get amalCategorySelf => 'ذات';

  @override
  String get amalCategoryKnowledge => 'علم';

  @override
  String get amalCategoryCharity => 'صدقہ';

  @override
  String get amalSearchHint => 'نیک اعمال تلاش کریں...';

  @override
  String get amalNoResults => 'کوئی عمل نہیں ملا';

  @override
  String amalNoorCoinsReward(int coins) {
    return '$coins NC';
  }

  @override
  String get amalCompleteButton => 'یہ عمل مکمل کریں';

  @override
  String get amalCompleted => 'مکمل';

  @override
  String amalCompletedTimes(int count) {
    return '$count بار مکمل';
  }

  @override
  String get amalSource => 'ماخذ';

  @override
  String get amalDifficultyEasy => 'آسان';

  @override
  String get amalDifficultyMedium => 'درمیانہ';

  @override
  String get amalDifficultyHigh => 'مشکل';

  @override
  String get amalOneTime => 'ایک بار';

  @override
  String get amalDaily => 'روزانہ';

  @override
  String get amalWeekly => 'ہفتہ وار';

  @override
  String get amalOngoing => 'جاری';

  @override
  String get amalWatchToComplete => 'مکمل کرنے کے لیے دیکھیں';

  @override
  String get trackerMyTracker => 'میرا ٹریکر';

  @override
  String get trackerFavourites => 'پسندیدہ';

  @override
  String get trackerTodaysAmal => 'آج کا عمل';

  @override
  String get trackerDailyGoal => 'روزانہ ہدف';

  @override
  String get trackerSetGoal => 'روزانہ ہدف مقرر کریں';

  @override
  String trackerGoalProgress(int done, int total) {
    return 'آج $total میں سے $done مکمل';
  }

  @override
  String get trackerTotalAmals => 'کل اعمال';

  @override
  String get trackerTotalCoins => 'حاصل شدہ نور سکے';

  @override
  String get trackerDailyStreak => 'روزانہ سلسلہ';

  @override
  String get trackerLongestDaily => 'بہترین روزانہ';

  @override
  String get trackerWeeklyStreak => 'ہفتہ وار سلسلہ';

  @override
  String get trackerLongestWeekly => 'بہترین ہفتہ وار';

  @override
  String get trackerRecentActivity => 'حالیہ سرگرمی';

  @override
  String get trackerEncouragement => 'ہر نیک عمل اہم ہے۔ آج ہی شروع کریں!';

  @override
  String get trackerNoCompletions =>
      'ابھی تک کوئی تکمیل نہیں۔ اپنا سفر شروع کریں!';

  @override
  String get trackerNoFavourites =>
      'ابھی تک کوئی پسندیدہ نہیں۔ کسی بھی عمل پر دل ٹیپ کر کے یہاں محفوظ کریں۔';

  @override
  String get soulStackRise => 'رائز — صبح';

  @override
  String get soulStackShine => 'شائن — دوپہر';

  @override
  String get soulStackGlow => 'گلو — رات';

  @override
  String soulStackProgress(int done) {
    return '$done/5 ویڈیوز';
  }

  @override
  String soulStackCompletedTimes(int count) {
    return 'آج $count بار مکمل';
  }

  @override
  String get soulStackStartStack => 'اسٹیک شروع کریں';

  @override
  String get soulStackStart => 'شروع';

  @override
  String get soulStackReady => 'تیار';

  @override
  String get soulStackSwipeUp => 'جاری رکھنے کے لیے اوپر سوائپ کریں';

  @override
  String get soulStackWhatIsRise =>
      'رائز آپ کا صبح کا دعا اسٹیک ہے۔ ۵ مختصر دعاؤں کے ویڈیو دیکھ کر نیت کے ساتھ دن شروع کریں۔ آپ کا دیکھنے کا وقت حقیقی صدقہ بنتا ہے۔';

  @override
  String get soulStackWhatIsShine =>
      'شائن آپ کا دوپہر کا دعا اسٹیک ہے۔ ۵ دعاؤں کے ساتھ ذہنی سکون حاصل کریں۔ آپ کا ہر لمحہ ضرورت مندوں کے لیے صدقہ ہے۔';

  @override
  String get soulStackWhatIsGlow =>
      'گلو آپ کا شام کا دعا اسٹیک ہے۔ ۵ خوبصورت دعاؤں کے ساتھ اپنا دن ختم کریں۔ آپ کا دیکھنے کا وقت حقیقی زندگیاں بدلتا ہے۔';

  @override
  String get soulStackMashaAllah => 'ماشاء اللہ!';

  @override
  String soulStackCoinsEarned(int coins) {
    return '+$coins نور سکے';
  }

  @override
  String get soulStackGardenAccess => '۶ گھنٹے جنت کے باغ کی رسائی شامل ہوئی';

  @override
  String get soulStackSadaqaMessage =>
      'آپ کے دیکھنے کے وقت نے حقیقی صدقے میں حصہ ڈالا';

  @override
  String get soulStackWatchYwtl => 'آج کا اثر ویڈیو دیکھیں';

  @override
  String get soulStackDone => 'مکمل';

  @override
  String get gardenLocked =>
      'اپنے باغ میں داخلے کے لیے ایک سوُل اسٹیک مکمل کریں (فی اسٹیک ۶ گھنٹے)';

  @override
  String get gardenGoToSoulStack => 'سوُل اسٹیک پر جائیں';

  @override
  String get gardenLocalSaveWarning =>
      'آپ کا باغ اس ڈیوائس پر محفوظ ہے۔ ایپ ڈیلیٹ کرنے سے باغ ضائع ہو جائے گا۔ کلاؤڈ بیک اپ جلد آ رہا ہے۔';

  @override
  String get gardenIUnderstand => 'سمجھ گیا';

  @override
  String gardenAccessRemaining(String time) {
    return 'باغ تک رسائی: $time باقی';
  }

  @override
  String get gardenPremiumOpen => 'پریمیم — ہمیشہ کھلا';

  @override
  String get gardenInnerCircle => 'اندرونی دائرہ';

  @override
  String get gardenOuterCircle => 'بیرونی دائرہ';

  @override
  String get gardenAssetStore => 'اثاثہ اسٹور';

  @override
  String get gardenRestoreWithCoins => 'نور سکوں سے بحال کریں';

  @override
  String get gardenRestoreInstantly => 'فوری بحالی';

  @override
  String get gardenInsufficientCoins =>
      'کافی نور سکے نہیں — مزید کمانے کے لیے سوُل اسٹیک مکمل کریں';

  @override
  String get gardenShareAmal => 'عمل شیئر کریں';

  @override
  String get gardenReferralCode => 'آپ کا ریفرل کوڈ';

  @override
  String get gardenIntensityLow =>
      'بیج بوئیں۔ دوسروں کو اپنا سفر شروع کرنے کی دعوت دیں۔';

  @override
  String get gardenIntensityMedium =>
      'آپ کا صدقہ جاریہ بڑھ رہا ہے۔ ماشاء اللہ۔';

  @override
  String get gardenIntensityHigh =>
      'ایک خوبصورت بارانی جنگل، جنہیں آپ عمل میں لائے ان کے ذریعے زندہ۔';

  @override
  String get gardenIntensityMax =>
      'سبحان اللہ۔ آپ کا صدقہ جاریہ عظیم دریا کی طرح بہتا ہے۔';

  @override
  String get gardenPlace => 'رکھیں';

  @override
  String get walletBalance => 'بیلنس';

  @override
  String walletTotalEarned(int coins) {
    return 'کل مجموعی کمائی: $coins';
  }

  @override
  String get walletTransactionHistory => 'لین دین کی تاریخ';

  @override
  String get walletLoadMore => 'مزید لوڈ کریں';

  @override
  String get walletHowToEarn => 'نور سکے کیسے کمائیں';

  @override
  String get walletHowToSpend => 'نور سکے کس پر خرچ کر سکتے ہیں؟';

  @override
  String get walletOpenGarden => 'جنت کا باغ کھولیں';

  @override
  String get walletNoTransactions =>
      'ابھی تک کوئی لین دین نہیں۔ نور سکے کمانا شروع کریں!';

  @override
  String get ywtlWatchToday => 'آج کا اثر دیکھیں';

  @override
  String get ywtlWatchAgain => 'دوبارہ دیکھیں';

  @override
  String get ywtlCollectCoins => 'اپنے نور سکے جمع کریں';

  @override
  String ywtlCoinsCollected(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return '+$coinsString نور سکے جمع ہوگئے!';
  }

  @override
  String ywtlAvailableIn(int days) {
    return '$days دن میں';
  }

  @override
  String get ywtlPreviousWeeks => 'پچھلے ہفتے ہمارے یوٹیوب چینل پر دستیاب ہیں';

  @override
  String get ywtlThisWeek => 'اس ہفتے';

  @override
  String get ywtlMonday => 'پیر';

  @override
  String get ywtlTuesday => 'منگل';

  @override
  String get ywtlWednesday => 'بدھ';

  @override
  String get ywtlThursday => 'جمعرات';

  @override
  String get ywtlFriday => 'جمعہ';

  @override
  String get ywtlSaturday => 'ہفتہ';

  @override
  String get ywtlSunday => 'اتوار';

  @override
  String get settingsNotifications => 'اطلاعات';

  @override
  String get settingsPrayerReminders => 'نماز کی یاددہانیاں';

  @override
  String get settingsSoulStackReminders => 'سوُل اسٹیک یاددہانیاں';

  @override
  String get settingsYwtlVideo => 'YWTL نیا ویڈیو';

  @override
  String get settingsStreakAtRisk => 'سلسلہ خطرے میں';

  @override
  String get settingsAssetFading => 'اثاثہ دھندلا ہونے کی وارننگ';

  @override
  String get settingsPrayerSettings => 'نماز کی ترتیبات';

  @override
  String get settingsPrayerTradition => 'نماز کا طریقہ';

  @override
  String get settingsCalculationMethod => 'حساب کا طریقہ';

  @override
  String get settingsLocation => 'مقام';

  @override
  String get settingsUpdateLocation => 'مقام اپڈیٹ کریں';

  @override
  String get settingsAzanAudio => 'اذان آڈیو';

  @override
  String get settingsAppSettings => 'ایپ ترتیبات';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsTheme => 'تھیم';

  @override
  String get settingsThemeLight => 'روشن';

  @override
  String get settingsThemeDark => 'تاریک';

  @override
  String get settingsThemeSystem => 'سسٹم';

  @override
  String get settingsHaptic => 'ہیپٹک فیڈ بیک';

  @override
  String get settingsSound => 'ساؤنڈ ایفیکٹ';

  @override
  String get settingsBiometric => 'بائیومیٹرک لاگ ان';

  @override
  String get settingsStreakAtRiskDesc =>
      'اگر سلسلہ خطرے میں ہو تو رات 8 بجے خبردار کرے گا';

  @override
  String get settingsAssetFadingDesc =>
      'باغ کے اثاثے دھندلا ہونے پر متنبہ کرے گا';

  @override
  String get settingsAzanMakkah => 'مکہ قاری';

  @override
  String get settingsAzanMadinah => 'مدینہ قاری';

  @override
  String get settingsAzanAlAqsa => 'المسجد الاقصیٰ قاری';

  @override
  String get settingsAzanMishary => 'مشاری راشد';

  @override
  String get profileMemberSince => 'رکن بنے';

  @override
  String get profileFree => 'مفت';

  @override
  String get profilePremium => 'پریمیم';

  @override
  String get profileReferralCode => 'ریفرل کوڈ';

  @override
  String get profileTotalEarned => 'کل حاصل شدہ نور سکے';

  @override
  String get profileCommunityImpact => 'معاشرتی اثر';

  @override
  String get profileDataUpdated => 'ڈیٹا اپڈیٹ ہوا';

  @override
  String get profileSubscribe => 'سبسکرائب کریں';

  @override
  String get profileManageSubscription => 'سبسکرپشن کا انتظام';

  @override
  String get profileRestorePurchases => 'خریداری بحال کریں';

  @override
  String get profileMonthly => 'ماہانہ';

  @override
  String get profileAnnual => 'سالانہ';

  @override
  String get profileLogOut => 'لاگ آؤٹ';

  @override
  String get profileLogOutConfirm => 'کیا آپ واقعی لاگ آؤٹ کرنا چاہتے ہیں؟';

  @override
  String get profileDeleteAccount => 'اکاؤنٹ حذف کریں';

  @override
  String get profileDeleteWarning =>
      'یہ عمل مستقل ہے۔ آپ کا تمام ڈیٹا، نور سکے اور پیشرفت ضائع ہو جائے گی۔ کیا آپ کو یقین ہے؟';

  @override
  String get profileDeleteConfirmType =>
      'اکاؤنٹ حذف کرنے کی تصدیق کے لیے DELETE ٹائپ کریں';

  @override
  String get profileCancel => 'منسوخ';

  @override
  String get profileSaveDiscount => '۱۷% بچائیں';

  @override
  String get or => 'یا';

  @override
  String get timeJustNow => 'ابھی';

  @override
  String timeMinutesAgo(int count) {
    return '$count منٹ پہلے';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count گھنٹے پہلے';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count دن پہلے';
  }

  @override
  String get walletSourcePrayer => 'روزانہ نماز';

  @override
  String get walletSourceFast => 'رمضان کا روزہ';

  @override
  String get walletSourceTasbeeh => 'تسبیح سیشن';

  @override
  String get walletSourceSoulStack => 'سول اسٹیک';

  @override
  String get walletSourceYwtl => 'YWTL ویڈیو';

  @override
  String get walletSourceAmal => 'عمل مکمل';

  @override
  String get walletSourceGarden => 'باغ اثاثہ';

  @override
  String get walletSpendGarden => 'جنت باغ اثاثے';

  @override
  String get walletSpendRestore => 'دھندلے اثاثے بحال کریں';

  @override
  String get countdownDays => 'دن';

  @override
  String get countdownHours => 'گھنٹے';

  @override
  String get countdownMinutes => 'منٹ';

  @override
  String get remove => 'ہٹائیں';

  @override
  String get restore => 'بحال کریں';

  @override
  String get info => 'معلومات';

  @override
  String get ok => 'ٹھیک ہے';

  @override
  String get restoreAsset => 'اثاثہ بحال کریں';

  @override
  String get copiedToClipboard => 'کلپ بورڈ میں کاپی ہوگیا';

  @override
  String ywtlWatchFullVideo(int coins) {
    return 'مکمل ویڈیو دیکھیں $coins نور سکے جمع کرنے کے لیے';
  }

  @override
  String get comingSoon => 'جلد آرہا ہے';

  @override
  String get forgotPasswordTitle => 'پاسورڈ ری سیٹ';

  @override
  String get forgotPasswordSubtitle =>
      'اپنا ای میل ایڈریس درج کریں اور ہم آپ کو پاسورڈ ری سیٹ لنک بھیجیں گے';

  @override
  String get sendResetLink => 'ری سیٹ لنک بھیجیں';

  @override
  String get resetLinkSent =>
      'پاسورڈ ری سیٹ لنک بھیج دیا گیا! اپنا ای میل چیک کریں۔';

  @override
  String get resetLinkError =>
      'ری سیٹ لنک بھیجنے میں ناکامی۔ اپنا ای میل چیک کر کے دوبارہ کوشش کریں۔';

  @override
  String get gardenVisit => 'اپنے جنت کے باغ کا دورہ کریں';

  @override
  String get soulStackSubtitle => 'روزانہ دعا اسٹیکس سے نور سکے حاصل کریں';

  @override
  String get amalTrackerSubtitle => 'اپنے نیک اعمال ٹریک کریں اور سلسلہ بنائیں';

  @override
  String get gardenAwaitsTitle => 'آپ کا باغ آپ کا منتظر ہے';

  @override
  String get gardenAwaitsBody =>
      'سول اسٹیک مکمل کریں یا ویڈیو دیکھیں اپنا باغ ٦ گھنٹے کے لیے کھولنے کے لیے۔';

  @override
  String get gardenSubscribe => 'سبسکرائب';

  @override
  String get gardenCompleteSoulStack => 'سول اسٹیک مکمل کریں';

  @override
  String get gardenWatchVideo => 'ویڈیو دیکھیں';

  @override
  String get gardenNotNow => 'ابھی نہیں';

  @override
  String get gardenPremiumBadge => 'پریمیم — مکمل رسائی';

  @override
  String get gardenWatchToUnlock => 'باغ کھولنے کے لیے ویڈیو دیکھیں';

  @override
  String get shopGalleryTitle => 'مقدس باغ گیلری';

  @override
  String get shopFeatured => 'نمایاں';

  @override
  String get shopAddToGarden => 'باغ میں شامل کریں';

  @override
  String get shopInGarden => 'باغ میں ہے';

  @override
  String get shopEarnMoreNc => 'مزید حاصل کریں';

  @override
  String get shopAll => 'سب';

  @override
  String get shopTrees => 'درخت';

  @override
  String get shopWater => 'پانی';

  @override
  String get shopFruits => 'پھل';

  @override
  String get shopCreatures => 'مخلوقات';

  @override
  String get shopStructures => 'عمارات';

  @override
  String get shopSacred => 'مقدس';

  @override
  String get shopUnderwater => 'زیرآب';

  @override
  String get shopSky => 'آسمان';

  @override
  String get shopHayatTitle => 'اپنی جنت بحال کریں';

  @override
  String get shopHayatDrop => 'حیات ڈراپ';

  @override
  String get shopHayatBloom => 'حیات بلوم';

  @override
  String get shopNcTitle => 'نور سکے شامل کریں';

  @override
  String get shopStarterNoor => 'ابتدائی نور';

  @override
  String get shopHandfulNoor => 'مٹھی بھر نور';

  @override
  String get shopGardensWorth => 'ایک باغ کی قدر';

  @override
  String get shopBlessedHarvest => 'مبارک فصل';

  @override
  String get hayatLife => 'حیات · زندگی';

  @override
  String get hayatTagline =>
      'ہر باغ کو دیکھ بھال کی ضرورت ہے۔ حیات آپ کے باغ کو دوبارہ زندہ کرتا ہے۔';

  @override
  String get hayatDropTitle => 'حیات ڈراپ';

  @override
  String get hayatDropEffect => 'ایک منتخب اثاثہ بحال کرتا ہے';

  @override
  String get hayatBloomTitle => 'حیات بلوم';

  @override
  String get hayatBloomEffect => 'آپ کا پورا باغ بحال کرتا ہے';

  @override
  String get hayatRestoreOne => 'ایک اثاثہ بحال کریں';

  @override
  String get hayatRestoreAll => 'پورا باغ بحال کریں';

  @override
  String get hayatOr => 'یا';

  @override
  String hayatYourBalance(int balance) {
    return 'آپ کا بیلنس: $balance نور سکے';
  }

  @override
  String get hayatSelectAsset => 'بحالی کے لیے ایک اثاثہ منتخب کریں';

  @override
  String get hayatRestoreThis => 'اسے بحال کریں؟';

  @override
  String plantConfirmTitle(String name, int price) {
    return '$price نور سکوں میں $name لگائیں؟';
  }

  @override
  String get plantIt => 'لگائیں';

  @override
  String get notNow => 'ابھی نہیں';

  @override
  String get earnMorePrompt => 'یہ تحفہ لگانے کے لیے مزید نور سکے حاصل کریں';

  @override
  String sellConfirmTitle(String name, int price) {
    return '$price نور سکوں میں $name فروخت کریں؟';
  }

  @override
  String get sellConfirmBody => 'اسے آپ کے باغ سے ہٹا دیا جائے گا۔';

  @override
  String get sellButton => 'فروخت';

  @override
  String get tapSlotToPlace => 'اپنا اثاثہ رکھنے کے لیے خالی سلاٹ پر ٹیپ کریں';

  @override
  String get moveAsset => 'منتقل';

  @override
  String get sellAsset => 'فروخت';

  @override
  String get qmDua => 'دعا';

  @override
  String get qmHistory => 'اسلامی تاریخ';

  @override
  String get qmWatchToDiscover => 'اپنا تحفہ دریافت کرنے کے لیے دیکھیں';

  @override
  String get qmMomentPassed => 'یہ لمحہ گزر گیا۔ ایک نیا آئے گا۔';

  @override
  String get qmDiscoveryWaiting => 'آپ کی دریافت ابھی بھی منتظر ہے';

  @override
  String get qmDiscoveryBody =>
      'آپ کے پاس وقت ہے۔ آپ کے باغ میں ایک مقدس تحفہ آپ کا منتظر ہے۔';

  @override
  String get jazakAllahuKhairan => 'جزاک اللہ خیراً';

  @override
  String get sacredContentComingSoon =>
      'مقدس مواد جلد آرہا ہے۔ جزاک اللہ خیراً۔';

  @override
  String get returnToGarden => 'باغ میں واپسی';

  @override
  String get outerGardenTitle => 'آپ کا بیرونی باغ';

  @override
  String get outerGardenExplainerBody =>
      'آپ جسے بھی عمل میں مدعو کرتے ہیں وہ آپ کی بیرونی جنت میں ایک بیج بوتا ہے۔ ہر عمل جو وہ کرتے ہیں — آپ کے باغ میں بارش ہوتی ہے۔ ہر شخص جسے وہ مدعو کرتے ہیں — ان کا عمل آپ تک بھی پہنچتا ہے۔ یہ صدقہ جاریہ ہے۔ نیکیاں جو کبھی نہیں رکتیں۔';

  @override
  String get outerGardenExplainerSubtext =>
      'آپ کا ریفرل نیٹ ورک لامحدود ہے۔ ہر عمل کی بازگشت ہوتی ہے۔';

  @override
  String get outerGardenEnterButton => 'میرے باغ میں داخل ہوں';

  @override
  String get myNetwork => 'میرا نیٹ ورک';

  @override
  String get copyLink => 'لنک کاپی کریں';

  @override
  String get linkCopied => 'کاپی ہو گیا!';

  @override
  String get shareInvite => 'شیئر کریں';

  @override
  String get shareInviteMessage =>
      'جنت بنانے میں میرے ساتھ شامل ہوں۔ ہر نیک عمل کی بازگشت ہوتی ہے۔ یہاں اپنا جنت باغ شروع کریں:';

  @override
  String get directInvites => 'براہ راست دعوتیں';

  @override
  String get directInvitesDesc => 'آپ کے لنک سے براہ راست شامل ہونے والے';

  @override
  String get theirInvites => 'ان کی دعوتیں';

  @override
  String get theirInvitesDesc => 'آپ کے مدعوین کے ذریعے مدعو کیے گئے';

  @override
  String get totalNetwork => 'کل نیٹ ورک';

  @override
  String get totalNetworkDesc => 'ہر سطح پر آپ کا مکمل نیٹ ورک';

  @override
  String get totalNetworkAmals => 'کل اعمال';

  @override
  String get totalNetworkAmalsDesc => 'آپ کے نیٹ ورک میں سب کے مکمل اعمال';

  @override
  String get rainfallToday => 'آج کی بارش';

  @override
  String get rainfallTodayDesc => 'آپ کے نیٹ ورک کی آج کی سرگرمی سے بارش';

  @override
  String get howItWorks => 'یہ کیسے کام کرتا ہے؟';

  @override
  String get howItWorksBody =>
      'آپ کے نیٹ ورک کا ہر عمل آپ کے باغ میں بارش بھیجتا ہے۔ آپ جتنی گہری جڑیں لگائیں گے — آپ کی جنت اتنی زیادہ بڑھے گی۔';

  @override
  String get levelAlRawdah => 'الروضہ';

  @override
  String get levelAlFirdaws => 'الفردوس';

  @override
  String get levelAlNaim => 'النعیم';

  @override
  String get levelJannatAlMawa => 'جنت المأوی';

  @override
  String welcomeToLevel(String levelName) {
    return '$levelName میں خوش آمدید';
  }

  @override
  String get verseLevel2En => 'ایمان لانے والوں کو خوشخبری دیں';

  @override
  String get verseLevel3En => 'بے شک متقین باغات میں ہوں گے';

  @override
  String get verseLevel4En => 'اس میں صاف پانی کی نہریں ہیں';

  @override
  String get architectViewLabel => 'آرکیٹیکٹ ویو';

  @override
  String get immersionViewLabel => 'ڈوبے ہوئے';

  @override
  String get plantSomething => 'کچھ لگائیں';

  @override
  String get accessPromptTitle => 'آپ کا باغ آپ کا منتظر ہے';

  @override
  String get accessPromptBody =>
      'سول اسٹیک مکمل کریں یا ویڈیو دیکھیں اپنا باغ ٦ گھنٹے کے لیے کھولنے کے لیے۔';

  @override
  String get accessSubscribeButton => 'سبسکرائب';

  @override
  String get accessSoulStackButton => 'سول اسٹیک مکمل کریں';

  @override
  String get accessYwtlButton => 'ویڈیو دیکھیں';

  @override
  String get shopFeaturedLabel => 'اس ہفتے کا خاص';

  @override
  String get shopFilterAll => 'سب';

  @override
  String get shopFilterTrees => 'درخت';

  @override
  String get shopFilterWater => 'پانی';

  @override
  String get shopFilterFruits => 'پھل';

  @override
  String get shopFilterCreatures => 'مخلوقات';

  @override
  String get shopFilterStructures => 'عمارات';

  @override
  String get shopFilterSacred => 'مقدس';

  @override
  String get shopFilterUnderwater => 'زیرآب';

  @override
  String get shopFilterSky => 'آسمان';

  @override
  String get shopHayatTagline =>
      'ہر باغ کو دیکھ بھال کی ضرورت ہے۔ حیات آپ کے باغ کو دوبارہ زندہ کرتا ہے۔';

  @override
  String get hayatRestoreFull => 'پورا باغ بحال کریں';

  @override
  String get plantingConfirmTitle => 'اپنی جنت میں لگائیں؟';

  @override
  String get plantingConfirmButton => 'لگائیں';

  @override
  String get plantingNotNow => 'ابھی نہیں';

  @override
  String assetSellConfirm(String name, int nc) {
    return '$nc نور سکوں میں $name فروخت کریں؟';
  }

  @override
  String get assetSellRemovalWarning => 'اسے آپ کے باغ سے ہٹا دیا جائے گا۔';

  @override
  String get assetSellButton => 'فروخت کی تصدیق';

  @override
  String get questionMarkDua => 'دعا';

  @override
  String get questionMarkHistory => 'اسلامی تاریخ';

  @override
  String get questionMarkWatchToDiscover =>
      'اپنا تحفہ دریافت کرنے کے لیے دیکھیں';

  @override
  String get questionMarkExpired => 'یہ لمحہ گزر گیا۔ ایک نیا آئے گا۔';

  @override
  String get questionMarkPending =>
      'آپ کی دریافت ابھی بھی منتظر ہے۔ آپ کے پاس وقت ہے۔';

  @override
  String get discoveryJazakAllah => 'جزاک اللہ خیراً';

  @override
  String get outerGardenSubtitle => 'صدقہ جاریہ';

  @override
  String get outerGardenSkip => 'چھوڑیں';

  @override
  String get referralCopied => 'کاپی ہو گیا!';

  @override
  String get referralShareText => 'عمل میں میرے ساتھ شامل ہوں';

  @override
  String get networkDirectInvites => 'براہ راست دعوتیں';

  @override
  String get networkTheirInvites => 'ان کی دعوتیں';

  @override
  String get networkTotal => 'کل نیٹ ورک';

  @override
  String get networkAmals => 'کل اعمال';

  @override
  String get networkRainfallToday => 'آج کی بارش';

  @override
  String get myNetworkButton => 'میرا نیٹ ورک';

  @override
  String levelUpWelcome(String name) {
    return '$name میں خوش آمدید';
  }

  @override
  String get gateSkip => 'چھوڑیں';
}
