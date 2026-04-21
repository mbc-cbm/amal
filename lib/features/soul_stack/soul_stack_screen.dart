import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/soul_stack_provider.dart';
import '../../core/services/soul_stack_service.dart';

class SoulStackScreen extends ConsumerWidget {
  const SoulStackScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final dayStatus = ref.watch(soulStackDayStatusProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.soulStack),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: dayStatus.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorGeneric, style: AppTypography.bodyMedium),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: () => ref.invalidate(soulStackDayStatusProvider),
                child: Text(l10n.retry),
              ),
            ],
          ),
        ),
        data: (status) => ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          children: [
            _StackCard(
              stackName: StackName.rise,
              icon: Icons.wb_sunny_rounded,
              subtitle: l10n.soulStackRise,
              log: status.rise,
            ),
            const SizedBox(height: AppSpacing.md),
            _StackCard(
              stackName: StackName.shine,
              icon: Icons.wb_twilight_rounded,
              subtitle: l10n.soulStackShine,
              log: status.shine,
            ),
            const SizedBox(height: AppSpacing.md),
            _StackCard(
              stackName: StackName.glow,
              icon: Icons.nightlight_round,
              subtitle: l10n.soulStackGlow,
              log: status.glow,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stack card ──────────────────────────────────────────────────────────────

class _StackCard extends StatelessWidget {
  const _StackCard({
    required this.stackName,
    required this.icon,
    required this.subtitle,
    required this.log,
  });

  final StackName stackName;
  final IconData icon;
  final String subtitle;
  final StackDayLog log;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedToday = log.completed;

    return GestureDetector(
      onTap: () => context.push('/soul-stack/flow', extra: stackName),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: completedToday
              ? Border.all(color: AppColors.noorGold, width: 2.5)
              : Border.all(color: cs.outline.withValues(alpha: 0.15)),
          boxShadow: completedToday
              ? [
                  BoxShadow(
                    color: AppColors.noorGold.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon + name row ────────────────────────────────────────────
            Row(
              children: [
                Container(
                  width: AppSpacing.iconXl,
                  height: AppSpacing.iconXl,
                  decoration: BoxDecoration(
                    color: completedToday
                        ? AppColors.noorGold.withValues(alpha: 0.2)
                        : AppColors.primaryGreen.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: AppSpacing.iconLg,
                    color: completedToday
                        ? AppColors.noorGold
                        : AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stackName.name[0].toUpperCase() +
                            stackName.name.substring(1),
                        style: AppTypography.headlineSmall.copyWith(
                          color: cs.onSurface,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        subtitle,
                        style: AppTypography.bodyMedium.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (completedToday)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.noorGold,
                    size: AppSpacing.iconLg,
                  ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Progress ───────────────────────────────────────────────────
            Text(
              l10n.soulStackProgress(0),
              style: AppTypography.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),

            if (log.count > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.soulStackCompletedTimes(log.count),
                style: AppTypography.labelMedium.copyWith(
                  color: completedToday
                      ? AppColors.noorGold
                      : AppColors.primaryGreen,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // ── Start button ───────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () =>
                    context.push('/soul-stack/flow', extra: stackName),
                style: FilledButton.styleFrom(
                  backgroundColor: completedToday
                      ? AppColors.noorGold
                      : AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + AppSpacing.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(
                  l10n.soulStackStartStack,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
