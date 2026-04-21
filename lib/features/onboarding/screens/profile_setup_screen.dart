import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/amal_button.dart';
import '../../../shared/widgets/amal_text_field.dart';
import '../providers/onboarding_provider.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    // Pre-populate from social auth display name if available
    final displayName = ref
            .read(authStateProvider)
            .valueOrNull
            ?.displayName ??
        '';
    _nameCtrl = TextEditingController(text: displayName);
    if (displayName.isNotEmpty) {
      ref.read(onboardingProvider.notifier).setName(displayName);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _proceed() {
    ref.read(onboardingProvider.notifier).setName(_nameCtrl.text.trim());
    context.go(AppRoutes.onboardingNotifications);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final photoUrl = ref.watch(onboardingProvider).photoUrl;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              Text(
                l10n.profileSetupTitle,
                style: AppTypography.headlineMedium
                    .copyWith(color: cs.onSurface),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.profileSetupSubtitle,
                style: AppTypography.bodyMedium
                    .copyWith(color: cs.onSurfaceVariant, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),

              // ── Avatar ────────────────────────────────────────────────────
              GestureDetector(
                onTap: () {
                  // TODO Day 3: open image picker via image_picker package
                },
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 52,
                      backgroundColor: cs.surfaceContainerHighest,
                      backgroundImage:
                          photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 52,
                              color: cs.onSurfaceVariant,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: cs.surface, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                photoUrl == null ? l10n.addPhoto : l10n.changePhoto,
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.primaryGreen),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Name field ─────────────────────────────────────────────────
              AmalTextField(
                label: l10n.nameLabel,
                controller: _nameCtrl,
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.name],
                prefixIcon: const Icon(Icons.person_outline_rounded),
                onChanged: (v) =>
                    ref.read(onboardingProvider.notifier).setName(v),
              ),
              const SizedBox(height: AppSpacing.xxl),

              AmalPrimaryButton(
                label: l10n.saveAndContinue,
                onPressed: _proceed,
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Skip ────────────────────────────────────────────────────────
              AmalTextButton(
                label: l10n.skip,
                onPressed: () => context.go(AppRoutes.onboardingNotifications),
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
