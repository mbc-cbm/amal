import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/amal_model.dart';
import '../../core/providers/amal_tracker_provider.dart';
import '../../core/router/app_router.dart';

// ── Tracker Dashboard ──────────────────────────────────────────────────────

class TrackerDashboard extends ConsumerWidget {
  const TrackerDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          l10n.trackerMyTracker,
          style: AppTypography.titleLarge.copyWith(color: cs.onSurface),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. Amal of the Day ──────────────────────────────────────
            _AmalOfTheDayCard(ref: ref, l10n: l10n, cs: cs),

            const SizedBox(height: AppSpacing.lg),

            // ── 2. Daily Goal ───────────────────────────────────────────
            _DailyGoalSection(ref: ref, l10n: l10n, cs: cs),

            const SizedBox(height: AppSpacing.lg),

            // ── 3. Stats Grid ───────────────────────────────────────────
            _StatsGrid(ref: ref, l10n: l10n, cs: cs),

            const SizedBox(height: AppSpacing.lg),

            // ── 4. Recent Activity ──────────────────────────────────────
            _RecentActivitySection(ref: ref, l10n: l10n, cs: cs),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ── Amal of the Day Card ───────────────────────────────────────────────────

class _AmalOfTheDayCard extends StatelessWidget {
  const _AmalOfTheDayCard({
    required this.ref,
    required this.l10n,
    required this.cs,
  });

  final WidgetRef ref;
  final AppLocalizations l10n;
  final ColorScheme cs;

  String _categoryLabel(AmalCategory category, AppLocalizations l10n) {
    return switch (category) {
      AmalCategory.prayer => l10n.amalCategoryPrayer,
      AmalCategory.family => l10n.amalCategoryFamily,
      AmalCategory.community => l10n.amalCategoryCommunity,
      AmalCategory.self => l10n.amalCategorySelf,
      AmalCategory.knowledge => l10n.amalCategoryKnowledge,
      AmalCategory.charity => l10n.amalCategoryCharity,
    };
  }

