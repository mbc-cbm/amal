import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../shared/widgets/amal_button.dart';
import '../providers/onboarding_provider.dart';

class WelcomeCompleteScreen extends ConsumerStatefulWidget {
  const WelcomeCompleteScreen({super.key});

  @override
  ConsumerState<WelcomeCompleteScreen> createState() =>
      _WelcomeCompleteScreenState();
}

class _WelcomeCompleteScreenState
    extends ConsumerState<WelcomeCompleteScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _layer1;
  late final Animation<double> _layer2;
  late final Animation<double> _layer3;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _layer1 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _layer2 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    _layer3 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.65, 1.0, curve: Curves.easeOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _enterAmal() async {
    setState(() => _isLoading = true);

    final onboarding = ref.read(onboardingProvider);
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    // 1. Try to create user document in Firestore (best-effort).
    //    If Firestore is unavailable (API propagation), skip and proceed.
    //    The document will be created on next successful connection.
    if (uid != null) {
      try {
        final userRef =
            FirebaseFirestore.instance.collection('users').doc(uid);
        final existing =
            await userRef.get().timeout(const Duration(seconds: 5));
        if (!existing.exists) {
          final referralCode = uid.substring(0, 4).toUpperCase() +
              DateTime.now()
                  .millisecondsSinceEpoch
                  .toRadixString(36)
                  .substring(0, 4)
                  .toUpperCase();

          await userRef.set({
            'uid': uid,
            'displayName': onboarding.name.isNotEmpty
                ? onboarding.name
                : user?.displayName ?? '',
            'email': user?.email ?? '',
            'photoUrl': onboarding.photoUrl ?? user?.photoURL ?? '',
            'language': onboarding.language,
            'prayerTradition': onboarding.prayerTradition ?? 'sunni',
            'calculationMethod':
                onboarding.calculationMethodId?.toString() ?? '2',
            'notificationsEnabled': onboarding.notificationsEnabled,
            'biometricEnabled': onboarding.biometricEnabled,
            'preferredLocale': onboarding.language,
            'subscriptionStatus': 'free',
            'currentDailyStreak': 0,
            'longestDailyStreak': 0,
            'currentWeeklyStreak': 0,
            'longestWeeklyStreak': 0,
            'totalAmalsCompleted': 0,
            'totalNoorCoinsFromAmals': 0,
            'referralCode': referralCode,
            'rainforestIntensity': 0,
            'isDeleted': false,
            'createdAt': FieldValue.serverTimestamp(),
            'lastActiveAt': FieldValue.serverTimestamp(),
          }).timeout(const Duration(seconds: 5));
        }
      } catch (e) {
        debugPrint('Firestore user doc creation skipped: $e');
      }

      // 2. Try Cloud Function backfill (best-effort).
      try {
        await FirebaseFunctions.instance
            .httpsCallable('createUserDocument')
            .call(<String, dynamic>{'uid': uid, 'name': onboarding.name})
            .timeout(const Duration(seconds: 5));
      } catch (e) {
        debugPrint('Cloud Function backfill skipped: $e');
      }
    }

    // 3. Mark onboarding complete locally — this ALWAYS runs.
    await AppPreferences.instance.setOnboardingComplete(true);
    await AppPreferences.instance.setLocale(onboarding.language);

    // 4. Navigate to home — this ALWAYS runs.
    if (mounted) context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final name = ref.watch(onboardingProvider).name;
    final displayName = name.isNotEmpty
        ? name
        : FirebaseAuth.instance.currentUser?.displayName ?? '';

    return Scaffold(
      backgroundColor: AppColors.primaryGreen,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Layer 1: Personalised welcome ───────────────────────────────
              FadeTransition(
                opacity: _layer1,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_layer1),
                  child: Text(
                    l10n.welcomeToAmalTitle(displayName),
                    style: AppTypography.headlineLarge.copyWith(
                      color: AppColors.creamWhite,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Layer 2: Impact message ─────────────────────────────────────
              FadeTransition(
                opacity: _layer2,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.2),
                    end: Offset.zero,
                  ).animate(_layer2),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusXl),
                    ),
                    child: Text(
                      l10n.impactMessage,
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.creamWhite,
                        height: 1.7,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Tagline ─────────────────────────────────────────────────────
              FadeTransition(
                opacity: _layer2,
                child: Text(
                  l10n.welcomeTagline,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.primaryGold,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(flex: 2),

              // ── Layer 3: CTA ────────────────────────────────────────────────
              FadeTransition(
                opacity: _layer3,
                child: SlideTransition(
                  position: Tween(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(_layer3),
                  child: AmalGoldButton(
                    label: l10n.enterAmal,
                    isLoading: _isLoading,
                    onPressed: _enterAmal,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
