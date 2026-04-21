import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/amal_button.dart';
import '../providers/onboarding_provider.dart';

class PrayerTraditionScreen extends ConsumerStatefulWidget {
  const PrayerTraditionScreen({super.key});

  @override
  ConsumerState<PrayerTraditionScreen> createState() =>
      _PrayerTraditionScreenState();
}

class _PrayerTraditionScreenState
    extends ConsumerState<PrayerTraditionScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              Text(
                l10n.prayerTraditionTitle,
                style: AppTypography.headlineMedium.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.prayerTraditionSubtitle,
                style: AppTypography.bodyMedium.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.5,
                ),
              ),

              const Spacer(),

              // ── Equally prominent tradition cards ──────────────────────
              Row(
                children: [
                  Expanded(
                    child: _TraditionCard(
                      label: l10n.sunni,
                      emoji: '☽',
                      code: 'sunni',
                      isSelected: _selected == 'sunni',
                      onTap: () => setState(() => _selected = 'sunni'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _TraditionCard(
                      label: l10n.shia,
                      emoji: '☽',
                      code: 'shia',
                      isSelected: _selected == 'shia',
                      onTap: () => setState(() => _selected = 'shia'),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              AmalPrimaryButton(
                label: l10n.continueButton,
                onPressed: _selected == null
                    ? null
                    : () {
                        ref
                            .read(onboardingProvider.notifier)
                            .setPrayerTradition(_selected!);
                        context.go(AppRoutes.onboardingCalculationMethod);
                      },
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _TraditionCard extends StatelessWidget {
  const _TraditionCard({
    required this.label,
    required this.emoji,
    required this.code,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final String code;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 180,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen.withAlpha(20)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : AppColors.transparent,
            width: 2.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.md),
            Text(
              label,
              style: AppTypography.titleLarge.copyWith(
                color: isSelected ? AppColors.primaryGreen : cs.onSurface,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.sm),
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryGreen,
                size: 22,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
