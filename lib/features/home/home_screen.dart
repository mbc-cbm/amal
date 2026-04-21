import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/prayer_log_model.dart';
import '../../core/models/prayer_times_model.dart';
import '../../core/providers/amal_tracker_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/providers/soul_stack_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/prayer_times_service.dart';
import '../../shared/widgets/prayer_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _prayerLabel(PrayerName prayer, AppLocalizations l10n) {
    switch (prayer) {
      case PrayerName.fajr:
        return l10n.fajr;
      case PrayerName.dhuhr:
        return l10n.dhuhr;
      case PrayerName.asr:
        return l10n.asr;
      case PrayerName.maghrib:
        return l10n.maghrib;
      case PrayerName.isha:
        return l10n.isha;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final user = FirebaseAuth.instance.currentUser;
    // Prefer Firestore name, fallback to Auth displayName, then empty
    final userDocAsync = ref.watch(
      StreamProvider((ref) => FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid ?? '_')
          .snapshots()),
    );
    final firestoreName = userDocAsync.valueOrNull?.data()?['name'] as String?;
    final displayName = (firestoreName?.isNotEmpty == true)
        ? firestoreName!
        : (user?.displayName ?? '');

    final timesAsync = ref.watch(todayPrayerTimesProvider);
    final logAsync = ref.watch(todayPrayerLogProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);
    final balanceAsync = ref.watch(
      StreamProvider((ref) =>
          ref.read(walletServiceProvider).watchNoorCoinBalance()),
    );

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HomeHeader(
              greeting: l10n.homeGreeting(displayName),
              balanceLabel: l10n.yourBalance,
              balance: balanceAsync.valueOrNull ?? 0,
              noorCoinsLabel: l10n.noorCoins,
            ),
          ),

          // ── Prayer summary card ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: timesAsync.when(
                loading: () => const _PrayerCardSkeleton(),
                error: (_, _) => _PrayerErrorTile(
                  prompt: l10n.setLocationPrompt,
                  onTap: () => context.push(AppRoutes.prayer),
                ),
                data: (times) {
                  final log = logAsync.valueOrNull ??
                      DayPrayerLog.empty(
                          PrayerTimesService.currentPrayerDateKey(
                              times.fajr));
                  final dateKey =
                      PrayerTimesService.currentPrayerDateKey(times.fajr);
                  final done = log.completedCount;
                  final total = PrayerName.values.length;

                  return _PrayerSummaryCard(
                    locationLabel: times.locationLabel,
                    progressLabel: l10n.prayerProgress(done, total),
                    viewAllLabel: l10n.viewAllPrayers,
                    sunriseLabel: l10n.sunrise,
                    sunriseTime: _formatTime(times.sunrise),
                    onViewAll: () => context.push(AppRoutes.prayer),
                    prayers: PrayerName.values.map((prayer) {
                      final prayerTime = times.timeFor(prayer);
                      // Allow completing any prayer whose time has arrived,
                      // plus always allow past prayers
                      final isAvailable = true;
                      return _PrayerRowData(
                        prayer: prayer,
                        label: _prayerLabel(prayer, l10n),
                        time: _formatTime(prayerTime),
                        isCompleted: log.isCompleted(prayer),
                        isNext: prayer == nextPrayer,
                        isAvailable: isAvailable,
                        onComplete: () => ref
                            .read(prayerLogActionProvider.notifier)
                            .complete(prayer: prayer, dateKey: dateKey),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
          ),

          // ── Soul Stack + Garden widget cards ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: _SoulStackWidget(ref: ref),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: _GardenWidget(ref: ref),
            ),
          ),

          // ── Amal Tracker widget ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              child: _AmalTrackerWidget(ref: ref),
            ),
          ),

          // ── Quick-access feature grid ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              child: Text(
                l10n.quickActions,
                style: AppTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverGrid.count(
              crossAxisCount: 4,
              mainAxisSpacing: AppSpacing.md,
              crossAxisSpacing: AppSpacing.md,
              childAspectRatio: 0.85,
              children: [
                _FeatureTile(
                  icon: Icons.explore_rounded,
                  label: l10n.qibla,
                  color: AppColors.primaryGreen,
                  onTap: () => context.push(AppRoutes.qibla),
                ),
                _FeatureTile(
                  icon: Icons.touch_app_rounded,
                  label: l10n.tasbeeh,
                  color: AppColors.featureTasbeeh,
                  onTap: () => context.push(AppRoutes.tasbeeh),
                ),
                _FeatureTile(
                  icon: Icons.nightlight_round,
                  label: l10n.ramadan,
                  color: AppColors.featureRamadan,
                  onTap: () => context.push(AppRoutes.ramadan),
                ),
                _FeatureTile(
                  icon: Icons.play_circle_rounded,
                  label: l10n.ywtl,
                  color: AppColors.featureYwtl,
                  onTap: () => context.push(AppRoutes.ywtl),
                ),
                _FeatureTile(
                  icon: Icons.auto_stories_rounded,
                  label: l10n.amalTracker,
                  color: AppColors.featureAmal,
                  onTap: () => context.push(AppRoutes.amalTracker),
                ),
                _FeatureTile(
                  icon: Icons.layers_rounded,
                  label: l10n.soulStack,
                  color: AppColors.primaryGold,
                  onTap: () => context.push(AppRoutes.soulStack),
                ),
                _FeatureTile(
                  icon: Icons.park_rounded,
                  label: l10n.garden,
                  color: AppColors.gardenGrass,
                  onTap: () => context.push(AppRoutes.jannahGarden),
                ),
                _FeatureTile(
                  icon: Icons.settings_rounded,
                  label: l10n.settings,
                  color: AppColors.featureSettings,
                  onTap: () => context.push(AppRoutes.settings),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break; // Already on home
            case 1:
              context.push(AppRoutes.prayer);
            case 2:
              context.push(AppRoutes.soulStack);
            case 3:
              context.push(AppRoutes.noorWallet);
            case 4:
              context.push(AppRoutes.profile);
          }
        },
        backgroundColor: cs.surface,
        indicatorColor: AppColors.primaryGreen.withAlpha(30),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded, color: AppColors.primaryGreen),
            label: l10n.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.access_time_rounded),
            selectedIcon: const Icon(Icons.access_time_filled, color: AppColors.primaryGreen),
            label: l10n.prayerTime,
          ),
          NavigationDestination(
            icon: const Icon(Icons.layers_outlined),
            selectedIcon: const Icon(Icons.layers_rounded, color: AppColors.primaryGreen),
            label: l10n.soulStack,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryGreen),
            label: l10n.noorWallet,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline_rounded),
            selectedIcon: const Icon(Icons.person_rounded, color: AppColors.primaryGreen),
            label: l10n.profile,
          ),
        ],
      ),
    );
  }
}

