import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/email_auth_screen.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/screens/calculation_method_screen.dart';
import '../../features/onboarding/screens/language_screen.dart';
import '../../features/onboarding/screens/notification_screen.dart';
import '../../features/onboarding/screens/prayer_tradition_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/onboarding/screens/sign_up_screen.dart';
import '../../features/onboarding/screens/welcome_complete_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/prayer/prayer_screen.dart';
import '../../features/qibla/qibla_screen.dart';
import '../../features/amal_gallery/amal_detail_screen.dart';
import '../../features/amal_gallery/amal_gallery_screen.dart';
import '../../features/amal_tracker/amal_tracker_screen.dart';
import '../../features/ramadan/ramadan_screen.dart';
import '../../features/jannah_garden/jannah_garden_screen.dart';
import '../../features/jannah_garden/shop/jannah_shop_screen.dart';
import '../../features/soul_stack/soul_stack_flow_screen.dart';
import '../../features/soul_stack/soul_stack_screen.dart';
import '../services/soul_stack_service.dart';
import '../../features/noor_wallet/noor_wallet_screen.dart';
import '../../features/ywtl/ywtl_screen.dart';
import '../../features/tasbeeh/tasbeeh_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../models/amal_model.dart';
import '../utils/app_preferences.dart';

// ── Route paths ────────────────────────────────────────────────────────────
abstract final class AppRoutes {
  static const String welcome                   = '/welcome';
  static const String signIn                    = '/sign-in';
  static const String authEmail                 = '/auth/email';
  static const String authForgotPassword        = '/auth/forgot-password';
  static const String onboardingLanguage        = '/onboarding/language';
  static const String onboardingPrayerTradition = '/onboarding/prayer-tradition';
  static const String onboardingCalculationMethod = '/onboarding/calculation-method';
  static const String onboardingProfile         = '/onboarding/profile';
  static const String onboardingNotifications   = '/onboarding/notifications';
  static const String onboardingComplete        = '/onboarding/complete';
  static const String home                      = '/home';
  static const String prayer                    = '/prayer';
  static const String qibla                     = '/qibla';
  static const String tasbeeh                   = '/tasbeeh';
  static const String ramadan                   = '/ramadan';
  static const String amalTracker               = '/amal-tracker';
  static const String amalGallery               = '/amal-gallery';
  static const String amalGalleryDetail         = '/amal-gallery/detail';
  static const String soulStack                 = '/soul-stack';
  static const String soulStackFlow             = '/soul-stack/flow';
  static const String ywtl                      = '/ywtl';
  static const String jannahGarden              = '/jannah-garden';
  static const String jannahShop                = '/jannah-garden/shop';
  static const String jannahHayat               = '/jannah-garden/hayat';
  static const String jannahOuter              = '/jannah-garden/outer';
  static const String noorWallet                = '/noor-wallet';
  static const String profile                   = '/profile';
  static const String settings                  = '/settings';
}

// ── Auth-state refresh notifier ────────────────────────────────────────────
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier() {
    _sub = FirebaseAuth.instance.authStateChanges().listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authNotifier = _AuthNotifier();

// ── Router ─────────────────────────────────────────────────────────────────
final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.welcome,
  refreshListenable: _authNotifier,
  debugLogDiagnostics: false,

  redirect: (context, state) {
    final isLoggedIn = FirebaseAuth.instance.currentUser != null;
    final onboardingDone = AppPreferences.instance.onboardingComplete;
    final loc = state.matchedLocation;

    final isAuthRoute = loc == AppRoutes.welcome ||
        loc == AppRoutes.signIn ||
        loc.startsWith('/auth');

    final isOnboardingRoute = loc.startsWith('/onboarding');

    // Not logged in → force to welcome/sign-in
    if (!isLoggedIn) {
      return isAuthRoute ? null : AppRoutes.welcome;
    }

    // Logged in but onboarding not done → onboarding flow
    if (!onboardingDone) {
      return (isOnboardingRoute || isAuthRoute)
          ? null
          : AppRoutes.onboardingLanguage;
    }

    // Logged in + onboarding done → not allowed back into auth/onboarding
    if (isAuthRoute || isOnboardingRoute) return AppRoutes.home;

    return null;
  },

  routes: [
    // ── Pre-auth ──────────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.welcome,
      builder: (context, _) => const WelcomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.signIn,
      builder: (context, _) => const SignUpScreen(),
    ),
    GoRoute(
      path: AppRoutes.authEmail,
      builder: (context, _) => const EmailAuthScreen(),
    ),
    GoRoute(
      path: AppRoutes.authForgotPassword,
      builder: (context, _) => const ForgotPasswordScreen(),
    ),

    // ── Onboarding (post-auth) ─────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.onboardingLanguage,
      builder: (context, _) => const LanguageScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingPrayerTradition,
      builder: (context, _) => const PrayerTraditionScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingCalculationMethod,
      builder: (context, _) => const CalculationMethodScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingProfile,
      builder: (context, _) => const ProfileSetupScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingNotifications,
      builder: (context, _) => const NotificationScreen(),
    ),
    GoRoute(
      path: AppRoutes.onboardingComplete,
      builder: (context, _) => const WelcomeCompleteScreen(),
    ),

    // ── App (protected) ────────────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.home,
      builder: (context, _) => const HomeScreen(),
    ),
    GoRoute(
      path: AppRoutes.prayer,
      builder: (context, _) => const PrayerScreen(),
    ),
    GoRoute(
      path: AppRoutes.qibla,
      builder: (context, _) => const QiblaScreen(),
    ),
    GoRoute(
      path: AppRoutes.tasbeeh,
      builder: (context, _) => const TasbeehScreen(),
    ),
    GoRoute(
      path: AppRoutes.ramadan,
      builder: (context, _) => const RamadanScreen(),
    ),
    GoRoute(
      path: AppRoutes.amalTracker,
      builder: (context, _) => const AmalTrackerScreen(),
    ),
    GoRoute(
      path: AppRoutes.amalGallery,
      builder: (context, _) => const AmalGalleryScreen(),
    ),
    GoRoute(
      path: AppRoutes.amalGalleryDetail,
      builder: (context, state) => AmalDetailScreen(
        amal: state.extra! as AmalModel,
      ),
    ),
    GoRoute(
      path: AppRoutes.soulStack,
      builder: (context, _) => const SoulStackScreen(),
    ),
    GoRoute(
      path: AppRoutes.soulStackFlow,
      builder: (context, state) => SoulStackFlowScreen(
        stackName: state.extra! as StackName,
      ),
    ),
    GoRoute(
      path: AppRoutes.ywtl,
      builder: (context, _) => const YwtlScreen(),
    ),
    GoRoute(
      path: AppRoutes.jannahGarden,
      builder: (context, _) => const JannahGardenScreen(),
    ),
    GoRoute(
      path: AppRoutes.jannahShop,
      builder: (context, _) => const JannahShopScreen(),
    ),
    GoRoute(
      path: AppRoutes.jannahHayat,
      builder: (context, _) => const JannahGardenScreen(showHayatOnLoad: true),
    ),
    GoRoute(
      path: AppRoutes.jannahOuter,
      builder: (context, _) => const JannahGardenScreen(showOuterOnLoad: true),
    ),
    GoRoute(
      path: AppRoutes.noorWallet,
      builder: (context, _) => const NoorWalletScreen(),
    ),
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, _) => const ProfileScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, _) => const SettingsScreen(),
    ),
  ],

  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.uri}')),
  ),
);
