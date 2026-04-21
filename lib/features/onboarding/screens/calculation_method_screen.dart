import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/constants/calculation_methods.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/amal_button.dart';
import '../providers/onboarding_provider.dart';

class CalculationMethodScreen extends ConsumerStatefulWidget {
  const CalculationMethodScreen({super.key});

  @override
  ConsumerState<CalculationMethodScreen> createState() =>
      _CalculationMethodScreenState();
}

class _CalculationMethodScreenState
    extends ConsumerState<CalculationMethodScreen> {
  int? _selectedId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final tradition =
        ref.watch(onboardingProvider).prayerTradition ?? 'sunni';
    final methods = methodsForTradition(tradition);

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
                l10n.calculationMethodTitle,
                style: AppTypography.headlineMedium
                    .copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.calculationMethodSubtitle,
                style: AppTypography.bodyMedium
                    .copyWith(color: cs.onSurfaceVariant, height: 1.5),
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Method list ──────────────────────────────────────────────
              Expanded(
                child: ListView.separated(
                  itemCount: methods.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) {
                    final m = methods[i];
                    final isSelected = _selectedId == m.id;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedId = m.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withAlpha(20)
                              : cs.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    m.name,
                                    style: AppTypography.titleSmall.copyWith(
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : cs.onSurface,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    m.region,
                                    style: AppTypography.bodySmall.copyWith(
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryGreen,
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              AmalPrimaryButton(
                label: l10n.continueButton,
                onPressed: _selectedId == null
                    ? null
                    : () {
                        ref
                            .read(onboardingProvider.notifier)
                            .setCalculationMethod(_selectedId!);
                        context.go(AppRoutes.onboardingProfile);
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
