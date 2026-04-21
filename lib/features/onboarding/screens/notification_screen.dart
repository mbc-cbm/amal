import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/notification_service.dart';
import '../../../shared/widgets/amal_button.dart';
import '../providers/onboarding_provider.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  Future<void> _allow(BuildContext context, WidgetRef ref) async {
    final svc = NotificationService();
    await svc.initialize();
    ref.read(onboardingProvider.notifier).setNotificationsEnabled(true);
    if (context.mounted) context.go(AppRoutes.onboardingComplete);
  }

  void _skip(BuildContext context, WidgetRef ref) {
    ref.read(onboardingProvider.notifier).setNotificationsEnabled(false);
    context.go(AppRoutes.onboardingComplete);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Bell icon ──────────────────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primaryGold,
                  size: 52,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                l10n.notificationTitle,
                style: AppTypography.headlineMedium
                    .copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.notificationDescription,
                style: AppTypography.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              AmalPrimaryButton(
                label: l10n.allowNotifications,
                onPressed: () => _allow(context, ref),
              ),
              const SizedBox(height: AppSpacing.md),
              AmalTextButton(
                label: l10n.maybeLater,
                onPressed: () => _skip(context, ref),
                subtle: true,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
