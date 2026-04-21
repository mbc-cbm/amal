import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('bn'),
    Locale('en'),
    Locale('ur'),
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Amal'**
  String get appName;

  /// Short tagline
  ///
  /// In en, this message translates to:
  /// **'Every good deed counts'**
  String get tagline;

  /// Full onboarding tagline
  ///
  /// In en, this message translates to:
  /// **'Every action. Every intention. Every day.'**
  String get welcomeTagline;

  /// Welcome screen hint
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to continue'**
  String get tapAnywhereToContinue;

  /// Currency name
  ///
  /// In en, this message translates to:
  /// **'Noor Coins'**
  String get noorCoins;

  /// Formatted balance
  ///
  /// In en, this message translates to:
  /// **'{count} Noor Coins'**
  String noorCoinBalance(int count);

  /// Sign in screen heading
  ///
  /// In en, this message translates to:
  /// **'Join Amal'**
  String get signInTitle;

  /// Sign in screen subheading
  ///
  /// In en, this message translates to:
  /// **'Create your account to begin'**
  String get signInSubtitle;

  /// Sign in label
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Sign up label
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Sign out label
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Google sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get continueWithGoogle;

  /// Apple sign-in button
  ///
  /// In en, this message translates to:
  /// **'Continue with Apple'**
  String get continueWithApple;

  /// Email auth button
  ///
  /// In en, this message translates to:
  /// **'Email & Password'**
  String get emailAndPassword;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Confirm password field label
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPasswordLabel;

  /// Create account button
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Switch to sign-in link
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign In'**
  String get alreadyHaveAccount;

  /// Switch to sign-up link
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign Up'**
  String get noAccount;

  /// Forgot password link
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Reset password button
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPassword;

  /// Confirmation after reset email sent
  ///
  /// In en, this message translates to:
  /// **'Reset link sent to {email}'**
  String resetPasswordSent(String email);

  /// Biometric sign-in button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Face ID / Fingerprint'**
  String get biometricSignIn;

  /// Enable biometric prompt title
  ///
  /// In en, this message translates to:
  /// **'Enable Face ID / Fingerprint'**
  String get enableBiometric;

  /// Enable biometric prompt subtitle
  ///
  /// In en, this message translates to:
  /// **'Sign in faster next time with your biometrics'**
  String get enableBiometricSubtitle;

  /// Biometric auth reason string
  ///
  /// In en, this message translates to:
  /// **'Authenticate to enter Amal'**
  String get biometricPrompt;

  /// Fallback from biometric
  ///
  /// In en, this message translates to:
  /// **'Use PIN instead'**
  String get usePinInstead;

  /// Language selection heading
  ///
  /// In en, this message translates to:
  /// **'Choose Your Language'**
  String get selectLanguageTitle;

  /// Language selection subheading
  ///
  /// In en, this message translates to:
  /// **'You can change this anytime in Settings'**
  String get selectLanguageSubtitle;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Bengali language option — always in Bengali script
  ///
  /// In en, this message translates to:
  /// **'বাংলা'**
  String get languageBengali;

  /// Urdu language option — always in Urdu script
  ///
  /// In en, this message translates to:
  /// **'اردو'**
  String get languageUrdu;

  /// Arabic language option — always in Arabic script
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// Prayer tradition screen heading
  ///
  /// In en, this message translates to:
  /// **'Your Prayer Tradition'**
  String get prayerTraditionTitle;

  /// Prayer tradition explanation
  ///
  /// In en, this message translates to:
  /// **'This determines your Azan audio and prayer calculation method'**
  String get prayerTraditionSubtitle;

  /// Sunni tradition label
  ///
  /// In en, this message translates to:
  /// **'Sunni'**
  String get sunni;

  /// Shia tradition label
  ///
  /// In en, this message translates to:
  /// **'Shia'**
  String get shia;

  /// Generic continue button
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// Calculation method screen heading
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get calculationMethodTitle;

  /// Calculation method explanation
  ///
  /// In en, this message translates to:
  /// **'Select the method used to calculate prayer times in your region'**
  String get calculationMethodSubtitle;

  /// Profile setup heading
  ///
  /// In en, this message translates to:
  /// **'Set Up Your Profile'**
  String get profileSetupTitle;

  /// Profile setup subheading
  ///
  /// In en, this message translates to:
  /// **'Tell us your name — you can always change it later'**
  String get profileSetupSubtitle;

  /// Name field label
  ///
  /// In en, this message translates to:
  /// **'Your Name'**
  String get nameLabel;

  /// Add photo button
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// Change photo button
  ///
  /// In en, this message translates to:
  /// **'Change Photo'**
  String get changePhoto;

  /// Skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Save and continue button
  ///
  /// In en, this message translates to:
  /// **'Save & Continue'**
  String get saveAndContinue;

  /// Notification screen heading
  ///
  /// In en, this message translates to:
  /// **'Stay Connected'**
  String get notificationTitle;

  /// Notification permission description
  ///
  /// In en, this message translates to:
  /// **'Prayer times, Soul Stack reminders, YWTL impact videos, streak reminders, and garden alerts'**
  String get notificationDescription;

  /// Allow notifications button
  ///
  /// In en, this message translates to:
  /// **'Allow Notifications'**
  String get allowNotifications;

  /// Decline notifications button
  ///
  /// In en, this message translates to:
  /// **'Maybe Later'**
  String get maybeLater;

  /// Personalized welcome heading
  ///
  /// In en, this message translates to:
  /// **'Welcome, {name}'**
  String welcomeToAmalTitle(String name);

  /// Impact statement on welcome complete screen
  ///
  /// In en, this message translates to:
  /// **'Every time you use Amal, real people receive sadaqa. Your watch time funds real change.'**
  String get impactMessage;

  /// CTA button on welcome complete screen
  ///
  /// In en, this message translates to:
  /// **'Enter Amal'**
  String get enterAmal;

  /// Auth error
  ///
  /// In en, this message translates to:
  /// **'This email is already registered. Try signing in.'**
  String get errorEmailAlreadyInUse;

  /// Auth error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get errorWeakPassword;

  /// Auth error
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address.'**
  String get errorInvalidEmail;

  /// Auth error
  ///
  /// In en, this message translates to:
  /// **'Incorrect password. Please try again.'**
  String get errorWrongPassword;

  /// Auth error
  ///
  /// In en, this message translates to:
  /// **'No account found with this email.'**
  String get errorUserNotFound;

  /// Network error
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your internet and try again.'**
  String get errorNetworkRequest;

  /// Generic sign-in error
  ///
  /// In en, this message translates to:
  /// **'Sign-in failed. Please try again.'**
  String get errorSignInFailed;

  /// Validation error
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// Generic error
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// Loading label
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Section header for feature grid on home screen
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Earn tab
  ///
  /// In en, this message translates to:
  /// **'Earn'**
  String get earn;

  /// Garden tab
  ///
  /// In en, this message translates to:
  /// **'Garden'**
  String get garden;

  /// Community label
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get community;

  /// Prayer feature label
  ///
  /// In en, this message translates to:
  /// **'Prayer Time'**
  String get prayerTime;

  /// Qibla feature label
  ///
  /// In en, this message translates to:
  /// **'Qibla'**
  String get qibla;

  /// Shown when location is unavailable for Qibla
  ///
  /// In en, this message translates to:
  /// **'Location permission is needed to determine the Qibla direction. Please enable location services.'**
  String get qiblaPermissionNeeded;

  /// Button to open location settings from Qibla screen
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get qiblaOpenSettings;

  /// Prompt shown when magnetometer needs calibration
  ///
  /// In en, this message translates to:
  /// **'Compass accuracy is low. Move your phone in a figure-8 pattern to calibrate.'**
  String get qiblaCalibrationPrompt;

  /// Label under the Kaaba icon on Qibla screen
  ///
  /// In en, this message translates to:
  /// **'Kaaba'**
  String get qiblaKaabaLabel;

  /// Label under the bearing degrees on Qibla screen
  ///
  /// In en, this message translates to:
  /// **'Qibla Bearing'**
  String get qiblaBearingLabel;

  /// Tasbeeh feature label
  ///
  /// In en, this message translates to:
  /// **'Tasbeeh'**
  String get tasbeeh;

  /// Garden feature label
  ///
  /// In en, this message translates to:
  /// **'Jannah Garden'**
  String get jannahGarden;

  /// Wallet feature label
  ///
  /// In en, this message translates to:
  /// **'Noor Wallet'**
  String get noorWallet;

  /// Soul Stack feature label
  ///
  /// In en, this message translates to:
  /// **'Soul Stack'**
  String get soulStack;

  /// YWTL feature label
  ///
  /// In en, this message translates to:
  /// **'You Watch, They Live'**
  String get ywtl;

  /// Amal Tracker feature label
  ///
  /// In en, this message translates to:
  /// **'Amal Tracker'**
  String get amalTracker;

  /// Amal Gallery feature label
  ///
  /// In en, this message translates to:
  /// **'Amal Gallery'**
  String get amalGallery;

  /// Ramadan feature label
  ///
  /// In en, this message translates to:
  /// **'Ramadan'**
  String get ramadan;

  /// Ramadan countdown heading
  ///
  /// In en, this message translates to:
  /// **'Ramadan Countdown'**
  String get ramadanCountdown;

  /// Countdown to Ramadan
  ///
  /// In en, this message translates to:
  /// **'Ramadan begins in {days} days, {hours} hours, {minutes} minutes'**
  String ramadanDaysRemaining(int days, int hours, int minutes);

  /// Suhoor label
  ///
  /// In en, this message translates to:
  /// **'Suhoor'**
  String get ramadanSuhoor;

  /// Iftar label
  ///
  /// In en, this message translates to:
  /// **'Iftar'**
  String get ramadanIftar;

  /// Button to log fast
  ///
  /// In en, this message translates to:
  /// **'Log Today\'s Fast'**
  String get ramadanLogFast;

  /// Fast already logged label
  ///
  /// In en, this message translates to:
  /// **'Fast Logged'**
  String get ramadanFastLogged;

  /// Tarawih label
  ///
  /// In en, this message translates to:
  /// **'Tarawih'**
  String get ramadanTarawih;

  /// Tarawih logged label
  ///
  /// In en, this message translates to:
  /// **'Tarawih Completed'**
  String get ramadanTarawihLogged;

  /// Running fasts completed count
  ///
  /// In en, this message translates to:
  /// **'{count} Fasts Completed'**
  String ramadanFastsCompleted(int count);

  /// Last 10 nights section heading
  ///
  /// In en, this message translates to:
  /// **'Last 10 Nights'**
  String get ramadanLastTenNights;

  /// Ramadan day label
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String ramadanDay(int day);

  /// Ramadan greeting
  ///
  /// In en, this message translates to:
  /// **'Ramadan Mubarak'**
  String get ramadanMubarak;

  /// Button to log tarawih
  ///
  /// In en, this message translates to:
  /// **'Log Tarawih'**
  String get ramadanLogTarawih;

  /// Laylatul Qadr reminder
  ///
  /// In en, this message translates to:
  /// **'Seek Laylatul Qadr in the odd nights'**
  String get ramadanSeekLaylatulQadr;

  /// Profile label
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Settings label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Prayer logged confirmation
  ///
  /// In en, this message translates to:
  /// **'Prayer logged! +{coins} Noor Coins'**
  String prayerLogged(int coins);

  /// Fast logged confirmation
  ///
  /// In en, this message translates to:
  /// **'Fast logged! +{coins} Noor Coins'**
  String fastLogged(int coins);

  /// Tasbeeh complete confirmation
  ///
  /// In en, this message translates to:
  /// **'Tasbeeh complete! +{coins} Noor Coins'**
  String tasbeehComplete(int coins);

  /// Fajr prayer name
  ///
  /// In en, this message translates to:
  /// **'Fajr'**
  String get fajr;

  /// Dhuhr prayer name
  ///
  /// In en, this message translates to:
  /// **'Dhuhr'**
  String get dhuhr;

  /// Asr prayer name
  ///
  /// In en, this message translates to:
  /// **'Asr'**
  String get asr;

  /// Maghrib prayer name
  ///
  /// In en, this message translates to:
  /// **'Maghrib'**
  String get maghrib;

  /// Isha prayer name
  ///
  /// In en, this message translates to:
  /// **'Isha'**
  String get isha;

  /// Sunrise label
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get sunrise;

  /// Home screen greeting
  ///
  /// In en, this message translates to:
  /// **'Assalamu Alaikum, {name}'**
  String homeGreeting(String name);

  /// Balance label on home screen
  ///
  /// In en, this message translates to:
  /// **'Your Balance'**
  String get yourBalance;

  /// Prompt when location not set
  ///
  /// In en, this message translates to:
  /// **'Tap to set your location for prayer times'**
  String get setLocationPrompt;

  /// Prayer completion progress
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} prayers'**
  String prayerProgress(int done, int total);

  /// Link to full prayer screen
  ///
  /// In en, this message translates to:
  /// **'View All Prayers'**
  String get viewAllPrayers;

  /// Prayer screen title
  ///
  /// In en, this message translates to:
  /// **'Prayer Times'**
  String get prayerTimesTitle;

  /// Section heading
  ///
  /// In en, this message translates to:
  /// **'Today\'s Prayers'**
  String get todaysPrayers;

  /// Silent notification mode
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get modeSilent;

  /// Push notification mode
  ///
  /// In en, this message translates to:
  /// **'Notify'**
  String get modeNotification;

  /// Azan audio notification mode
  ///
  /// In en, this message translates to:
  /// **'Azan'**
  String get modeAzan;

  /// Notification settings heading
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// Change location button
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get changeLocation;

  /// Use GPS button
  ///
  /// In en, this message translates to:
  /// **'Use GPS'**
  String get useGps;

  /// City input label
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get cityLabel;

  /// Country input label
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get countryLabel;

  /// Search button
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// Cache notice
  ///
  /// In en, this message translates to:
  /// **'Using cached data'**
  String get usingCachedData;

  /// Last updated timestamp
  ///
  /// In en, this message translates to:
  /// **'Updated {age}'**
  String lastUpdated(String age);

  /// Dhikr name
  ///
  /// In en, this message translates to:
  /// **'Subhanallah'**
  String get tasbeehSubhanallah;

  /// Dhikr name
  ///
  /// In en, this message translates to:
  /// **'Alhamdulillah'**
  String get tasbeehAlhamdulillah;

  /// Dhikr name
  ///
  /// In en, this message translates to:
  /// **'Allahu Akbar'**
  String get tasbeehAllahuAkbar;

  /// Dhikr name
  ///
  /// In en, this message translates to:
  /// **'Astaghfirullah'**
  String get tasbeehAstaghfirullah;

  /// Target count label
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get tasbeehTarget;

  /// Reset button label
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get tasbeehReset;

  /// Completion overlay heading
  ///
  /// In en, this message translates to:
  /// **'Session Complete'**
  String get tasbeehSessionComplete;

  /// History section heading
  ///
  /// In en, this message translates to:
  /// **'Session History'**
  String get tasbeehSessionHistory;

  /// Total count stat label
  ///
  /// In en, this message translates to:
  /// **'Total Count'**
  String get tasbeehTotalCount;

  /// Longest session stat label
  ///
  /// In en, this message translates to:
  /// **'Longest Session'**
  String get tasbeehLongestSession;

  /// Coins awarded message
  ///
  /// In en, this message translates to:
  /// **'+{coins} Noor Coins'**
  String tasbeehCoinsAwarded(int coins);

  /// All categories filter
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get amalCategoryAll;

  /// Prayer category
  ///
  /// In en, this message translates to:
  /// **'Prayer'**
  String get amalCategoryPrayer;

  /// Family category
  ///
  /// In en, this message translates to:
  /// **'Family'**
  String get amalCategoryFamily;

  /// Community category
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get amalCategoryCommunity;

  /// Self category
  ///
  /// In en, this message translates to:
  /// **'Self'**
  String get amalCategorySelf;

  /// Knowledge category
  ///
  /// In en, this message translates to:
  /// **'Knowledge'**
  String get amalCategoryKnowledge;

  /// Charity category
  ///
  /// In en, this message translates to:
  /// **'Charity'**
  String get amalCategoryCharity;

  /// Search field placeholder
  ///
  /// In en, this message translates to:
  /// **'Search good deeds...'**
  String get amalSearchHint;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'No Amals found'**
  String get amalNoResults;

  /// Noor Coins reward badge
  ///
  /// In en, this message translates to:
  /// **'{coins} NC'**
  String amalNoorCoinsReward(int coins);

  /// Completion button
  ///
  /// In en, this message translates to:
  /// **'Complete This Amal'**
  String get amalCompleteButton;

  /// Completed badge
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get amalCompleted;

  /// Completion count
  ///
  /// In en, this message translates to:
  /// **'Completed {count} times'**
  String amalCompletedTimes(int count);

  /// Source label
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get amalSource;

  /// Easy difficulty
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get amalDifficultyEasy;

  /// Medium difficulty
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get amalDifficultyMedium;

  /// High difficulty
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get amalDifficultyHigh;

  /// One-time completion type
  ///
  /// In en, this message translates to:
  /// **'One-time'**
  String get amalOneTime;

  /// Daily completion type
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get amalDaily;

  /// Weekly completion type
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get amalWeekly;

  /// Ongoing completion type
  ///
  /// In en, this message translates to:
  /// **'Ongoing'**
  String get amalOngoing;

  /// Video watch prompt
  ///
  /// In en, this message translates to:
  /// **'Watch to complete'**
  String get amalWatchToComplete;

  /// Tracker tab label
  ///
  /// In en, this message translates to:
  /// **'My Tracker'**
  String get trackerMyTracker;

  /// Favourites tab label
  ///
  /// In en, this message translates to:
  /// **'Favourites'**
  String get trackerFavourites;

  /// Amal of the day heading
  ///
  /// In en, this message translates to:
  /// **'Today\'s Amal'**
  String get trackerTodaysAmal;

  /// Daily goal heading
  ///
  /// In en, this message translates to:
  /// **'Daily Goal'**
  String get trackerDailyGoal;

  /// Prompt to set goal
  ///
  /// In en, this message translates to:
  /// **'Set a daily goal'**
  String get trackerSetGoal;

  /// Daily goal progress
  ///
  /// In en, this message translates to:
  /// **'{done} of {total} completed today'**
  String trackerGoalProgress(int done, int total);

  /// Total amals stat
  ///
  /// In en, this message translates to:
  /// **'Total Amals'**
  String get trackerTotalAmals;

  /// Total coins from amals stat
  ///
  /// In en, this message translates to:
  /// **'Noor Coins Earned'**
  String get trackerTotalCoins;

  /// Current daily streak
  ///
  /// In en, this message translates to:
  /// **'Daily Streak'**
  String get trackerDailyStreak;

  /// Longest daily streak
  ///
  /// In en, this message translates to:
  /// **'Best Daily'**
  String get trackerLongestDaily;

  /// Current weekly streak
  ///
  /// In en, this message translates to:
  /// **'Weekly Streak'**
  String get trackerWeeklyStreak;

  /// Longest weekly streak
  ///
  /// In en, this message translates to:
  /// **'Best Weekly'**
  String get trackerLongestWeekly;

  /// Recent completions heading
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get trackerRecentActivity;

  /// Encouragement when no goal set
  ///
  /// In en, this message translates to:
  /// **'Every good deed counts. Start today!'**
  String get trackerEncouragement;

  /// Empty state for recent activity
  ///
  /// In en, this message translates to:
  /// **'No completions yet. Begin your journey!'**
  String get trackerNoCompletions;

  /// Empty state for favourites tab
  ///
  /// In en, this message translates to:
  /// **'No favourites yet. Tap the heart on any Amal to save it here.'**
  String get trackerNoFavourites;

  /// Rise stack label
  ///
  /// In en, this message translates to:
  /// **'Rise — Morning'**
  String get soulStackRise;

  /// Shine stack label
  ///
  /// In en, this message translates to:
  /// **'Shine — Afternoon'**
  String get soulStackShine;

  /// Glow stack label
  ///
  /// In en, this message translates to:
  /// **'Glow — Night'**
  String get soulStackGlow;

  /// Stack video progress
  ///
  /// In en, this message translates to:
  /// **'{done}/5 videos'**
  String soulStackProgress(int done);

  /// Stack completion count
  ///
  /// In en, this message translates to:
  /// **'Completed {count} times today'**
  String soulStackCompletedTimes(int count);

  /// Start stack button
  ///
  /// In en, this message translates to:
  /// **'Start Stack'**
  String get soulStackStartStack;

  /// Start button in flow
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get soulStackStart;

  /// Ready button in flow
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get soulStackReady;

  /// Swipe instruction
  ///
  /// In en, this message translates to:
  /// **'Swipe up to continue'**
  String get soulStackSwipeUp;

  /// Rise explanation
  ///
  /// In en, this message translates to:
  /// **'Rise is your morning dua stack. Watch 5 short videos of beautiful duas to begin your day with intention. Your watch time funds real-world sadaqa.'**
  String get soulStackWhatIsRise;

  /// Shine explanation
  ///
  /// In en, this message translates to:
  /// **'Shine is your afternoon dua stack. Take a mindful pause with 5 duas. Every second you watch contributes to sadaqa for those in need.'**
  String get soulStackWhatIsShine;

  /// Glow explanation
  ///
  /// In en, this message translates to:
  /// **'Glow is your evening dua stack. End your day with 5 beautiful duas. Your watch time generates sadaqa that changes real lives.'**
  String get soulStackWhatIsGlow;

  /// Achievement title
  ///
  /// In en, this message translates to:
  /// **'MashaAllah!'**
  String get soulStackMashaAllah;

  /// Coins earned message
  ///
  /// In en, this message translates to:
  /// **'+{coins} Noor Coins'**
  String soulStackCoinsEarned(int coins);

  /// Garden access message
  ///
  /// In en, this message translates to:
  /// **'6 hours of Jannah Garden access added'**
  String get soulStackGardenAccess;

  /// Sadaqa contribution message
  ///
  /// In en, this message translates to:
  /// **'Your watch time contributed to real-world sadaqa'**
  String get soulStackSadaqaMessage;

  /// YWTL button on achievement
  ///
  /// In en, this message translates to:
  /// **'Watch today\'s impact video'**
  String get soulStackWatchYwtl;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get soulStackDone;

  /// Garden locked message
  ///
  /// In en, this message translates to:
  /// **'Complete a Soul Stack to enter your garden (6 hours access per stack)'**
  String get gardenLocked;

  /// Button to navigate to Soul Stack from locked garden
  ///
  /// In en, this message translates to:
  /// **'Go to Soul Stack'**
  String get gardenGoToSoulStack;

  /// First-time warning about local-only save
  ///
  /// In en, this message translates to:
  /// **'Your garden is saved on this device. If you delete the app, you will lose your garden. Cloud backup coming soon.'**
  String get gardenLocalSaveWarning;

  /// Acknowledge garden warning button
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get gardenIUnderstand;

  /// Timer showing remaining garden access
  ///
  /// In en, this message translates to:
  /// **'Garden access: {time} remaining'**
  String gardenAccessRemaining(String time);

  /// Premium user garden status
  ///
  /// In en, this message translates to:
  /// **'Premium — Always Open'**
  String get gardenPremiumOpen;

  /// Inner circle toggle label
  ///
  /// In en, this message translates to:
  /// **'Inner Circle'**
  String get gardenInnerCircle;

  /// Outer circle toggle label
  ///
  /// In en, this message translates to:
  /// **'Outer Circle'**
  String get gardenOuterCircle;

  /// Asset store heading
  ///
  /// In en, this message translates to:
  /// **'Asset Store'**
  String get gardenAssetStore;

  /// Restore asset with coins button
  ///
  /// In en, this message translates to:
  /// **'Restore with Noor Coins'**
  String get gardenRestoreWithCoins;

  /// Restore asset instantly button
  ///
  /// In en, this message translates to:
  /// **'Restore Instantly'**
  String get gardenRestoreInstantly;

  /// Insufficient coins error
  ///
  /// In en, this message translates to:
  /// **'Not enough Noor Coins — complete a Soul Stack to earn more'**
  String get gardenInsufficientCoins;

  /// Share referral button
  ///
  /// In en, this message translates to:
  /// **'Share Amal'**
  String get gardenShareAmal;

  /// Referral code label
  ///
  /// In en, this message translates to:
  /// **'Your referral code'**
  String get gardenReferralCode;

  /// Low intensity message
  ///
  /// In en, this message translates to:
  /// **'Plant seeds. Invite others to begin their journey.'**
  String get gardenIntensityLow;

  /// Medium intensity message
  ///
  /// In en, this message translates to:
  /// **'Your sadaqa zariyah is growing. MashaAllah.'**
  String get gardenIntensityMedium;

  /// High intensity message
  ///
  /// In en, this message translates to:
  /// **'A beautiful rainforest, kept alive by those you brought to Amal.'**
  String get gardenIntensityHigh;

  /// Max intensity message
  ///
  /// In en, this message translates to:
  /// **'SubhanAllah. Your sadaqa zariyah flows like a great river.'**
  String get gardenIntensityMax;

  /// Place asset button
  ///
  /// In en, this message translates to:
  /// **'Place'**
  String get gardenPlace;

  /// Wallet balance heading
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get walletBalance;

  /// Total coins ever earned
  ///
  /// In en, this message translates to:
  /// **'Total earned all time: {coins}'**
  String walletTotalEarned(int coins);

  /// Transaction history section heading
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get walletTransactionHistory;

  /// Load more transactions button
  ///
  /// In en, this message translates to:
  /// **'Load More'**
  String get walletLoadMore;

  /// Earning guide section heading
  ///
  /// In en, this message translates to:
  /// **'How to Earn Noor Coins'**
  String get walletHowToEarn;

  /// Spending guide section heading
  ///
  /// In en, this message translates to:
  /// **'What can I spend Noor Coins on?'**
  String get walletHowToSpend;

  /// Navigate to garden button
  ///
  /// In en, this message translates to:
  /// **'Open Jannah Garden'**
  String get walletOpenGarden;

  /// Empty state for transactions
  ///
  /// In en, this message translates to:
  /// **'No transactions yet. Start earning Noor Coins!'**
  String get walletNoTransactions;

  /// YWTL watch button
  ///
  /// In en, this message translates to:
  /// **'Watch Today\'s Impact'**
  String get ywtlWatchToday;

  /// YWTL rewatch button
  ///
  /// In en, this message translates to:
  /// **'Watch Again'**
  String get ywtlWatchAgain;

  /// YWTL collect coins button
  ///
  /// In en, this message translates to:
  /// **'Collect Your Noor Coins'**
  String get ywtlCollectCoins;

  /// YWTL coins collected confirmation
  ///
  /// In en, this message translates to:
  /// **'+{coins} Noor Coins collected!'**
  String ywtlCoinsCollected(int coins);

  /// YWTL days until available
  ///
  /// In en, this message translates to:
  /// **'In {days}d'**
  String ywtlAvailableIn(int days);

  /// YWTL previous weeks note
  ///
  /// In en, this message translates to:
  /// **'Previous weeks available on our YouTube channel'**
  String get ywtlPreviousWeeks;

  /// YWTL this week heading
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get ywtlThisWeek;

  /// Monday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get ywtlMonday;

  /// Tuesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get ywtlTuesday;

  /// Wednesday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get ywtlWednesday;

  /// Thursday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get ywtlThursday;

  /// Friday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get ywtlFriday;

  /// Saturday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get ywtlSaturday;

  /// Sunday abbreviation
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get ywtlSunday;

  /// Notifications section heading
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// Prayer reminders subsection
  ///
  /// In en, this message translates to:
  /// **'Prayer Reminders'**
  String get settingsPrayerReminders;

  /// Soul Stack reminders subsection
  ///
  /// In en, this message translates to:
  /// **'Soul Stack Reminders'**
  String get settingsSoulStackReminders;

  /// YWTL video reminder
  ///
  /// In en, this message translates to:
  /// **'YWTL New Video'**
  String get settingsYwtlVideo;

  /// Streak at risk reminder
  ///
  /// In en, this message translates to:
  /// **'Streak At Risk'**
  String get settingsStreakAtRisk;

  /// Asset fading warning reminder
  ///
  /// In en, this message translates to:
  /// **'Asset Fading Warning'**
  String get settingsAssetFading;

  /// Prayer settings section heading
  ///
  /// In en, this message translates to:
  /// **'Prayer Settings'**
  String get settingsPrayerSettings;

  /// Prayer tradition setting
  ///
  /// In en, this message translates to:
  /// **'Prayer Tradition'**
  String get settingsPrayerTradition;

  /// Calculation method setting
  ///
  /// In en, this message translates to:
  /// **'Calculation Method'**
  String get settingsCalculationMethod;

  /// Location setting
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get settingsLocation;

  /// Update location button
  ///
  /// In en, this message translates to:
  /// **'Update Location'**
  String get settingsUpdateLocation;

  /// Azan audio setting
  ///
  /// In en, this message translates to:
  /// **'Azan Audio'**
  String get settingsAzanAudio;

  /// App settings section heading
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get settingsAppSettings;

  /// Language setting
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Theme setting
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Haptic feedback setting
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get settingsHaptic;

  /// Sound effects setting
  ///
  /// In en, this message translates to:
  /// **'Sound Effects'**
  String get settingsSound;

  /// Biometric login setting
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get settingsBiometric;

  /// Streak at risk description
  ///
  /// In en, this message translates to:
  /// **'Fires at 8:00 PM if streak is at risk'**
  String get settingsStreakAtRiskDesc;

  /// Asset fading description
  ///
  /// In en, this message translates to:
  /// **'Warns when garden assets are fading'**
  String get settingsAssetFadingDesc;

  /// Makkah azan option
  ///
  /// In en, this message translates to:
  /// **'Makkah Qari'**
  String get settingsAzanMakkah;

  /// Madinah azan option
  ///
  /// In en, this message translates to:
  /// **'Madinah Qari'**
  String get settingsAzanMadinah;

  /// Al-Aqsa azan option
  ///
  /// In en, this message translates to:
  /// **'Al-Aqsa Qari'**
  String get settingsAzanAlAqsa;

  /// Mishary Rashid azan option
  ///
  /// In en, this message translates to:
  /// **'Mishary Rashid'**
  String get settingsAzanMishary;

  /// Member since label
  ///
  /// In en, this message translates to:
  /// **'Member since'**
  String get profileMemberSince;

  /// Free subscription badge
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get profileFree;

  /// Premium subscription badge
  ///
  /// In en, this message translates to:
  /// **'Premium'**
  String get profilePremium;

  /// Referral code label
  ///
  /// In en, this message translates to:
  /// **'Referral Code'**
  String get profileReferralCode;

  /// Total earned label
  ///
  /// In en, this message translates to:
  /// **'Total Noor Coins Earned'**
  String get profileTotalEarned;

  /// Community impact section heading
  ///
  /// In en, this message translates to:
  /// **'Community Impact'**
  String get profileCommunityImpact;

  /// Data updated footer for FTC compliance
  ///
  /// In en, this message translates to:
  /// **'Data updated'**
  String get profileDataUpdated;

  /// Subscribe button
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get profileSubscribe;

  /// Manage subscription button
  ///
  /// In en, this message translates to:
  /// **'Manage Subscription'**
  String get profileManageSubscription;

  /// Restore purchases button
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get profileRestorePurchases;

  /// Monthly plan label
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get profileMonthly;

  /// Annual plan label
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get profileAnnual;

  /// Log out button
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profileLogOut;

  /// Log out confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profileLogOutConfirm;

  /// Delete account button
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profileDeleteAccount;

  /// Delete account warning text
  ///
  /// In en, this message translates to:
  /// **'This action is permanent. All your data, Noor Coins, and progress will be lost. Are you sure?'**
  String get profileDeleteWarning;

  /// Delete confirmation instruction
  ///
  /// In en, this message translates to:
  /// **'Type DELETE to confirm account deletion'**
  String get profileDeleteConfirmType;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profileCancel;

  /// Annual plan discount label
  ///
  /// In en, this message translates to:
  /// **'Save 17%'**
  String get profileSaveDiscount;

  /// Divider label between auth methods
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get or;

  /// Time ago label for very recent
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// Minutes ago
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String timeMinutesAgo(int count);

  /// Hours ago
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeHoursAgo(int count);

  /// Days ago
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String timeDaysAgo(int count);

  /// Wallet transaction source label
  ///
  /// In en, this message translates to:
  /// **'Daily Prayer'**
  String get walletSourcePrayer;

  /// Wallet transaction source label
  ///
  /// In en, this message translates to:
  /// **'Ramadan Fast'**
  String get walletSourceFast;

  /// Wallet transaction source label
  ///
  /// In en, this message translates to:
  /// **'Tasbeeh Session'**
  String get walletSourceTasbeeh;

  /// Wallet transaction source label
  ///
  /// In en, this message translates to:
  /// **'Soul Stack'**
  String get walletSourceSoulStack;

  /// Wallet transaction source label
  ///
  /// In en, this message translates to:
  /// **'YWTL Video'**
  String get walletSourceYwtl;

  /// Wallet transaction source label
  ///
  /// In en, this message translates to:
  /// **'Amal Completion'**
  String get walletSourceAmal;

  /// Wallet transaction source label
  ///
  /// In en, this message translates to:
  /// **'Garden Asset'**
  String get walletSourceGarden;

  /// Spending guide label
  ///
  /// In en, this message translates to:
  /// **'Jannah Garden assets'**
  String get walletSpendGarden;

  /// Spending guide label
  ///
  /// In en, this message translates to:
  /// **'Restoring fading garden assets'**
  String get walletSpendRestore;

  /// Countdown unit label
  ///
  /// In en, this message translates to:
  /// **'DAYS'**
  String get countdownDays;

  /// Countdown unit label
  ///
  /// In en, this message translates to:
  /// **'HRS'**
  String get countdownHours;

  /// Countdown unit label
  ///
  /// In en, this message translates to:
  /// **'MIN'**
  String get countdownMinutes;

  /// Remove action label
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// Restore action label
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// Info action label
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// OK button label
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// Restore asset dialog title
  ///
  /// In en, this message translates to:
  /// **'Restore Asset'**
  String get restoreAsset;

  /// Clipboard copy confirmation
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// YWTL video instruction
  ///
  /// In en, this message translates to:
  /// **'Watch the full video to collect {coins} Noor Coins'**
  String ywtlWatchFullVideo(int coins);

  /// Feature coming soon placeholder
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Forgot password screen title
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get forgotPasswordTitle;

  /// Forgot password instruction
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we\'ll send you a link to reset your password'**
  String get forgotPasswordSubtitle;

  /// Send password reset email button
  ///
  /// In en, this message translates to:
  /// **'Send Reset Link'**
  String get sendResetLink;

  /// Success message after sending reset link
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent! Check your email.'**
  String get resetLinkSent;

  /// Error message for reset link failure
  ///
  /// In en, this message translates to:
  /// **'Failed to send reset link. Please check your email and try again.'**
  String get resetLinkError;

  /// Garden widget subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'Visit Your Jannah Garden'**
  String get gardenVisit;

  /// Soul Stack widget subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'Earn Noor Coins through daily dua stacks'**
  String get soulStackSubtitle;

  /// Amal Tracker widget subtitle on home screen
  ///
  /// In en, this message translates to:
  /// **'Track your good deeds & build streaks'**
  String get amalTrackerSubtitle;

  /// Access prompt sheet title
  ///
  /// In en, this message translates to:
  /// **'Your Garden Awaits'**
  String get gardenAwaitsTitle;

  /// Access prompt sheet body
  ///
  /// In en, this message translates to:
  /// **'Complete a Soul Stack or watch a video to unlock your garden for 6 hours.'**
  String get gardenAwaitsBody;

  /// Subscribe button on access prompt
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get gardenSubscribe;

  /// Soul stack button on access prompt
  ///
  /// In en, this message translates to:
  /// **'Complete Soul Stack'**
  String get gardenCompleteSoulStack;

  /// Watch video button on access prompt
  ///
  /// In en, this message translates to:
  /// **'Watch a Video'**
  String get gardenWatchVideo;

  /// Dismiss access prompt
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get gardenNotNow;

  /// Premium badge in timer overlay
  ///
  /// In en, this message translates to:
  /// **'Premium — Full Access'**
  String get gardenPremiumBadge;

  /// Gentle invitation when no timer active
  ///
  /// In en, this message translates to:
  /// **'Watch a video to unlock'**
  String get gardenWatchToUnlock;

  /// Shop screen title
  ///
  /// In en, this message translates to:
  /// **'Sacred Garden Gallery'**
  String get shopGalleryTitle;

  /// Featured asset badge
  ///
  /// In en, this message translates to:
  /// **'Featured'**
  String get shopFeatured;

  /// Purchase/add button
  ///
  /// In en, this message translates to:
  /// **'Add to Garden'**
  String get shopAddToGarden;

  /// Already owned badge
  ///
  /// In en, this message translates to:
  /// **'In Garden'**
  String get shopInGarden;

  /// Insufficient balance button
  ///
  /// In en, this message translates to:
  /// **'Earn More NC'**
  String get shopEarnMoreNc;

  /// All filter tab
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get shopAll;

  /// Trees filter tab
  ///
  /// In en, this message translates to:
  /// **'Trees'**
  String get shopTrees;

  /// Water filter tab
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get shopWater;

  /// Fruits filter tab
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get shopFruits;

  /// Creatures filter tab
  ///
  /// In en, this message translates to:
  /// **'Creatures'**
  String get shopCreatures;

  /// Structures filter tab
  ///
  /// In en, this message translates to:
  /// **'Structures'**
  String get shopStructures;

  /// Sacred filter tab
  ///
  /// In en, this message translates to:
  /// **'Sacred'**
  String get shopSacred;

  /// Underwater filter tab
  ///
  /// In en, this message translates to:
  /// **'Underwater'**
  String get shopUnderwater;

  /// Sky filter tab
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get shopSky;

  /// Hayat section title
  ///
  /// In en, this message translates to:
  /// **'Restore Your Paradise'**
  String get shopHayatTitle;

  /// Single restore product
  ///
  /// In en, this message translates to:
  /// **'Hayat Drop'**
  String get shopHayatDrop;

  /// Full restore product
  ///
  /// In en, this message translates to:
  /// **'Hayat Bloom'**
  String get shopHayatBloom;

  /// NC IAP section title
  ///
  /// In en, this message translates to:
  /// **'Add Noor Coins'**
  String get shopNcTitle;

  /// 1000 NC package
  ///
  /// In en, this message translates to:
  /// **'Starter Noor'**
  String get shopStarterNoor;

  /// 5000 NC package
  ///
  /// In en, this message translates to:
  /// **'A Handful of Noor'**
  String get shopHandfulNoor;

  /// 10000 NC package
  ///
  /// In en, this message translates to:
  /// **'A Garden\'s Worth'**
  String get shopGardensWorth;

  /// 25000 NC package
  ///
  /// In en, this message translates to:
  /// **'The Blessed Harvest'**
  String get shopBlessedHarvest;

  /// Hayat subtitle
  ///
  /// In en, this message translates to:
  /// **'Hayat · Life'**
  String get hayatLife;

  /// Hayat description
  ///
  /// In en, this message translates to:
  /// **'Every garden needs care. Hayat brings yours back to life.'**
  String get hayatTagline;

  /// Single asset restore
  ///
  /// In en, this message translates to:
  /// **'Hayat Drop'**
  String get hayatDropTitle;

  /// Drop effect description
  ///
  /// In en, this message translates to:
  /// **'Restores one chosen asset'**
  String get hayatDropEffect;

  /// Full garden restore
  ///
  /// In en, this message translates to:
  /// **'Hayat Bloom'**
  String get hayatBloomTitle;

  /// Bloom effect description
  ///
  /// In en, this message translates to:
  /// **'Restores your entire garden'**
  String get hayatBloomEffect;

  /// Drop action button
  ///
  /// In en, this message translates to:
  /// **'Restore One Asset'**
  String get hayatRestoreOne;

  /// Bloom action button
  ///
  /// In en, this message translates to:
  /// **'Restore Full Garden'**
  String get hayatRestoreAll;

  /// NC or USD separator
  ///
  /// In en, this message translates to:
  /// **'or'**
  String get hayatOr;

  /// Balance display
  ///
  /// In en, this message translates to:
  /// **'Your balance: {balance} Noor Coins'**
  String hayatYourBalance(int balance);

  /// Asset selection prompt
  ///
  /// In en, this message translates to:
  /// **'Select an asset to restore'**
  String get hayatSelectAsset;

  /// Contextual restore prompt
  ///
  /// In en, this message translates to:
  /// **'Restore this?'**
  String get hayatRestoreThis;

  /// Plant confirmation
  ///
  /// In en, this message translates to:
  /// **'Plant {name} for {price} Noor Coins?'**
  String plantConfirmTitle(String name, int price);

  /// Confirm plant button
  ///
  /// In en, this message translates to:
  /// **'Plant It'**
  String get plantIt;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get notNow;

  /// Insufficient balance message
  ///
  /// In en, this message translates to:
  /// **'Earn more Noor Coins to plant this gift'**
  String get earnMorePrompt;

  /// Sell confirmation
  ///
  /// In en, this message translates to:
  /// **'Sell {name} for {price} NC?'**
  String sellConfirmTitle(String name, int price);

  /// Sell warning body
  ///
  /// In en, this message translates to:
  /// **'This removes it from your garden.'**
  String get sellConfirmBody;

  /// Confirm sell button
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellButton;

  /// Placement prompt
  ///
  /// In en, this message translates to:
  /// **'Tap an empty slot to place your asset'**
  String get tapSlotToPlace;

  /// Move menu option
  ///
  /// In en, this message translates to:
  /// **'Move'**
  String get moveAsset;

  /// Sell menu option
  ///
  /// In en, this message translates to:
  /// **'Sell'**
  String get sellAsset;

  /// Question mark content type badge
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get qmDua;

  /// Question mark content type badge
  ///
  /// In en, this message translates to:
  /// **'Islamic History'**
  String get qmHistory;

  /// Question mark scroll prompt
  ///
  /// In en, this message translates to:
  /// **'Watch to discover your gift'**
  String get qmWatchToDiscover;

  /// Gentle QM expiry toast
  ///
  /// In en, this message translates to:
  /// **'This moment passed. A new one will come.'**
  String get qmMomentPassed;

  /// QM reminder notification title
  ///
  /// In en, this message translates to:
  /// **'Your discovery is still waiting'**
  String get qmDiscoveryWaiting;

  /// QM reminder notification body
  ///
  /// In en, this message translates to:
  /// **'You have time. A sacred gift is waiting for you in your garden.'**
  String get qmDiscoveryBody;

  /// Thank you in Islamic greeting
  ///
  /// In en, this message translates to:
  /// **'JazakAllahu Khairan'**
  String get jazakAllahuKhairan;

  /// Placeholder when video unavailable
  ///
  /// In en, this message translates to:
  /// **'Sacred content coming soon. JazakAllahu Khairan.'**
  String get sacredContentComingSoon;

  /// Return button from placeholder
  ///
  /// In en, this message translates to:
  /// **'Return to Garden'**
  String get returnToGarden;

  /// Outer garden explainer heading
  ///
  /// In en, this message translates to:
  /// **'Your Outer Garden'**
  String get outerGardenTitle;

  /// Outer garden explainer body
  ///
  /// In en, this message translates to:
  /// **'Every person you invite to Amal plants a seed in your outer paradise. Every Amal they do — rain falls in your garden. Every person they invite — their Amal reaches you too. This is Sadaqa Zariyah. Good deeds that never stop.'**
  String get outerGardenExplainerBody;

  /// Outer garden explainer subtext
  ///
  /// In en, this message translates to:
  /// **'Your referral network is infinite. Every deed echoes.'**
  String get outerGardenExplainerSubtext;

  /// Enter outer garden button
  ///
  /// In en, this message translates to:
  /// **'Enter My Garden'**
  String get outerGardenEnterButton;

  /// Referral panel button
  ///
  /// In en, this message translates to:
  /// **'My Network'**
  String get myNetwork;

  /// Copy referral link button
  ///
  /// In en, this message translates to:
  /// **'Copy Link'**
  String get copyLink;

  /// Clipboard copy toast
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get linkCopied;

  /// Share referral link button
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get shareInvite;

  /// Referral share message
  ///
  /// In en, this message translates to:
  /// **'Join me in building paradise. Every good deed echoes. Start your Jannah Garden here:'**
  String get shareInviteMessage;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Direct Invites'**
  String get directInvites;

  /// Stat description
  ///
  /// In en, this message translates to:
  /// **'People who joined through your link directly'**
  String get directInvitesDesc;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Their Invites'**
  String get theirInvites;

  /// Stat description
  ///
  /// In en, this message translates to:
  /// **'People invited by your direct invites'**
  String get theirInvitesDesc;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Total Network'**
  String get totalNetwork;

  /// Stat description
  ///
  /// In en, this message translates to:
  /// **'Your complete network at every depth'**
  String get totalNetworkDesc;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Total Amals'**
  String get totalNetworkAmals;

  /// Stat description
  ///
  /// In en, this message translates to:
  /// **'Amals completed by everyone in your network'**
  String get totalNetworkAmalsDesc;

  /// Stat label
  ///
  /// In en, this message translates to:
  /// **'Rainfall Today'**
  String get rainfallToday;

  /// Stat description
  ///
  /// In en, this message translates to:
  /// **'Rain events from your network\'s activity today'**
  String get rainfallTodayDesc;

  /// Collapsible explainer title
  ///
  /// In en, this message translates to:
  /// **'How does this work?'**
  String get howItWorks;

  /// Referral explainer body
  ///
  /// In en, this message translates to:
  /// **'Every Amal your network completes sends rain to your garden. The deeper the roots you plant — the more your paradise grows.'**
  String get howItWorksBody;

  /// Garden level 1 name
  ///
  /// In en, this message translates to:
  /// **'Al-Rawdah'**
  String get levelAlRawdah;

  /// Garden level 2 name
  ///
  /// In en, this message translates to:
  /// **'Al-Firdaws'**
  String get levelAlFirdaws;

  /// Garden level 3 name
  ///
  /// In en, this message translates to:
  /// **'Al-Na\'im'**
  String get levelAlNaim;

  /// Garden level 4 name
  ///
  /// In en, this message translates to:
  /// **'Jannat al-Ma\'wa'**
  String get levelJannatAlMawa;

  /// Level-up toast
  ///
  /// In en, this message translates to:
  /// **'Welcome to {levelName}'**
  String welcomeToLevel(String levelName);

  /// Quran 2:25 translation
  ///
  /// In en, this message translates to:
  /// **'And give good tidings to those who believe'**
  String get verseLevel2En;

  /// Quran 15:45 translation
  ///
  /// In en, this message translates to:
  /// **'Indeed, the righteous will be among gardens'**
  String get verseLevel3En;

  /// Quran 47:15 translation
  ///
  /// In en, this message translates to:
  /// **'In it are rivers of water unaltered'**
  String get verseLevel4En;

  /// Camera mode label
  ///
  /// In en, this message translates to:
  /// **'Architect View'**
  String get architectViewLabel;

  /// Camera mode label
  ///
  /// In en, this message translates to:
  /// **'Immersed'**
  String get immersionViewLabel;

  /// Empty garden CTA
  ///
  /// In en, this message translates to:
  /// **'Plant Something'**
  String get plantSomething;

  /// Access prompt heading
  ///
  /// In en, this message translates to:
  /// **'Your Garden Awaits'**
  String get accessPromptTitle;

  /// Access prompt body
  ///
  /// In en, this message translates to:
  /// **'Complete a Soul Stack or watch a video to unlock your garden for 6 hours.'**
  String get accessPromptBody;

  /// Access prompt subscribe
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get accessSubscribeButton;

  /// Access prompt soul stack
  ///
  /// In en, this message translates to:
  /// **'Complete Soul Stack'**
  String get accessSoulStackButton;

  /// Access prompt YWTL
  ///
  /// In en, this message translates to:
  /// **'Watch a Video'**
  String get accessYwtlButton;

  /// Featured asset section label
  ///
  /// In en, this message translates to:
  /// **'Featured This Week'**
  String get shopFeaturedLabel;

  /// Shop filter tab
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get shopFilterAll;

  /// Shop filter tab
  ///
  /// In en, this message translates to:
  /// **'Trees'**
  String get shopFilterTrees;

  /// Shop filter tab
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get shopFilterWater;

  /// Shop filter tab
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get shopFilterFruits;

  /// Shop filter tab
  ///
  /// In en, this message translates to:
  /// **'Creatures'**
  String get shopFilterCreatures;

  /// Shop filter tab
  ///
  /// In en, this message translates to:
  /// **'Structures'**
  String get shopFilterStructures;

  /// Shop filter tab
  ///
  /// In en, this message translates to:
  /// **'Sacred'**
  String get shopFilterSacred;

  /// Shop filter tab
  ///
  /// In en, this message translates to:
  /// **'Underwater'**
  String get shopFilterUnderwater;

  /// Shop filter tab
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get shopFilterSky;

  /// Hayat section tagline in shop
  ///
  /// In en, this message translates to:
  /// **'Every garden needs care. Hayat brings yours back to life.'**
  String get shopHayatTagline;

  /// Bloom action button
  ///
  /// In en, this message translates to:
  /// **'Restore Full Garden'**
  String get hayatRestoreFull;

  /// Planting confirmation heading
  ///
  /// In en, this message translates to:
  /// **'Plant in Your Paradise?'**
  String get plantingConfirmTitle;

  /// Planting confirm button
  ///
  /// In en, this message translates to:
  /// **'Plant It'**
  String get plantingConfirmButton;

  /// Planting cancel
  ///
  /// In en, this message translates to:
  /// **'Not Now'**
  String get plantingNotNow;

  /// Sell confirmation
  ///
  /// In en, this message translates to:
  /// **'Sell {name} for {nc} Noor Coins?'**
  String assetSellConfirm(String name, int nc);

  /// Sell removal warning
  ///
  /// In en, this message translates to:
  /// **'This removes it from your garden.'**
  String get assetSellRemovalWarning;

  /// Sell confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm Sale'**
  String get assetSellButton;

  /// QM content type
  ///
  /// In en, this message translates to:
  /// **'Dua'**
  String get questionMarkDua;

  /// QM content type
  ///
  /// In en, this message translates to:
  /// **'Islamic History'**
  String get questionMarkHistory;

  /// QM scroll prompt
  ///
  /// In en, this message translates to:
  /// **'Watch to discover your gift'**
  String get questionMarkWatchToDiscover;

  /// QM expiry toast
  ///
  /// In en, this message translates to:
  /// **'This moment passed. A new one will come.'**
  String get questionMarkExpired;

  /// QM pending reminder
  ///
  /// In en, this message translates to:
  /// **'Your discovery is still waiting. You have time.'**
  String get questionMarkPending;

  /// Post-discovery thank you
  ///
  /// In en, this message translates to:
  /// **'JazakAllahu Khairan'**
  String get discoveryJazakAllah;

  /// Outer garden Arabic subtitle
  ///
  /// In en, this message translates to:
  /// **'Sadaqa Zariyah'**
  String get outerGardenSubtitle;

  /// Outer garden explainer skip
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get outerGardenSkip;

  /// Referral link copy toast
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get referralCopied;

  /// Referral share prefix
  ///
  /// In en, this message translates to:
  /// **'Join me on Amal'**
  String get referralShareText;

  /// Referral stat
  ///
  /// In en, this message translates to:
  /// **'Direct Invites'**
  String get networkDirectInvites;

  /// Referral stat
  ///
  /// In en, this message translates to:
  /// **'Their Invites'**
  String get networkTheirInvites;

  /// Referral stat
  ///
  /// In en, this message translates to:
  /// **'Total Network'**
  String get networkTotal;

  /// Referral stat
  ///
  /// In en, this message translates to:
  /// **'Total Amals'**
  String get networkAmals;

  /// Referral stat
  ///
  /// In en, this message translates to:
  /// **'Rainfall Today'**
  String get networkRainfallToday;

  /// Floating button label
  ///
  /// In en, this message translates to:
  /// **'My Network'**
  String get myNetworkButton;

  /// Level-up toast
  ///
  /// In en, this message translates to:
  /// **'Welcome to {name}'**
  String levelUpWelcome(String name);

  /// Gate animation skip button
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get gateSkip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'bn', 'en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bn':
      return AppLocalizationsBn();
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
