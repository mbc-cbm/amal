import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/amal_logo.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => context.go(AppRoutes.signIn),
      child: Scaffold(
        backgroundColor: AppColors.primaryGreen,
        body: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    // ── Logo ───────────────────────────────────────────────
                    const AmalLogo(size: 100),
                    const SizedBox(height: AppSpacing.lg),

                    // ── App name ───────────────────────────────────────────
                    Text(
                      l10n.appName,
                      style: AppTypography.displaySmall.copyWith(
                        color: AppColors.creamWhite,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),

                    // ── Tagline ────────────────────────────────────────────
                    Text(
                      l10n.welcomeTagline,
                      textAlign: TextAlign.center,
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.primaryGold,
                        letterSpacing: 0.5,
                        height: 1.6,
                      ),
                    ),

                    const Spacer(flex: 4),

                    // ── Hint ───────────────────────────────────────────────
                    Text(
                      l10n.tapAnywhereToContinue,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.creamWhite.withAlpha(153),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