  @override
  Widget build(BuildContext context) {
    final amalAsync = ref.watch(amalOfTheDayProvider);
    final locale = Localizations.localeOf(context).languageCode;

    return amalAsync.when(
      loading: () => Container(
        height: 120,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.primaryGold, width: 2),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGold),
        ),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (amal) => GestureDetector(
        onTap: () => context.push(AppRoutes.amalGalleryDetail, extra: amal),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.primaryGold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withValues(alpha: 0.25),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.trackerTodaysAmal,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                amal.localizedTitle(locale),
                style: AppTypography.titleMedium.copyWith(
                  color: cs.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  // Category chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      _categoryLabel(amal.category, l10n),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Noor Coins
                  const Icon(
                    Icons.stars_rounded,
                    color: AppColors.noorGold,
                    size: AppSpacing.iconSm,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    l10n.amalNoorCoinsReward(amal.noorCoins),
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.noorGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Daily Goal Section ─────────────────────────────────────────────────────

class _DailyGoalSection extends StatefulWidget {
  const _DailyGoalSection({
    required this.ref,
    required this.l10n,
    required this.cs,
  });

  final WidgetRef ref;
  final AppLocalizations l10n;
  final ColorScheme cs;

  @override
  State<_DailyGoalSection> createState() => _DailyGoalSectionState();
}

class _DailyGoalSectionState extends State<_DailyGoalSection> {
  final TextEditingController _goalCtrl = TextEditingController();

  @override
  void dispose() {
    _goalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goalAsync = widget.ref.watch(dailyGoalProvider);
    final completedAsync = widget.ref.watch(todayCompletionCountProvider);

    final goal = goalAsync.valueOrNull;
    final completed = completedAsync.valueOrNull ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.l10n.trackerDailyGoal,
          style: AppTypography.titleMedium.copyWith(
            color: widget.cs.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (goal != null && goal > 0) ...[
          // Show progress bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: widget.cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.l10n.trackerGoalProgress(completed, goal),
                  style: AppTypography.bodyMedium.copyWith(
                    color: widget.cs.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                  child: LinearProgressIndicator(
                    value: (completed / goal).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor:
                        widget.cs.onSurfaceVariant.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completed >= goal
                          ? AppColors.success
                          : AppColors.primaryGreen,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  widget.l10n.trackerEncouragement,
                  style: AppTypography.bodySmall.copyWith(
                    color: widget.cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          // Set a daily goal prompt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: widget.cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.l10n.trackerSetGoal,
                    style: AppTypography.bodyMedium.copyWith(
                      color: widget.cs.onSurfaceVariant,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                SizedBox(
                  width: 64,
                  child: TextField(
                    controller: _goalCtrl,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: widget.cs.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: '5',
                      hintStyle: AppTypography.bodyMedium.copyWith(
                        color: widget.cs.onSurfaceVariant,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      filled: true,
                      fillColor: widget.cs.surface,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusSm),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      final parsed = int.tryParse(value);
                      if (parsed != null && parsed > 0) {
                        widget.ref
                            .read(amalTrackerServiceProvider)
                            .setDailyGoal(parsed);
                        widget.ref.invalidate(dailyGoalProvider);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ── Stats Grid ─────────────────────────────────────────────────────────────

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.ref,
    required this.l10n,
    required this.cs,
  });

  final WidgetRef ref;
  final AppLocalizations l10n;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(trackerStatsProvider);

    return statsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
      ),
      error: (_, _) => Center(
        child: Text(
          l10n.errorGeneric,
          style: AppTypography.bodyMedium.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
      ),
      data: (stats) => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1.45,
        children: [
          _StatCard(
            icon: Icons.check_circle_rounded,
            label: l10n.trackerTotalAmals,
            value: '${stats.totalAmalsCompleted}',
            cs: cs,
          ),
          _StatCard(
            icon: Icons.stars_rounded,
            label: l10n.trackerTotalCoins,
            value: '${stats.totalNoorCoinsFromAmals}',
            cs: cs,
            valueColor: AppColors.noorGold,
          ),
          _StatCard(
            icon: Icons.local_fire_department_rounded,
            label: l10n.trackerDailyStreak,
            value: '${stats.currentDailyStreak}',
            cs: cs,
            iconColor: AppColors.warning,
          ),
          _StatCard(
            icon: Icons.emoji_events_rounded,
            label: l10n.trackerLongestDaily,
            value: '${stats.longestDailyStreak}',
            cs: cs,
          ),
          _StatCard(
            icon: Icons.date_range_rounded,
            label: l10n.trackerWeeklyStreak,
            value: '${stats.currentWeeklyStreak}',
            cs: cs,
          ),
          _StatCard(
            icon: Icons.workspace_premium_rounded,
            label: l10n.trackerLongestWeekly,
            value: '${stats.longestWeeklyStreak}',
            cs: cs,
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.cs,
    this.iconColor,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final ColorScheme cs;
  final Color? iconColor;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor ?? cs.onSurfaceVariant,
            size: AppSpacing.iconMd,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: valueColor ?? cs.onSurface,
            ),
          ),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: cs.onSurfaceVariant,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Recent Activity Section ────────────────────────────────────────────────

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection({
    required this.ref,
    required this.l10n,
    required this.cs,
  });

  final WidgetRef ref;
  final AppLocalizations l10n;
  final ColorScheme cs;

  String _timeAgo(DateTime dateTime, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
    return l10n.timeDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final completionsAsync = ref.watch(recentCompletionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.trackerRecentActivity,
          style: AppTypography.titleMedium.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppSpacing.sm),
        completionsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          ),
          error: (_, _) => Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(
              l10n.errorGeneric,
              style: AppTypography.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          data: (completions) {
            if (completions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: AppSpacing.iconXl,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.trackerNoCompletions,
                      style: AppTypography.bodyMedium.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: completions.map((completion) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_outline_rounded,
                          color: AppColors.success,
                          size: AppSpacing.iconMd,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            completion.amalId,
                            style: AppTypography.bodyMedium.copyWith(
                              color: cs.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _timeAgo(completion.completedAt, l10n),
                          style: AppTypography.labelSmall.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.stars_rounded,
                              color: AppColors.noorGold,
                              size: AppSpacing.iconSm,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '+${completion.coinsAwarded}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.noorGold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