// ── Feature tile ──────────────────────────────────────────────────────────────

class _FeatureTile extends StatelessWidget {
  const _FeatureTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Soul Stack widget card ────────────────────────────────────────────────

class _SoulStackWidget extends ConsumerWidget {
  const _SoulStackWidget({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final dayStatus = ref.watch(soulStackDayStatusProvider);

    final riseOk = dayStatus.valueOrNull?.rise.completed ?? false;
    final shineOk = dayStatus.valueOrNull?.shine.completed ?? false;
    final glowOk = dayStatus.valueOrNull?.glow.completed ?? false;
    final done = [riseOk, shineOk, glowOk].where((v) => v).length;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.soulStack),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: done == 3
                ? [
                    AppColors.noorGold.withAlpha(25),
                    AppColors.primaryGold.withAlpha(12),
                  ]
                : [
                    AppColors.primaryGreen.withAlpha(15),
                    cs.surfaceContainerHighest.withAlpha(200),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: (done == 3 ? AppColors.noorGold : AppColors.primaryGreen)
                  .withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: done == 3 ? AppColors.noorGold : AppColors.primaryGreen,
                    size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.soulStack,
                  style: AppTypography.titleSmall.copyWith(
                    color: cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: cs.onSurfaceVariant),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              l10n.soulStackSubtitle,
              style: AppTypography.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Three stack progress bars
            Row(
              children: [
                _StackPill(label: 'Rise', icon: Icons.wb_sunny_rounded, done: riseOk),
                const SizedBox(width: AppSpacing.sm),
                _StackPill(label: 'Shine', icon: Icons.wb_twilight_rounded, done: shineOk),
                const SizedBox(width: AppSpacing.sm),
                _StackPill(label: 'Glow', icon: Icons.nightlight_round, done: glowOk),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StackPill extends StatelessWidget {
  const _StackPill({required this.label, required this.icon, required this.done});
  final String label;
  final IconData icon;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
        decoration: BoxDecoration(
          color: done
              ? AppColors.noorGold.withAlpha(25)
              : Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: done
              ? Border.all(color: AppColors.noorGold.withAlpha(80))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              done ? Icons.check_circle_rounded : icon,
              size: 16,
              color: done ? AppColors.noorGold : AppColors.primaryGreen,
            ),
            const SizedBox(width: AppSpacing.xs),
            Flexible(
              child: Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  color: done
                      ? AppColors.noorGold
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: done ? FontWeight.w700 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Garden widget card ────────────────────────────────────────────────────

class _GardenWidget extends ConsumerWidget {
  const _GardenWidget({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () => context.push(AppRoutes.jannahGarden),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1B5E20),
              Color(0xFF2E7D32),
              Color(0xFF388E3C),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gardenGrass.withAlpha(40),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Decorative scattered elements
            Positioned(
              right: -8,
              top: -8,
              child: Icon(Icons.park_rounded,
                  size: 80, color: AppColors.white.withAlpha(15)),
            ),
            Positioned(
              left: 60,
              bottom: -12,
              child: Icon(Icons.grass_rounded,
                  size: 50, color: AppColors.white.withAlpha(12)),
            ),
            Positioned(
              right: 50,
              bottom: 4,
              child: Icon(Icons.eco_rounded,
                  size: 28, color: AppColors.white.withAlpha(18)),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  // Garden icon with glow
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withAlpha(25),
                      border: Border.all(
                          color: AppColors.white.withAlpha(40), width: 1.5),
                    ),
                    child: const Icon(Icons.spa_rounded,
                        color: AppColors.white, size: 26),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.garden,
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.gardenVisit,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.white.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.white.withAlpha(25),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded,
                        size: 16, color: AppColors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Amal Tracker widget card ──────────────────────────────────────────────

class _AmalTrackerWidget extends ConsumerWidget {
  const _AmalTrackerWidget({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final statsAsync = ref.watch(trackerStatsProvider);

    final streak = statsAsync.valueOrNull?.currentDailyStreak ?? 0;
    final total = statsAsync.valueOrNull?.totalAmalsCompleted ?? 0;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.amalTracker),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          color: cs.surfaceContainerHighest,
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withAlpha(8),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with accent ring
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.featureAmal.withAlpha(30),
                    AppColors.featureAmal.withAlpha(15),
                  ],
                ),
                border: Border.all(
                    color: AppColors.featureAmal.withAlpha(50), width: 1.5),
              ),
              child: const Icon(Icons.auto_stories_rounded,
                  color: AppColors.featureAmal, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.amalTracker,
                    style: AppTypography.titleSmall.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.amalTrackerSubtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Stats column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (streak > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.local_fire_department_rounded,
                          size: 16, color: AppColors.warning),
                      const SizedBox(width: 2),
                      Text(
                        '$streak',
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                Text(
                  '$total',
                  style: AppTypography.labelSmall.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: cs.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

// ── Home header ────────────────────────────────────────────────────────────

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.greeting,
    required this.balanceLabel,
    required this.balance,
    required this.noorCoinsLabel,
  });

  final String greeting;
  final String balanceLabel;
  final int balance;
  final String noorCoinsLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        MediaQuery.of(context).padding.top + AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primaryGreen, AppColors.gardenGrass],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            greeting,
            style: AppTypography.headlineSmall.copyWith(
              color: AppColors.creamWhite,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Noor Coin balance chip
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded,
                    color: AppColors.primaryGold, size: 20),
                const SizedBox(width: AppSpacing.xs),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balanceLabel,
                      style: AppTypography.labelSmall.copyWith(
                          color: AppColors.creamWhite.withAlpha(180)),
                    ),
                    Text(
                      '$balance $noorCoinsLabel',
                      style: AppTypography.titleMedium.copyWith(
                        color: AppColors.creamWhite,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Prayer summary card ────────────────────────────────────────────────────

class _PrayerRowData {
  const _PrayerRowData({
    required this.prayer,
    required this.label,
    required this.time,
    required this.isCompleted,
    required this.isNext,
    required this.isAvailable,
    required this.onComplete,
  });

  final PrayerName prayer;
  final String label;
  final String time;
  final bool isCompleted;
  final bool isNext;
  final bool isAvailable;
  final Future<int> Function() onComplete;
}

class _PrayerSummaryCard extends StatelessWidget {
  const _PrayerSummaryCard({
    required this.locationLabel,
    required this.progressLabel,
    required this.viewAllLabel,
    required this.sunriseLabel,
    required this.sunriseTime,
    required this.onViewAll,
    required this.prayers,
  });

  final String locationLabel;
  final String progressLabel;
  final String viewAllLabel;
  final String sunriseLabel;
  final String sunriseTime;
  final VoidCallback onViewAll;
  final List<_PrayerRowData> prayers;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              children: [
                const Icon(Icons.mosque_rounded,
                    color: AppColors.primaryGreen, size: 18),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    locationLabel,
                    style: AppTypography.bodySmall
                        .copyWith(color: cs.onSurfaceVariant),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  progressLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Sunrise row
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: SunriseRow(label: sunriseLabel, time: sunriseTime),
          ),

          const SizedBox(height: AppSpacing.sm),
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.sm),

          // Prayer cards
          ...prayers.map(
            (data) => Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 2),
              child: PrayerCard(
                prayer: data.prayer,
                label: data.label,
                time: data.time,
                isCompleted: data.isCompleted,
                isNext: data.isNext,
                isAvailable: data.isAvailable,
                onComplete: data.onComplete,
              ),
            ),
          ),

          // View all button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: GestureDetector(
              onTap: onViewAll,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    viewAllLabel,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 16, color: AppColors.primaryGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Skeleton / error states ────────────────────────────────────────────────

class _PrayerCardSkeleton extends StatelessWidget {
  const _PrayerCardSkeleton();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.primaryGreen),
      ),
    );
  }
}

class _PrayerErrorTile extends StatelessWidget {
  const _PrayerErrorTile({required this.prompt, required this.onTap});

  final String prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
              color: AppColors.primaryGreen.withAlpha(60), width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_rounded,
                color: AppColors.primaryGreen),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(prompt,
                  style: AppTypography.bodyMedium
                      .copyWith(color: cs.onSurface)),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: AppColors.primaryGreen),
          ],
        ),
      ),
    );
  }
}
