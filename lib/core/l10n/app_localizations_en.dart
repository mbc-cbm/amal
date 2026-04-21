// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Amal';

  @override
  String get tagline => 'Every good deed counts';

  @override
  String get welcomeTagline => 'Every action. Every intention. Every day.';

  @override
  String get tapAnywhereToContinue => 'Tap anywhere to continue';

  @override
  String get noorCoins => 'Noor Coins';

  @override
  String noorCoinBalance(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString Noor Coins';
  }

  @override
  String get signInTitle => 'Join Amal';

  @override
  String get signInSubtitle => 'Create your account to begin';

  @override
  String get signIn => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signOut => 'Sign Out';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get emailAndPassword => 'Email & Password';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get confirmPasswordLabel => 'Confirm Password';

  @override
  String get createAccount => 'Create Account';

  @override
  String get alreadyHaveAccount => 'Already have an account? Sign In';

  @override
  String get noAccount => 'Don\'t have an account? Sign Up';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String resetPasswordSent(String email) {
    return 'Reset link sent to $email';
  }

  @override
  String get biometricSignIn => 'Sign in with Face ID / Fingerprint';

  @override
  String get enableBiometric => 'Enable Face ID / Fingerprint';

  @override
  String get enableBiometricSubtitle =>
      'Sign in faster next time with your biometrics';

  @override
  String get biometricPrompt => 'Authenticate to enter Amal';

  @override
  String get usePinInstead => 'Use PIN instead';

  @override
  String get selectLanguageTitle => 'Choose Your Language';

  @override
  String get selectLanguageSubtitle =>
      'You can change this anytime in Settings';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageBengali => 'বাংলা';

  @override
  String get languageUrdu => 'اردو';

  @override
  String get languageArabic => 'العربية';

  @override
  String get prayerTraditionTitle => 'Your Prayer Tradition';

  @override
  String get prayerTraditionSubtitle =>
      'This determines your Azan audio and prayer calculation method';

  @override
  String get sunni => 'Sunni';

  @override
  String get shia => 'Shia';

  @override
  String get continueButton => 'Continue';

  @override
  String get calculationMethodTitle => 'Calculation Method';

  @override
  String get calculationMethodSubtitle =>
      'Select the method used to calculate prayer times in your region';

  @override
  String get profileSetupTitle => 'Set Up Your Profile';

  @override
  String get profileSetupSubtitle =>
      'Tell us your name — you can always change it later';

  @override
  String get nameLabel => 'Your Name';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get changePhoto => 'Change Photo';

  @override
  String get skip => 'Skip';

  @override
  String get saveAndContinue => 'Save & Continue';

  @override
  String get notificationTitle => 'Stay Connected';

  @override
  String get notificationDescription =>
      'Prayer times, Soul Stack reminders, YWTL impact videos, streak reminders, and garden alerts';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get maybeLater => 'Maybe Later';

  @override
  String welcomeToAmalTitle(String name) {
    return 'Welcome, $name';
  }

  @override
  String get impactMessage =>
      'Every time you use Amal, real people receive sadaqa. Your watch time funds real change.';

  @override
  String get enterAmal => 'Enter Amal';

  @override
  String get errorEmailAlreadyInUse =>
      'This email is already registered. Try signing in.';

  @override
  String get errorWeakPassword => 'Password must be at least 8 characters.';

  @override
  String get errorInvalidEmail => 'Please enter a valid email address.';

  @override
  String get errorWrongPassword => 'Incorrect password. Please try again.';

  @override
  String get errorUserNotFound => 'No account found with this email.';

  @override
  String get errorNetworkRequest =>
      'Connection error. Check your internet and try again.';

  @override
  String get errorSignInFailed => 'Sign-in failed. Please try again.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get loading => 'Loading…';

  @override
  String get retry => 'Retry';

  @override
  String get home => 'Home';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get earn => 'Earn';

  @override
  String get garden => 'Garden';

  @override
  String get community => 'Community';

  @override
  String get prayerTime => 'Prayer Time';

  @override
  String get qibla => 'Qibla';

  @override
  String get qiblaPermissionNeeded =>
      'Location permission is needed to determine the Qibla direction. Please enable location services.';

  @override
  String get qiblaOpenSettings => 'Open Settings';

  @override
  String get qiblaCalibrationPrompt =>
      'Compass accuracy is low. Move your phone in a figure-8 pattern to calibrate.';

  @override
  String get qiblaKaabaLabel => 'Kaaba';

  @override
  String get qiblaBearingLabel => 'Qibla Bearing';

  @override
  String get tasbeeh => 'Tasbeeh';

  @override
  String get jannahGarden => 'Jannah Garden';

  @override
  String get noorWallet => 'Noor Wallet';

  @override
  String get soulStack => 'Soul Stack';

  @override
  String get ywtl => 'You Watch, They Live';

  @override
  String get amalTracker => 'Amal Tracker';

  @override
  String get amalGallery => 'Amal Gallery';

  @override
  String get ramadan => 'Ramadan';

  @override
  String get ramadanCountdown => 'Ramadan Countdown';

  @override
  String ramadanDaysRemaining(int days, int hours, int minutes) {
    return 'Ramadan begins in $days days, $hours hours, $minutes minutes';
  }

  @override
  String get ramadanSuhoor => 'Suhoor';

  @override
  String get ramadanIftar => 'Iftar';

  @override
  String get ramadanLogFast => 'Log Today\'s Fast';

  @override
  String get ramadanFastLogged => 'Fast Logged';

  @override
  String get ramadanTarawih => 'Tarawih';

  @override
  String get ramadanTarawihLogged => 'Tarawih Completed';

  @override
  String ramadanFastsCompleted(int count) {
    return '$count Fasts Completed';
  }

  @override
  String get ramadanLastTenNights => 'Last 10 Nights';

  @override
  String ramadanDay(int day) {
    return 'Day $day';
  }

  @override
  String get ramadanMubarak => 'Ramadan Mubarak';

  @override
  String get ramadanLogTarawih => 'Log Tarawih';

  @override
  String get ramadanSeekLaylatulQadr => 'Seek Laylatul Qadr in the odd nights';

  @override
  String get profile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String prayerLogged(int coins) {
    return 'Prayer logged! +$coins Noor Coins';
  }

  @override
  String fastLogged(int coins) {
    return 'Fast logged! +$coins Noor Coins';
  }

  @override
  String tasbeehComplete(int coins) {
    return 'Tasbeeh complete! +$coins Noor Coins';
  }

  @override
  String get fajr => 'Fajr';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get sunrise => 'Sunrise';

  @override
  String homeGreeting(String name) {
    return 'Assalamu Alaikum, $name';
  }

  @override
  String get yourBalance => 'Your Balance';

  @override
  String get setLocationPrompt => 'Tap to set your location for prayer times';

  @override
  String prayerProgress(int done, int total) {
    return '$done of $total prayers';
  }

  @override
  String get viewAllPrayers => 'View All Prayers';

  @override
  String get prayerTimesTitle => 'Prayer Times';

  @override
  String get todaysPrayers => 'Today\'s Prayers';

  @override
  String get modeSilent => 'Silent';

  @override
  String get modeNotification => 'Notify';

  @override
  String get modeAzan => 'Azan';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get changeLocation => 'Change';

  @override
  String get useGps => 'Use GPS';

  @override
  String get cityLabel => 'City';

  @override
  String get countryLabel => 'Country';

  @override
  String get search => 'Search';

  @override
  String get usingCachedData => 'Using cached data';

  @override
  String lastUpdated(String age) {
    return 'Updated $age';
  }

  @override
  String get tasbeehSubhanallah => 'Subhanallah';

  @override
  String get tasbeehAlhamdulillah => 'Alhamdulillah';

  @override
  String get tasbeehAllahuAkbar => 'Allahu Akbar';

  @override
  String get tasbeehAstaghfirullah => 'Astaghfirullah';

  @override
  String get tasbeehTarget => 'Target';

  @override
  String get tasbeehReset => 'Reset';

  @override
  String get tasbeehSessionComplete => 'Session Complete';

  @override
  String get tasbeehSessionHistory => 'Session History';

  @override
  String get tasbeehTotalCount => 'Total Count';

  @override
  String get tasbeehLongestSession => 'Longest Session';

  @override
  String tasbeehCoinsAwarded(int coins) {
    return '+$coins Noor Coins';
  }

  @override
  String get amalCategoryAll => 'All';

  @override
  String get amalCategoryPrayer => 'Prayer';

  @override
  String get amalCategoryFamily => 'Family';

  @override
  String get amalCategoryCommunity => 'Community';

  @override
  String get amalCategorySelf => 'Self';

  @override
  String get amalCategoryKnowledge => 'Knowledge';

  @override
  String get amalCategoryCharity => 'Charity';

  @override
  String get amalSearchHint => 'Search good deeds...';

  @override
  String get amalNoResults => 'No Amals found';

  @override
  String amalNoorCoinsReward(int coins) {
    return '$coins NC';
  }

  @override
  String get amalCompleteButton => 'Complete This Amal';

  @override
  String get amalCompleted => 'Completed';

  @override
  String amalCompletedTimes(int count) {
    return 'Completed $count times';
  }

  @override
  String get amalSource => 'Source';

  @override
  String get amalDifficultyEasy => 'Easy';

  @override
  String get amalDifficultyMedium => 'Medium';

  @override
  String get amalDifficultyHigh => 'High';

  @override
  String get amalOneTime => 'One-time';

  @override
  String get amalDaily => 'Daily';

  @override
  String get amalWeekly => 'Weekly';

  @override
  String get amalOngoing => 'Ongoing';

  @override
  String get amalWatchToComplete => 'Watch to complete';

  @override
  String get trackerMyTracker => 'My Tracker';

  @override
  String get trackerFavourites => 'Favourites';

  @override
  String get trackerTodaysAmal => 'Today\'s Amal';

  @override
  String get trackerDailyGoal => 'Daily Goal';

  @override
  String get trackerSetGoal => 'Set a daily goal';

  @override
  String trackerGoalProgress(int done, int total) {
    return '$done of $total completed today';
  }

  @override
  String get trackerTotalAmals => 'Total Amals';

  @override
  String get trackerTotalCoins => 'Noor Coins Earned';

  @override
  String get trackerDailyStreak => 'Daily Streak';

  @override
  String get trackerLongestDaily => 'Best Daily';

  @override
  String get trackerWeeklyStreak => 'Weekly Streak';

  @override
  String get trackerLongestWeekly => 'Best Weekly';

  @override
  String get trackerRecentActivity => 'Recent Activity';

  @override
  String get trackerEncouragement => 'Every good deed counts. Start today!';

  @override
  String get trackerNoCompletions => 'No completions yet. Begin your journey!';

  @override
  String get trackerNoFavourites =>
      'No favourites yet. Tap the heart on any Amal to save it here.';

  @override
  String get soulStackRise => 'Rise — Morning';

  @override
  String get soulStackShine => 'Shine — Afternoon';

  @override
  String get soulStackGlow => 'Glow — Night';

  @override
  String soulStackProgress(int done) {
    return '$done/5 videos';
  }

  @override
  String soulStackCompletedTimes(int count) {
    return 'Completed $count times today';
  }

  @override
  String get soulStackStartStack => 'Start Stack';

  @override
  String get soulStackStart => 'Start';

  @override
  String get soulStackReady => 'Ready';

  @override
  String get soulStackSwipeUp => 'Swipe up to continue';

  @override
  String get soulStackWhatIsRise =>
      'Rise is your morning dua stack. Watch 5 short videos of beautiful duas to begin your day with intention. Your watch time funds real-world sadaqa.';

  @override
  String get soulStackWhatIsShine =>
      'Shine is your afternoon dua stack. Take a mindful pause with 5 duas. Every second you watch contributes to sadaqa for those in need.';

  @override
  String get soulStackWhatIsGlow =>
      'Glow is your evening dua stack. End your day with 5 beautiful duas. Your watch time generates sadaqa that changes real lives.';

  @override
  String get soulStackMashaAllah => 'MashaAllah!';

  @override
  String soulStackCoinsEarned(int coins) {
    return '+$coins Noor Coins';
  }

  @override
  String get soulStackGardenAccess => '6 hours of Jannah Garden access added';

  @override
  String get soulStackSadaqaMessage =>
      'Your watch time contributed to real-world sadaqa';

  @override
  String get soulStackWatchYwtl => 'Watch today\'s impact video';

  @override
  String get soulStackDone => 'Done';

  @override
  String get gardenLocked =>
      'Complete a Soul Stack to enter your garden (6 hours access per stack)';

  @override
  String get gardenGoToSoulStack => 'Go to Soul Stack';

  @override
  String get gardenLocalSaveWarning =>
      'Your garden is saved on this device. If you delete the app, you will lose your garden. Cloud backup coming soon.';

  @override
  String get gardenIUnderstand => 'I understand';

  @override
  String gardenAccessRemaining(String time) {
    return 'Garden access: $time remaining';
  }

  @override
  String get gardenPremiumOpen => 'Premium — Always Open';

  @override
  String get gardenInnerCircle => 'Inner Circle';

  @override
  String get gardenOuterCircle => 'Outer Circle';

  @override
  String get gardenAssetStore => 'Asset Store';

  @override
  String get gardenRestoreWithCoins => 'Restore with Noor Coins';

  @override
  String get gardenRestoreInstantly => 'Restore Instantly';

  @override
  String get gardenInsufficientCoins =>
      'Not enough Noor Coins — complete a Soul Stack to earn more';

  @override
  String get gardenShareAmal => 'Share Amal';

  @override
  String get gardenReferralCode => 'Your referral code';

  @override
  String get gardenIntensityLow =>
      'Plant seeds. Invite others to begin their journey.';

  @override
  String get gardenIntensityMedium =>
      'Your sadaqa zariyah is growing. MashaAllah.';

  @override
  String get gardenIntensityHigh =>
      'A beautiful rainforest, kept alive by those you brought to Amal.';

  @override
  String get gardenIntensityMax =>
      'SubhanAllah. Your sadaqa zariyah flows like a great river.';

  @override
  String get gardenPlace => 'Place';

  @override
  String get walletBalance => 'Balance';

  @override
  String walletTotalEarned(int coins) {
    return 'Total earned all time: $coins';
  }

  @override
  String get walletTransactionHistory => 'Transaction History';

  @override
  String get walletLoadMore => 'Load More';

  @override
  String get walletHowToEarn => 'How to Earn Noor Coins';

  @override
  String get walletHowToSpend => 'What can I spend Noor Coins on?';

  @override
  String get walletOpenGarden => 'Open Jannah Garden';

  @override
  String get walletNoTransactions =>
      'No transactions yet. Start earning Noor Coins!';

  @override
  String get ywtlWatchToday => 'Watch Today\'s Impact';

  @override
  String get ywtlWatchAgain => 'Watch Again';

  @override
  String get ywtlCollectCoins => 'Collect Your Noor Coins';

  @override
  String ywtlCoinsCollected(int coins) {
    final intl.NumberFormat coinsNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String coinsString = coinsNumberFormat.format(coins);

    return '+$coinsString Noor Coins collected!';
  }

  @override
  String ywtlAvailableIn(int days) {
    return 'In ${days}d';
  }

  @override
  String get ywtlPreviousWeeks =>
      'Previous weeks available on our YouTube channel';

  @override
  String get ywtlThisWeek => 'This Week';

  @override
  String get ywtlMonday => 'Mon';

  @override
  String get ywtlTuesday => 'Tue';

  @override
  String get ywtlWednesday => 'Wed';

  @override
  String get ywtlThursday => 'Thu';

  @override
  String get ywtlFriday => 'Fri';

  @override
  String get ywtlSaturday => 'Sat';

  @override
  String get ywtlSunday => 'Sun';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsPrayerReminders => 'Prayer Reminders';

  @override
  String get settingsSoulStackReminders => 'Soul Stack Reminders';

  @override
  String get settingsYwtlVideo => 'YWTL New Video';

  @override
  String get settingsStreakAtRisk => 'Streak At Risk';

  @override
  String get settingsAssetFading => 'Asset Fading Warning';

  @override
  String get settingsPrayerSettings => 'Prayer Settings';

  @override
  String get settingsPrayerTradition => 'Prayer Tradition';

  @override
  String get settingsCalculationMethod => 'Calculation Method';

  @override
  String get settingsLocation => 'Location';

  @override
  String get settingsUpdateLocation => 'Update Location';

  @override
  String get settingsAzanAudio => 'Azan Audio';

  @override
  String get settingsAppSettings => 'App Settings';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsHaptic => 'Haptic Feedback';

  @override
  String get settingsSound => 'Sound Effects';

  @override
  String get settingsBiometric => 'Biometric Login';

  @override
  String get settingsStreakAtRiskDesc =>
      'Fires at 8:00 PM if streak is at risk';

  @override
  String get settingsAssetFadingDesc => 'Warns when garden assets are fading';

  @override
  String get settingsAzanMakkah => 'Makkah Qari';

  @override
  String get settingsAzanMadinah => 'Madinah Qari';

  @override
  String get settingsAzanAlAqsa => 'Al-Aqsa Qari';

  @override
  String get settingsAzanMishary => 'Mishary Rashid';

  @override
  String get profileMemberSince => 'Member since';

  @override
  String get profileFree => 'Free';

  @override
  String get profilePremium => 'Premium';

  @override
  String get profileReferralCode => 'Referral Code';

  @override
  String get profileTotalEarned => 'Total Noor Coins Earned';

  @override
  String get profileCommunityImpact => 'Community Impact';

  @override
  String get profileDataUpdated => 'Data updated';

  @override
  String get profileSubscribe => 'Subscribe';

  @override
  String get profileManageSubscription => 'Manage Subscription';

  @override
  String get profileRestorePurchases => 'Restore Purchases';

  @override
  String get profileMonthly => 'Monthly';

  @override
  String get profileAnnual => 'Annual';

  @override
  String get profileLogOut => 'Log Out';

  @override
  String get profileLogOutConfirm => 'Are you sure you want to log out?';

  @override
  String get profileDeleteAccount => 'Delete Account';

  @override
  String get profileDeleteWarning =>
      'This action is permanent. All your data, Noor Coins, and progress will be lost. Are you sure?';

  @override
  String get profileDeleteConfirmType =>
      'Type DELETE to confirm account deletion';

  @override
  String get profileCancel => 'Cancel';

  @override
  String get profileSaveDiscount => 'Save 17%';

  @override
  String get or => 'or';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String timeHoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String timeDaysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get walletSourcePrayer => 'Daily Prayer';

  @override
  String get walletSourceFast => 'Ramadan Fast';

  @override
  String get walletSourceTasbeeh => 'Tasbeeh Session';

  @override
  String get walletSourceSoulStack => 'Soul Stack';

  @override
  String get walletSourceYwtl => 'YWTL Video';

  @override
  String get walletSourceAmal => 'Amal Completion';

  @override
  String get walletSourceGarden => 'Garden Asset';

  @override
  String get walletSpendGarden => 'Jannah Garden assets';

  @override
  String get walletSpendRestore => 'Restoring fading garden assets';

  @override
  String get countdownDays => 'DAYS';

  @override
  String get countdownHours => 'HRS';

  @override
  String get countdownMinutes => 'MIN';

  @override
  String get remove => 'Remove';

  @override
  String get restore => 'Restore';

  @override
  String get info => 'Info';

  @override
  String get ok => 'OK';

  @override
  String get restoreAsset => 'Restore Asset';

  @override
  String get copiedToClipboard => 'Copied to clipboard';

  @override
  String ywtlWatchFullVideo(int coins) {
    return 'Watch the full video to collect $coins Noor Coins';
  }

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get forgotPasswordTitle => 'Reset Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email address and we\'ll send you a link to reset your password';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get resetLinkSent => 'Password reset link sent! Check your email.';

  @override
  String get resetLinkError =>
      'Failed to send reset link. Please check your email and try again.';

  @override
  String get gardenVisit => 'Visit Your Jannah Garden';

  @override
  String get soulStackSubtitle => 'Earn Noor Coins through daily dua stacks';

  @override
  String get amalTrackerSubtitle => 'Track your good deeds & build streaks';

  @override
  String get gardenAwaitsTitle => 'Your Garden Awaits';

  @override
  String get gardenAwaitsBody =>
      'Complete a Soul Stack or watch a video to unlock your garden for 6 hours.';

  @override
  String get gardenSubscribe => 'Subscribe';

  @override
  String get gardenCompleteSoulStack => 'Complete Soul Stack';

  @override
  String get gardenWatchVideo => 'Watch a Video';

  @override
  String get gardenNotNow => 'Not now';

  @override
  String get gardenPremiumBadge => 'Premium — Full Access';

  @override
  String get gardenWatchToUnlock => 'Watch a video to unlock';

  @override
  String get shopGalleryTitle => 'Sacred Garden Gallery';

  @override
  String get shopFeatured => 'Featured';

  @override
  String get shopAddToGarden => 'Add to Garden';

  @override
  String get shopInGarden => 'In Garden';

  @override
  String get shopEarnMoreNc => 'Earn More NC';

  @override
  String get shopAll => 'All';

  @override
  String get shopTrees => 'Trees';

  @override
  String get shopWater => 'Water';

  @override
  String get shopFruits => 'Fruits';

  @override
  String get shopCreatures => 'Creatures';

  @override
  String get shopStructures => 'Structures';

  @override
  String get shopSacred => 'Sacred';

  @override
  String get shopUnderwater => 'Underwater';

  @override
  String get shopSky => 'Sky';

  @override
  String get shopHayatTitle => 'Restore Your Paradise';

  @override
  String get shopHayatDrop => 'Hayat Drop';

  @override
  String get shopHayatBloom => 'Hayat Bloom';

  @override
  String get shopNcTitle => 'Add Noor Coins';

  @override
  String get shopStarterNoor => 'Starter Noor';

  @override
  String get shopHandfulNoor => 'A Handful of Noor';

  @override
  String get shopGardensWorth => 'A Garden\'s Worth';

  @override
  String get shopBlessedHarvest => 'The Blessed Harvest';

  @override
  String get hayatLife => 'Hayat · Life';

  @override
  String get hayatTagline =>
      'Every garden needs care. Hayat brings yours back to life.';

  @override
  String get hayatDropTitle => 'Hayat Drop';

  @override
  String get hayatDropEffect => 'Restores one chosen asset';

  @override
  String get hayatBloomTitle => 'Hayat Bloom';

  @override
  String get hayatBloomEffect => 'Restores your entire garden';

  @override
  String get hayatRestoreOne => 'Restore One Asset';

  @override
  String get hayatRestoreAll => 'Restore Full Garden';

  @override
  String get hayatOr => 'or';

  @override
  String hayatYourBalance(int balance) {
    return 'Your balance: $balance Noor Coins';
  }

  @override
  String get hayatSelectAsset => 'Select an asset to restore';

  @override
  String get hayatRestoreThis => 'Restore this?';

  @override
  String plantConfirmTitle(String name, int price) {
    return 'Plant $name for $price Noor Coins?';
  }

  @override
  String get plantIt => 'Plant It';

  @override
  String get notNow => 'Not Now';

  @override
  String get earnMorePrompt => 'Earn more Noor Coins to plant this gift';

  @override
  String sellConfirmTitle(String name, int price) {
    return 'Sell $name for $price NC?';
  }

  @override
  String get sellConfirmBody => 'This removes it from your garden.';

  @override
  String get sellButton => 'Sell';

  @override
  String get tapSlotToPlace => 'Tap an empty slot to place your asset';

  @override
  String get moveAsset => 'Move';

  @override
  String get sellAsset => 'Sell';

  @override
  String get qmDua => 'Dua';

  @override
  String get qmHistory => 'Islamic History';

  @override
  String get qmWatchToDiscover => 'Watch to discover your gift';

  @override
  String get qmMomentPassed => 'This moment passed. A new one will come.';

  @override
  String get qmDiscoveryWaiting => 'Your discovery is still waiting';

  @override
  String get qmDiscoveryBody =>
      'You have time. A sacred gift is waiting for you in your garden.';

  @override
  String get jazakAllahuKhairan => 'JazakAllahu Khairan';

  @override
  String get sacredContentComingSoon =>
      'Sacred content coming soon. JazakAllahu Khairan.';

  @override
  String get returnToGarden => 'Return to Garden';

  @override
  String get outerGardenTitle => 'Your Outer Garden';

  @override
  String get outerGardenExplainerBody =>
      'Every person you invite to Amal plants a seed in your outer paradise. Every Amal they do — rain falls in your garden. Every person they invite — their Amal reaches you too. This is Sadaqa Zariyah. Good deeds that never stop.';

  @override
  String get outerGardenExplainerSubtext =>
      'Your referral network is infinite. Every deed echoes.';

  @override
  String get outerGardenEnterButton => 'Enter My Garden';

  @override
  String get myNetwork => 'My Network';

  @override
  String get copyLink => 'Copy Link';

  @override
  String get linkCopied => 'Copied!';

  @override
  String get shareInvite => 'Share';

  @override
  String get shareInviteMessage =>
      'Join me in building paradise. Every good deed echoes. Start your Jannah Garden here:';

  @override
  String get directInvites => 'Direct Invites';

  @override
  String get directInvitesDesc =>
      'People who joined through your link directly';

  @override
  String get theirInvites => 'Their Invites';

  @override
  String get theirInvitesDesc => 'People invited by your direct invites';

  @override
  String get totalNetwork => 'Total Network';

  @override
  String get totalNetworkDesc => 'Your complete network at every depth';

  @override
  String get totalNetworkAmals => 'Total Amals';

  @override
  String get totalNetworkAmalsDesc =>
      'Amals completed by everyone in your network';

  @override
  String get rainfallToday => 'Rainfall Today';

  @override
  String get rainfallTodayDesc =>
      'Rain events from your network\'s activity today';

  @override
  String get howItWorks => 'How does this work?';

  @override
  String get howItWorksBody =>
      'Every Amal your network completes sends rain to your garden. The deeper the roots you plant — the more your paradise grows.';

  @override
  String get levelAlRawdah => 'Al-Rawdah';

  @override
  String get levelAlFirdaws => 'Al-Firdaws';

  @override
  String get levelAlNaim => 'Al-Na\'im';

  @override
  String get levelJannatAlMawa => 'Jannat al-Ma\'wa';

  @override
  String welcomeToLevel(String levelName) {
    return 'Welcome to $levelName';
  }

  @override
  String get verseLevel2En => 'And give good tidings to those who believe';

  @override
  String get verseLevel3En => 'Indeed, the righteous will be among gardens';

  @override
  String get verseLevel4En => 'In it are rivers of water unaltered';

  @override
  String get architectViewLabel => 'Architect View';

  @override
  String get immersionViewLabel => 'Immersed';

  @override
  String get plantSomething => 'Plant Something';

  @override
  String get accessPromptTitle => 'Your Garden Awaits';

  @override
  String get accessPromptBody =>
      'Complete a Soul Stack or watch a video to unlock your garden for 6 hours.';

  @override
  String get accessSubscribeButton => 'Subscribe';

  @override
  String get accessSoulStackButton => 'Complete Soul Stack';

  @override
  String get accessYwtlButton => 'Watch a Video';

  @override
  String get shopFeaturedLabel => 'Featured This Week';

  @override
  String get shopFilterAll => 'All';

  @override
  String get shopFilterTrees => 'Trees';

  @override
  String get shopFilterWater => 'Water';

  @override
  String get shopFilterFruits => 'Fruits';

  @override
  String get shopFilterCreatures => 'Creatures';

  @override
  String get shopFilterStructures => 'Structures';

  @override
  String get shopFilterSacred => 'Sacred';

  @override
  String get shopFilterUnderwater => 'Underwater';

  @override
  String get shopFilterSky => 'Sky';

  @override
  String get shopHayatTagline =>
      'Every garden needs care. Hayat brings yours back to life.';

  @override
  String get hayatRestoreFull => 'Restore Full Garden';

  @override
  String get plantingConfirmTitle => 'Plant in Your Paradise?';

  @override
  String get plantingConfirmButton => 'Plant It';

  @override
  String get plantingNotNow => 'Not Now';

  @override
  String assetSellConfirm(String name, int nc) {
    return 'Sell $name for $nc Noor Coins?';
  }

  @override
  String get assetSellRemovalWarning => 'This removes it from your garden.';

  @override
  String get assetSellButton => 'Confirm Sale';

  @override
  String get questionMarkDua => 'Dua';

  @override
  String get questionMarkHistory => 'Islamic History';

  @override
  String get questionMarkWatchToDiscover => 'Watch to discover your gift';

  @override
  String get questionMarkExpired => 'This moment passed. A new one will come.';

  @override
  String get questionMarkPending =>
      'Your discovery is still waiting. You have time.';

  @override
  String get discoveryJazakAllah => 'JazakAllahu Khairan';

  @override
  String get outerGardenSubtitle => 'Sadaqa Zariyah';

  @override
  String get outerGardenSkip => 'Skip';

  @override
  String get referralCopied => 'Copied!';

  @override
  String get referralShareText => 'Join me on Amal';

  @override
  String get networkDirectInvites => 'Direct Invites';

  @override
  String get networkTheirInvites => 'Their Invites';

  @override
  String get networkTotal => 'Total Network';

  @override
  String get networkAmals => 'Total Amals';

  @override
  String get networkRainfallToday => 'Rainfall Today';

  @override
  String get myNetworkButton => 'My Network';

  @override
  String levelUpWelcome(String name) {
    return 'Welcome to $name';
  }

  @override
  String get gateSkip => 'Skip';
}
