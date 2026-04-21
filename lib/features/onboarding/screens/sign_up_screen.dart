import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io' show Platform;
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../shared/widgets/amal_button.dart';
import '../../../shared/widgets/amal_logo.dart';

class SignUpScreen extends ConsumerWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final signInState = ref.watch(signInProvider);
    final isLoading = signInState is AsyncLoading;

    // Navigate forward after successful sign-in
    ref.listen(signInProvider, (_, next) {
      if (next is AsyncData) {
        context.go(AppRoutes.onboardingLanguage);
      }
    });

    final biometricAvailable = ref.watch(biometricAvailableProvider).valueOrNull ?? false;
    final biometricEnabled = AppPreferences.instance.biometricEnabled;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: cs.onSurface),
          onPressed: () => context.go(AppRoutes.welcome),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xl),
              const AmalLogo(size: 64),
              const SizedBox(height: AppSpacing.lg),

              Text(
                l10n.signInTitle,
                style: AppTypography.headlineMedium.copyWith(
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.signInSubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Biometric (returning users only) ────────────────────────
              if (biometricAvailable && biometricEnabled) ...[
                AmalPrimaryButton(
                  label: l10n.biometricSignIn,
                  isLoading: isLoading,
                  icon: const Icon(Icons.fingerprint_rounded),
                  onPressed: () async {
                    final ok = await ref
                        .read(signInProvider.notifier)
                        .signInWithBiometric(l10n.biometricPrompt);
                    if (ok && context.mounted) {
                      context.go(AppRoutes.home);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                _Divider(label: l10n.or),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Google ──────────────────────────────────────────────────
              AmalOutlinedButton(
                label: l10n.continueWithGoogle,
                isLoading: isLoading,
                icon: _GoogleIcon(),
                onPressed: () => ref.read(signInProvider.notifier).signInWithGoogle(),
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Apple (iOS only) ────────────────────────────────────────
              if (Platform.isIOS) ...[
                AmalOutlinedButton(
                  label: l10n.continueWithApple,
                  isLoading: isLoading,
                  icon: const Icon(Icons.apple_rounded),
                  onPressed: () => ref.read(signInProvider.notifier).signInWithApple(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // ── Email ───────────────────────────────────────────────────
              AmalOutlinedButton(
                label: l10n.emailAndPassword,
                isLoading: isLoading,
                icon: const Icon(Icons.email_outlined),
                onPressed: () => context.go(AppRoutes.authEmail),
              ),

              // ── Error message ───────────────────────────────────────────
              if (signInState is AsyncError) ...[
                const SizedBox(height: AppSpacing.md),
                _ErrorBanner(
                  message: _friendlyError(signInState.error, l10n),
                ),
              ],

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  String _friendlyError(Object error, AppLocalizations l10n) {
    final msg = error.toString();
    if (msg.contains('network')) return l10n.errorNetworkRequest;
    if (msg.contains('cancelled') || msg.contains('canceled')) return '';
    return l10n.errorSignInFailed;
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(child: Divider(color: cs.outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            label,
            style: AppTypography.bodySmall.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        Expanded(child: Divider(color: cs.outline)),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.onErrorContainer, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(color: cs.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Text(
      'G',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryGreen,
      ),
    );
  }
}
