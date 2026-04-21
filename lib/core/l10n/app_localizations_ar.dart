// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'عمل';

  @override
  String get tagline => 'كل عمل صالح له قيمة';

  @override
  String get welcomeTagline => 'كل عمل. كل نية. كل يوم.';

  @override
  String get tapAnywhereToContinue => 'انقر في أي مكان للمتابعة';

  @override
  String get noorCoins => 'عملات النور';

  @override
  String noorCoinBalance(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString عملة نور';
  }

  @override
  String get signInTitle => 'انضم إلى عمل';

  @override
  String get signInSubtitle => 'أنشئ حسابك للبدء';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get signOut => 'تسجيل الخروج';

  @override
  String get continueWithGoogle => 'المتابعة مع Google';

  @override
  String get continueWithApple => 'المتابعة مع Apple';

  @override
  String get emailAndPassword => 'البريد الإلكتروني وكلمة المرور';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get confirmPasswordLabel => 'تأكيد كلمة المرور';

  @override
  String get createAccount => 'إنشاء حساب';

  @override
  String get alreadyHaveAccount => 'لديك حساب بالفعل؟ سجّل الدخول';

  @override
  String get noAccount => 'ليس لديك حساب؟ سجّل الآن';

  @override
  String get forgotPassword => 'نسيت كلمة المرور؟';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String resetPasswordSent(String email) {
    return 'تم إرسال رابط الاستعادة إلى $email';
  }

  @override
  String get biometricSignIn => 'تسجيل الدخول ببصمة الوجه / الإصبع';

  @override
  String get enableBiometric => 'تفعيل معرّف الوجه / بصمة الإصبع';

  @override
  String get enableBiometricSubtitle =>
      'سجّل الدخول بشكل أسرع في المرة القادمة';

  @override
  String get biometricPrompt => 'المصادقة للدخول إلى عمل';

  @override
  String get usePinInstead => 'استخدام الرقم السري بدلاً من ذلك';

  @override
  String get selectLanguageTitle => 'اختر لغتك';

  @override
  String get selectLanguageSubtitle => 'يمكنك تغييرها في أي وقت من الإعدادات';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBengali => 'বাংলা';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get languageArabic => 'العربية';

  @override
  String get prayerTraditionTitle => 'مذهبك في الصلاة';

  @override
  String get prayerTraditionSubtitle =>
      'يحدد هذا ملف صوت الأذان وطريقة حساب مواقيت الصلاة';

  @override
  String get sunni => 'سني';

  @override
  String get shia => 'شيعي';

  @override
  String get continueButton => 'متابعة';

  @override
  String get calculationMethodTitle => 'طريقة الحساب';

  @override
  String get calculationMethodSubtitle =>
      'اختر الطريقة المستخدمة لحساب مواقيت الصلاة في منطقتك';

  @override
  String get profileSetupTitle => 'إعداد ملفك الشخصي';

  @override
  String get profileSetupSubtitle =>
      'أخبرنا باسمك — يمكنك تغييره في أي وقت لاحقاً';

  @override
  String get nameLabel => 'اسمك';

  @override
  String get addPhoto => 'إضافة صورة';

  @override
  String get changePhoto => 'تغيير الصورة';

  @override
  String get skip => 'تخطّ';

  @override
  String get saveAndContinue => 'حفظ ومتابعة';

  @override
  String get notificationTitle => 'ابق على تواصل';

  @override
  String get notificationDescription =>
      'مواقيت الصلاة، تذكيرات Soul Stack، مقاطع YWTL، تذكيرات التسلسل، وتنبيهات الحديقة';

  @override
  String get allowNotifications => 'السماح بالإشعارات';

  @override
  String get maybeLater => 'ربما لاحقاً';

  @override
  String welcomeToAmalTitle(String name) {
    return 'أهلاً بك، $name';
  }

  @override
  String get impactMessage =>
      'في كل مرة تستخدم فيها عمل، يتلقى أناس حقيقيون صدقة. وقت مشاهدتك يُحدث تغييراً حقيقياً.';

  @override
  String get enterAmal => 'ادخل إلى عمل';

  @override
  String get errorEmailAlreadyInUse =>
      'هذا البريد الإلكتروني مسجّل بالفعل. حاول تسجيل الدخول.';

  @override
  String get errorWeakPassword => 'يجب أن تكون كلمة المرور 8 أحرف على الأقل.';

  @override
  String get errorInvalidEmail => 'يرجى إدخال عنوان بريد إلكتروني صحيح.';

  @override
  String get errorWrongPassword => 'كلمة مرور غير صحيحة. حاول مجدداً.';

  @override
  String get errorUserNotFound => 'لم يُعثر على حساب بهذا البريد الإلكتروني.';

  @override
  String get errorNetworkRequest => 'خطأ في الاتصال. تحقق من اتصالك بالإنترنت.';

  @override
  String get errorSignInFailed => 'فشل تسجيل الدخول. حاول مجدداً.';

  @override
  String get passwordsDoNotMatch => 'كلمتا المرور غير متطابقتين.';

  @override
  String get errorGeneric => 'حدث خطأ ما. يرجى المحاولة مجدداً.';

  @override
  String get loading => 'جارٍ التحميل…';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get home => 'الرئيسية';

  @override
  String get quickActions => 'إجراءات سريعة';

  @override
  String get earn => 'اكسب';

  @override
  String get garden => 'الحديقة';

  @override
  String get community => 'المجتمع';

  @override
  String get prayerTime => 'وقت الصلاة';

  @override
  String get qibla => 'القبلة';

  @override
  String get qiblaPermissionNeeded =>
      'يلزم إذن الموقع لتحديد اتجاه القبلة. يرجى تفعيل خدمات الموقع.';

  @override
  String get qiblaOpenSettings => 'فتح الإعدادات';

  @override
  String get qiblaCalibrationPrompt =>
      'دقة البوصلة منخفضة. حرّك هاتفك بنمط الرقم 8 للمعايرة.';

  @override
  String get qiblaKaabaLabel => 'الكعبة';

  @override
  String get qiblaBearingLabel => 'اتجاه القبلة';

  @override
  String get tasbeeh => 'التسبيح';

  @override
  String get jannahGarden => 'جنة الفردوس';

  @override
  String get noorWallet => 'محفظة النور';

  @override
  String get soulStack => 'حزمة الروح';

  @override
  String get ywtl => 'أنت تشاهد، هم يعيشون';

  @override
  String get amalTracker => 'متتبع الأعمال';

  @override
  String get amalGallery => 'معرض الأعمال';

  @override
  String get ramadan => 'رمضان';

  @override
  String get ramadanCountdown => 'العد التنازلي لرمضان';

  @override
  String ramadanDaysRemaining(int days, int hours, int minutes) {
    return 'يبدأ رمضان خلال $days يوم، $hours ساعة، $minutes دقيقة';
  }

  @override
  String get ramadanSuhoor => 'السحور';

  @override
  String get ramadanIftar => 'الإفطار';

  @override
  String get ramadanLogFast => 'سجّل صيام اليوم';

  @override
  String get ramadanFastLogged => 'تم تسجيل الصيام';

  @override
  String get ramadanTarawih => 'التراويح';

  @override
  String get ramadanTarawihLogged => 'تم التراويح';

  @override
  String ramadanFastsCompleted(int count) {
    return '$count أيام صيام مكتملة';
  }

  @override
  String get ramadanLastTenNights => 'العشر الأواخر';

  @override
  String ramadanDay(int day) {
    return 'اليوم $day';
  }

  @override
  String get ramadanMubarak => 'رمضان مبارك';

  @override
  String get ramadanLogTarawih => 'سجّل التراويح';

  @override
  String get ramadanSeekLaylatulQadr => 'تحرّوا ليلة القدر في الأوتار';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get settings => 'الإعدادات';

  @override
  String prayerLogged(int coins) {
    return 'تم تسجيل الصلاة! +$coins عملة نور';
  }

  @override
  String fastLogged(int coins) {
    return 'تم تسجيل الصيام! +$coins عملة نور';
  }

  @override
  String tasbeehComplete(int coins) {
    return 'اكتمل التسبيح! +$coins عملة نور';
  }

  @override
  String get fajr => 'الفجر';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get sunrise => 'الشروق';

  @override
  String homeGreeting(String name) {
    return 'السلام عليكم، $name';
  }

  @override
  String get yourBalance => 'رصيدك';

  @override
  String get setLocationPrompt => 'اضغط لتحديد موقعك لأوقات الصلاة';

  @override
  String prayerProgress(int done, int total) {
    return '$done من $total صلوات';
  }

  @override
  String get viewAllPrayers => 'عرض جميع الصلوات';

  @override
  String get prayerTimesTitle => 'أوقات الصلاة';

  @override
  String get todaysPrayers => 'صلوات اليوم';

  @override
  String get modeSilent => 'صامت';

  @override
  String get modeNotification => 'إشعار';

  @override
  String get modeAzan => 'أذان';

  @override
  String get notificationSettings => 'إعدادات الإشعارات';

  @override
  String get changeLocation => 'تغيير';

  @override
  String get useGps => 'استخدام GPS';

  @override
  String get cityLabel => 'المدينة';

  @override
  String get countryLabel => 'الدولة';

  @override
  String get search => 'بحث';

  @override
  String get usingCachedData => 'استخدام بيانات مخزنة';

  @override
  String lastUpdated(String age) {
    return 'تم التحديث $age';
  }

  @override
  String get tasbeehSubhanallah => 'سبحان الله';

  @override
  String get tasbeehAlhamdulillah => 'الحمد لله';

  @override
  String get tasbeehAllahuAkbar => 'الله أكبر';

  @override
  String get tasbeehAstaghfirullah => 'أستغفر الله';

  @override
  String get tasbeehTarget => 'الهدف';

  @override
  String get tasbeehReset => 'إعادة';

  @override
  String get tasbeehSessionComplete => 'اكتملت الجلسة';

  @override
  String get tasbeehSessionHistory => 'سجل الجلسات';

  @override
  String get tasbeehTotalCount => 'العدد الإجمالي';

  @override
  String get tasbeehLongestSession => 'أطول جلسة';

  @override
  String tasbeehCoinsAwarded(int coins) {
    return '+$coins عملة نور';
  }

  @override
  String get amalCategoryAll => 'الكل';

  @override
  String get amalCategoryPrayer => 'الصلاة';

  @override
  String get amalCategoryFamily => 'الأسرة';

  @override
  String get amalCategoryCommunity => 'المجتمع';

  @override
  String get amalCategorySelf => 'الذات';

  @override
  String get amalCategoryKnowledge => 'العلم';

  @override
  String get amalCategoryCharity => 'الصدقة';

  @override
  String get amalSearchHint => 'ابحث عن أعمال صالحة...';

  @override
  String get amalNoResults => 'لم يتم العثور على أعمال';

  @override
  String amalNoorCoinsReward(int coins) {
    return '$coins NC';
  }

  @override
  String get amalCompleteButton => 'أكمل هذا العمل';

  @override
  String get amalCompleted => 'مكتمل';

  @override
  String amalCompletedTimes(int count) {
    return 'مكتمل $count مرات';
  }

  @override
  String get amalSource => 'المصدر';

  @override
  String get amalDifficultyEasy => 'سهل';

  @override
  String get amalDifficultyMedium => 'متوسط';

  @override
  String get amalDifficultyHigh => 'صعب';

  @override
  String get amalOneTime => 'مرة واحدة';

  @override
  String get amalDaily => 'يومي';

  @override
  String get amalWeekly => 'أسبوعي';

  @override
  String get amalOngoing => 'مستمر';

  @override
  String get amalWatchToComplete => 'شاهد للإكمال';

  @override
  String get trackerMyTracker => 'متتبعي';

  @override
  String get trackerFavourites => 'المفضلة';

  @override
  String get trackerTodaysAmal => 'عمل اليوم';

  @override
  String get trackerDailyGoal => 'الهدف اليومي';

  @override
  String get trackerSetGoal => 'حدد هدفاً يومياً';

  @override
  String trackerGoalProgress(int done, int total) {
    return '$done من $total مكتمل اليوم';
  }

  @override
  String get trackerTotalAmals => 'إجمالي الأعمال';

  @override
  String get trackerTotalCoins => 'عملات النور المكتسبة';

  @override
  String get trackerDailyStreak => 'السلسلة اليومية';

  @override
  String get trackerLongestDaily => 'أفضل يومي';

  @override
  String get trackerWeeklyStreak => 'السلسلة الأسبوعية';

  @override
  String get trackerLongestWeekly => 'أفضل أسبوعي';

  @override
  String get trackerRecentActivity => 'النشاط الأخير';

  @override
  String get trackerEncouragement => 'كل عمل صالح له قيمة. ابدأ اليوم!';

  @override
  String get trackerNoCompletions => 'لا إنجازات بعد. ابدأ رحلتك!';

  @override
  String get trackerNoFavourites =>
      'لا مفضلات بعد. اضغط على القلب في أي عمل لحفظه هنا.';

  @override
  String get soulStackRise => 'رايز — الصباح';

  @override
  String get soulStackShine => 'شاين — الظهيرة';

  @override
  String get soulStackGlow => 'غلو — المساء';

  @override
  String soulStackProgress(int done) {
    return '$done/5 فيديو';
  }

  @override
  String soulStackCompletedTimes(int count) {
    return 'مكتمل $count مرات اليوم';
  }

  @override
  String get soulStackStartStack => 'ابدأ الحزمة';

  @override
  String get soulStackStart => 'ابدأ';

  @override
  String get soulStackReady => 'جاهز';

  @override
  String get soulStackSwipeUp => 'اسحب للأعلى للمتابعة';

  @override
  String get soulStackWhatIsRise =>
      'رايز هو حزمة أدعية الصباح. شاهد ٥ فيديوهات قصيرة لأدعية جميلة لبدء يومك بنية. وقت مشاهدتك يموّل صدقة حقيقية.';

  @override
  String get soulStackWhatIsShine =>
      'شاين هو حزمة أدعية الظهيرة. خذ استراحة مع ٥ أدعية. كل ثانية تشاهدها تساهم في صدقة للمحتاجين.';

  @override
  String get soulStackWhatIsGlow =>
      'غلو هو حزمة أدعية المساء. أنهِ يومك بـ ٥ أدعية جميلة. وقت مشاهدتك يغيّر حياة حقيقية.';

  @override
  String get soulStackMashaAllah => 'ما شاء الله!';

  @override
  String soulStackCoinsEarned(int coins) {
    return '+$coins عملة نور';
  }

  @override
  String get soulStackGardenAccess => 'تمت إضافة ٦ ساعات وصول لحديقة الجنة';

  @override
  String get soulStackSadaqaMessage => 'وقت مشاهدتك ساهم في صدقة حقيقية';

  @override
  String get soulStackWatchYwtl => 'شاهد فيديو الأثر اليوم';

  @override
  String get soulStackDone => 'تم';

  @override
  String get gardenLocked => 'أكمل حزمة الروح لدخول حديقتك (٦ ساعات لكل حزمة)';

  @override
  String get gardenGoToSoulStack => 'اذهب إلى حزمة الروح';

  @override
  String get gardenLocalSaveWarning =>
      'حديقتك محفوظة على هذا الجهاز. إذا حذفت التطبيق ستفقد حديقتك. النسخ الاحتياطي السحابي قريباً.';

  @override
  String get gardenIUnderstand => 'أفهم';

  @override
  String gardenAccessRemaining(String time) {
    return 'وصول الحديقة: $time متبقي';
  }

  @override
  String get gardenPremiumOpen => 'بريميوم — مفتوح دائماً';

  @override
  String get gardenInnerCircle => 'الدائرة الداخلية';

  @override
  String get gardenOuterCircle => 'الدائرة الخارجية';

  @override
  String get gardenAssetStore => 'متجر الأصول';

  @override
  String get gardenRestoreWithCoins => 'استعادة بعملات النور';

  @override
  String get gardenRestoreInstantly => 'استعادة فورية';

  @override
  String get gardenInsufficientCoins =>
      'عملات نور غير كافية — أكمل حزمة الروح لكسب المزيد';

  @override
  String get gardenShareAmal => 'شارك عمل';

  @override
  String get gardenReferralCode => 'رمز الإحالة الخاص بك';

  @override
  String get gardenIntensityLow => 'ازرع البذور. ادعُ الآخرين لبدء رحلتهم.';

  @override
  String get gardenIntensityMedium => 'صدقتك الجارية تنمو. ما شاء الله.';

  @override
  String get gardenIntensityHigh =>
      'غابة مطيرة جميلة، تبقيها حية بمن جلبتهم إلى عمل.';

  @override
  String get gardenIntensityMax => 'سبحان الله. صدقتك الجارية تجري كنهر عظيم.';

  @override
  String get gardenPlace => 'ضع';

  @override
  String get walletBalance => 'الرصيد';

  @override
  String walletTotalEarned(int coins) {
    return 'إجمالي المكتسب: $coins';
  }

  @override
  String get walletTransactionHistory => 'سجل المعاملات';

  @override
  String get walletLoadMore => 'تحميل المزيد';

  @override
  String get walletHowToEarn => 'كيف تكسب عملات النور';

  @override
  String get walletHowToSpend => 'فيمَ يمكنني إنفاق عملات النور؟';

  @override
  String get walletOpenGarden => 'افتح حديقة الجنة';

  @override
  String get walletNoTransactions => 'لا معاملات بعد. ابدأ بكسب عملات النور!';

  @override
  String get ywtlWatchToday => 'شاهد تأثير اليوم';

  @override
  String get ywtlWatchAgain => 'شاهد مرة أخرى';

  @override
  String get ywtlCollectCoins => 'اجمع عملات النور';

  @override
  String ywtlCoinsCollected(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return '+$coinsString عملة نور تم جمعها!';
  }

  @override
  String ywtlAvailableIn(int days) {
    return 'في $days يوم';
  }

  @override
  String get ywtlPreviousWeeks => 'الأسابيع السابقة متاحة على قناتنا في يوتيوب';

  @override
  String get ywtlThisWeek => 'هذا الأسبوع';

  @override
  String get ywtlMonday => 'الإثنين';

  @override
  String get ywtlTuesday => 'الثلاثاء';

  @override
  String get ywtlWednesday => 'الأربعاء';

  @override
  String get ywtlThursday => 'الخميس';

  @override
  String get ywtlFriday => 'الجمعة';

  @override
  String get ywtlSaturday => 'السبت';

  @override
  String get ywtlSunday => 'الأحد';

  @override
  String get settingsNotifications => 'الإشعارات';

  @override
  String get settingsPrayerReminders => 'تذكيرات الصلاة';

  @override
  String get settingsSoulStackReminders => 'تذكيرات حزمة الروح';

  @override
  String get settingsYwtlVideo => 'فيديو YWTL جديد';

  @override
  String get settingsStreakAtRisk => 'السلسلة في خطر';

  @override
  String get settingsAssetFading => 'تحذير تلاشي الأصول';

  @override
  String get settingsPrayerSettings => 'إعدادات الصلاة';

  @override
  String get settingsPrayerTradition => 'مذهب الصلاة';

  @override
  String get settingsCalculationMethod => 'طريقة الحساب';

  @override
  String get settingsLocation => 'الموقع';

  @override
  String get settingsUpdateLocation => 'تحديث الموقع';

  @override
  String get settingsAzanAudio => 'صوت الأذان';

  @override
  String get settingsAppSettings => 'إعدادات التطبيق';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get settingsTheme => 'المظهر';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeSystem => 'النظام';

  @override
  String get settingsHaptic => 'الاهتزاز اللمسي';

  @override
  String get settingsSound => 'المؤثرات الصوتية';

  @override
  String get settingsBiometric => 'تسجيل الدخول البيومتري';

  @override
  String get settingsStreakAtRiskDesc =>
      'يُنبّه الساعة 8 مساءً إذا كانت السلسلة في خطر';

  @override
  String get settingsAssetFadingDesc => 'يحذّر عندما تتلاشى أصول الحديقة';

  @override
  String get settingsAzanMakkah => 'قارئ مكة';

  @override
  String get settingsAzanMadinah => 'قارئ المدينة';

  @override
  String get settingsAzanAlAqsa => 'قارئ الأقصى';

  @override
  String get settingsAzanMishary => 'مشاري راشد';

  @override
  String get profileMemberSince => 'عضو منذ';

  @override
  String get profileFree => 'مجاني';

  @override
  String get profilePremium => 'بريميوم';

  @override
  String get profileReferralCode => 'رمز الإحالة';

  @override
  String get profileTotalEarned => 'إجمالي عملات النور المكتسبة';

  @override
  String get profileCommunityImpact => 'أثر المجتمع';

  @override
  String get profileDataUpdated => 'تم تحديث البيانات';

  @override
  String get profileSubscribe => 'اشترك';

  @override
  String get profileManageSubscription => 'إدارة الاشتراك';

  @override
  String get profileRestorePurchases => 'استعادة المشتريات';

  @override
  String get profileMonthly => 'شهري';

  @override
  String get profileAnnual => 'سنوي';

  @override
  String get profileLogOut => 'تسجيل الخروج';

  @override
  String get profileLogOutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get profileDeleteAccount => 'حذف الحساب';

  @override
  String get profileDeleteWarning =>
      'هذا الإجراء دائم. ستفقد جميع بياناتك وعملات النور وتقدمك. هل أنت متأكد؟';

  @override
  String get profileDeleteConfirmType => 'اكتب DELETE لتأكيد حذف الحساب';

  @override
  String get profileCancel => 'إلغاء';

  @override
  String get profileSaveDiscount => 'وفّر ١٧٪';

  @override
  String get or => 'أو';

  @override
  String get timeJustNow => 'الآن';

  @override
  String timeMinutesAgo(int count) {
    return 'منذ $count د';
  }

  @override
  String timeHoursAgo(int count) {
    return 'منذ $count س';
  }

  @override
  String timeDaysAgo(int count) {
    return 'منذ $count ي';
  }

  @override
  String get walletSourcePrayer => 'الصلاة اليومية';

  @override
  String get walletSourceFast => 'صيام رمضان';

  @override
  String get walletSourceTasbeeh => 'جلسة تسبيح';

  @override
  String get walletSourceSoulStack => 'حزمة الروح';

  @override
  String get walletSourceYwtl => 'فيديو YWTL';

  @override
  String get walletSourceAmal => 'إتمام العمل';

  @override
  String get walletSourceGarden => 'أصل الحديقة';

  @override
  String get walletSpendGarden => 'أصول حديقة الجنة';

  @override
  String get walletSpendRestore => 'استعادة الأصول الباهتة';

  @override
  String get countdownDays => 'أيام';

  @override
  String get countdownHours => 'ساعات';

  @override
  String get countdownMinutes => 'دقائق';

  @override
  String get remove => 'إزالة';

  @override
  String get restore => 'استعادة';

  @override
  String get info => 'معلومات';

  @override
  String get ok => 'حسناً';

  @override
  String get restoreAsset => 'استعادة الأصل';

  @override
  String get copiedToClipboard => 'تم النسخ';

  @override
  String ywtlWatchFullVideo(int coins) {
    return 'شاهد الفيديو كاملاً لجمع $coins نقاط نور';
  }

  @override
  String get comingSoon => 'قريباً';

  @override
  String get forgotPasswordTitle => 'إعادة تعيين كلمة المرور';

  @override
  String get forgotPasswordSubtitle =>
      'أدخل بريدك الإلكتروني وسنرسل لك رابطاً لإعادة تعيين كلمة المرور';

  @override
  String get sendResetLink => 'إرسال رابط إعادة التعيين';

  @override
  String get resetLinkSent =>
      'تم إرسال رابط إعادة تعيين كلمة المرور! تحقق من بريدك الإلكتروني.';

  @override
  String get resetLinkError =>
      'فشل إرسال الرابط. يرجى التحقق من بريدك الإلكتروني والمحاولة مرة أخرى.';

  @override
  String get gardenVisit => 'زُر حديقتك في الجنة';

  @override
  String get soulStackSubtitle => 'اكسب نقاط نور من خلال حزم الدعاء اليومية';

  @override
  String get amalTrackerSubtitle => 'تتبع أعمالك الصالحة وابنِ سلسلة إنجازاتك';

  @override
  String get gardenAwaitsTitle => 'حديقتك في انتظارك';

  @override
  String get gardenAwaitsBody =>
      'أكمل حزمة الروح أو شاهد فيديو لفتح حديقتك لمدة ٦ ساعات.';

  @override
  String get gardenSubscribe => 'اشترك';

  @override
  String get gardenCompleteSoulStack => 'أكمل حزمة الروح';

  @override
  String get gardenWatchVideo => 'شاهد فيديو';

  @override
  String get gardenNotNow => 'ليس الآن';

  @override
  String get gardenPremiumBadge => 'بريميوم — وصول كامل';

  @override
  String get gardenWatchToUnlock => 'شاهد فيديو لفتح الحديقة';

  @override
  String get shopGalleryTitle => 'معرض الحديقة المقدسة';

  @override
  String get shopFeatured => 'مميز';

  @override
  String get shopAddToGarden => 'أضف إلى الحديقة';

  @override
  String get shopInGarden => 'في الحديقة';

  @override
  String get shopEarnMoreNc => 'اكسب المزيد';

  @override
  String get shopAll => 'الكل';

  @override
  String get shopTrees => 'أشجار';

  @override
  String get shopWater => 'ماء';

  @override
  String get shopFruits => 'فواكه';

  @override
  String get shopCreatures => 'مخلوقات';

  @override
  String get shopStructures => 'منشآت';

  @override
  String get shopSacred => 'مقدس';

  @override
  String get shopUnderwater => 'تحت الماء';

  @override
  String get shopSky => 'سماء';

  @override
  String get shopHayatTitle => 'أحيِ جنتك';

  @override
  String get shopHayatDrop => 'قطرة حياة';

  @override
  String get shopHayatBloom => 'إزهار حياة';

  @override
  String get shopNcTitle => 'أضف نقاط نور';

  @override
  String get shopStarterNoor => 'نور مبتدئ';

  @override
  String get shopHandfulNoor => 'حفنة من النور';

  @override
  String get shopGardensWorth => 'قيمة حديقة';

  @override
  String get shopBlessedHarvest => 'الحصاد المبارك';

  @override
  String get hayatLife => 'حياة · الحياة';

  @override
  String get hayatTagline => 'كل حديقة تحتاج رعاية. الحياة تعيدها إلى الحياة.';

  @override
  String get hayatDropTitle => 'قطرة حياة';

  @override
  String get hayatDropEffect => 'تستعيد أصلاً واحداً مختاراً';

  @override
  String get hayatBloomTitle => 'إزهار حياة';

  @override
  String get hayatBloomEffect => 'تستعيد حديقتك بالكامل';

  @override
  String get hayatRestoreOne => 'استعادة أصل واحد';

  @override
  String get hayatRestoreAll => 'استعادة الحديقة كاملة';

  @override
  String get hayatOr => 'أو';

  @override
  String hayatYourBalance(int balance) {
    return 'رصيدك: $balance نقاط نور';
  }

  @override
  String get hayatSelectAsset => 'اختر أصلاً لاستعادته';

  @override
  String get hayatRestoreThis => 'استعادة هذا؟';

  @override
  String plantConfirmTitle(String name, int price) {
    return 'ازرع $name مقابل $price نقاط نور؟';
  }

  @override
  String get plantIt => 'ازرعها';

  @override
  String get notNow => 'ليس الآن';

  @override
  String get earnMorePrompt => 'اكسب المزيد من نقاط النور لزراعة هذه الهدية';

  @override
  String sellConfirmTitle(String name, int price) {
    return 'بيع $name مقابل $price نقاط نور؟';
  }

  @override
  String get sellConfirmBody => 'سيتم إزالته من حديقتك.';

  @override
  String get sellButton => 'بيع';

  @override
  String get tapSlotToPlace => 'انقر على خانة فارغة لوضع أصلك';

  @override
  String get moveAsset => 'نقل';

  @override
  String get sellAsset => 'بيع';

  @override
  String get qmDua => 'دعاء';

  @override
  String get qmHistory => 'التاريخ الإسلامي';

  @override
  String get qmWatchToDiscover => 'شاهد لتكتشف هديتك';

  @override
  String get qmMomentPassed => 'مرت هذه اللحظة. ستأتي واحدة جديدة.';

  @override
  String get qmDiscoveryWaiting => 'اكتشافك لا يزال ينتظر';

  @override
  String get qmDiscoveryBody => 'لديك وقت. هدية مقدسة تنتظرك في حديقتك.';

  @override
  String get jazakAllahuKhairan => 'جزاك الله خيراً';

  @override
  String get sacredContentComingSoon =>
      'المحتوى المقدس قريباً. جزاك الله خيراً.';

  @override
  String get returnToGarden => 'العودة إلى الحديقة';

  @override
  String get outerGardenTitle => 'حديقتك الخارجية';

  @override
  String get outerGardenExplainerBody =>
      'كل شخص تدعوه إلى عمل يزرع بذرة في جنتك الخارجية. كل عمل يقومون به — ينزل المطر في حديقتك. كل شخص يدعونه — عملهم يصل إليك أيضاً. هذه هي الصدقة الجارية. حسنات لا تتوقف.';

  @override
  String get outerGardenExplainerSubtext =>
      'شبكة إحالاتك لا نهائية. كل عمل صالح يتردد صداه.';

  @override
  String get outerGardenEnterButton => 'ادخل حديقتي';

  @override
  String get myNetwork => 'شبكتي';

  @override
  String get copyLink => 'نسخ الرابط';

  @override
  String get linkCopied => 'تم النسخ!';

  @override
  String get shareInvite => 'مشاركة';

  @override
  String get shareInviteMessage =>
      'انضم إليّ في بناء الجنة. كل عمل صالح يتردد صداه. ابدأ حديقة الجنة هنا:';

  @override
  String get directInvites => 'دعوات مباشرة';

  @override
  String get directInvitesDesc => 'الأشخاص الذين انضموا من خلال رابطك مباشرة';

  @override
  String get theirInvites => 'دعواتهم';

  @override
  String get theirInvitesDesc => 'الأشخاص الذين دعاهم المدعوون منك';

  @override
  String get totalNetwork => 'إجمالي الشبكة';

  @override
  String get totalNetworkDesc => 'شبكتك الكاملة على كل مستوى';

  @override
  String get totalNetworkAmals => 'إجمالي الأعمال';

  @override
  String get totalNetworkAmalsDesc => 'الأعمال التي أكملها كل شخص في شبكتك';

  @override
  String get rainfallToday => 'أمطار اليوم';

  @override
  String get rainfallTodayDesc => 'أحداث المطر من نشاط شبكتك اليوم';

  @override
  String get howItWorks => 'كيف يعمل هذا؟';

  @override
  String get howItWorksBody =>
      'كل عمل يكمله أحد من شبكتك يرسل مطراً إلى حديقتك. كلما كانت جذورك أعمق — كلما نمت جنتك أكثر.';

  @override
  String get levelAlRawdah => 'الروضة';

  @override
  String get levelAlFirdaws => 'الفردوس';

  @override
  String get levelAlNaim => 'النعيم';

  @override
  String get levelJannatAlMawa => 'جنة المأوى';

  @override
  String welcomeToLevel(String levelName) {
    return 'مرحباً في $levelName';
  }

  @override
  String get verseLevel2En => 'وَبَشِّرِ الَّذِينَ آمَنُوا';

  @override
  String get verseLevel3En => 'إِنَّ الْمُتَّقِينَ فِي جَنَّاتٍ';

  @override
  String get verseLevel4En => 'فِيهَا أَنْهَارٌ مِّن مَّاءٍ';

  @override
  String get architectViewLabel => 'عرض المعماري';

  @override
  String get immersionViewLabel => 'منغمس';

  @override
  String get plantSomething => 'ازرع شيئاً';

  @override
  String get accessPromptTitle => 'حديقتك في انتظارك';

  @override
  String get accessPromptBody =>
      'أكمل حزمة الروح أو شاهد فيديو لفتح حديقتك لمدة ٦ ساعات.';

  @override
  String get accessSubscribeButton => 'اشترك';

  @override
  String get accessSoulStackButton => 'أكمل حزمة الروح';

  @override
  String get accessYwtlButton => 'شاهد فيديو';

  @override
  String get shopFeaturedLabel => 'مميز هذا الأسبوع';

  @override
  String get shopFilterAll => 'الكل';

  @override
  String get shopFilterTrees => 'أشجار';

  @override
  String get shopFilterWater => 'ماء';

  @override
  String get shopFilterFruits => 'فواكه';

  @override
  String get shopFilterCreatures => 'مخلوقات';

  @override
  String get shopFilterStructures => 'منشآت';

  @override
  String get shopFilterSacred => 'مقدس';

  @override
  String get shopFilterUnderwater => 'تحت الماء';

  @override
  String get shopFilterSky => 'سماء';

  @override
  String get shopHayatTagline =>
      'كل حديقة تحتاج رعاية. الحياة تعيدها إلى الحياة.';

  @override
  String get hayatRestoreFull => 'استعادة الحديقة كاملة';

  @override
  String get plantingConfirmTitle => 'ازرع في جنتك؟';

  @override
  String get plantingConfirmButton => 'ازرعها';

  @override
  String get plantingNotNow => 'ليس الآن';

  @override
  String assetSellConfirm(String name, int nc) {
    return 'بيع $name مقابل $nc نقاط نور؟';
  }

  @override
  String get assetSellRemovalWarning => 'سيتم إزالته من حديقتك.';

  @override
  String get assetSellButton => 'تأكيد البيع';

  @override
  String get questionMarkDua => 'دعاء';

  @override
  String get questionMarkHistory => 'التاريخ الإسلامي';

  @override
  String get questionMarkWatchToDiscover => 'شاهد لتكتشف هديتك';

  @override
  String get questionMarkExpired => 'مرت هذه اللحظة. ستأتي واحدة جديدة.';

  @override
  String get questionMarkPending => 'اكتشافك لا يزال ينتظر. لديك وقت.';

  @override
  String get discoveryJazakAllah => 'جزاك الله خيراً';

  @override
  String get outerGardenSubtitle => 'صدقة جارية';

  @override
  String get outerGardenSkip => 'تخطي';

  @override
  String get referralCopied => 'تم النسخ!';

  @override
  String get referralShareText => 'انضم إليّ في عمل';

  @override
  String get networkDirectInvites => 'دعوات مباشرة';

  @override
  String get networkTheirInvites => 'دعواتهم';

  @override
  String get networkTotal => 'إجمالي الشبكة';

  @override
  String get networkAmals => 'إجمالي الأعمال';

  @override
  String get networkRainfallToday => 'أمطار اليوم';

  @override
  String get myNetworkButton => 'شبكتي';

  @override
  String levelUpWelcome(String name) {
    return 'مرحباً في $name';
  }

  @override
  String get gateSkip => 'تخطي';
}
