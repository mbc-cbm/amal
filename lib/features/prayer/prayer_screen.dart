import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/prayer_log_model.dart';
import '../../core/models/prayer_times_model.dart';
import '../../core/providers/prayer_provider.dart';
import '../../core/services/prayer_times_service.dart';
import '../../core/utils/app_preferences.dart';
import '../../shared/widgets/amal_button.dart';
import '../../shared/widgets/amal_text_field.dart';
import '../../shared/widgets/prayer_card.dart';

class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  bool _showCityForm = false;
  final _cityCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();

  @override
  void dispose() {
    _cityCtrl.dispose();
    _countryCtrl.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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

  String _modeLabelFor(PrayerNotificationMode mode, AppLocalizations l10n) {
    switch (mode) {
      case PrayerNotificationMode.silent:
        return l10n.modeSilent;
      case PrayerNotificationMode.notification:
        return l10n.modeNotification;
      case PrayerNotificationMode.azan:
        return l10n.modeAzan;
    }
  }

  Future<void> _saveCity() async {
    final city = _cityCtrl.text.trim();
    final country = _countryCtrl.text.trim();
    if (city.isEmpty || country.isEmpty) return;
    await AppPreferences.instance.setPrayerCity(city, country);
    await AppPreferences.instance.setPrayerUseGps(false);
    await AppPreferences.instance.clearPrayerTimesCache();
    if (mounted) {
      setState(() => _showCityForm = false);
      ref.invalidate(todayPrayerTimesProvider);
    }
  }

  Future<void> _switchToGps() async {
    await AppPreferences.instance.setPrayerUseGps(true);
    await AppPreferences.instance.clearPrayerTimesCache();
    ref.invalidate(currentPositionProvider);
    ref.invalidate(todayPrayerTimesProvider);
    if (mounted) setState(() => _showCityForm = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final timesAsync = ref.watch(todayPrayerTimesProvider);
    final logAsync = ref.watch(todayPrayerLogProvider);
    final nextPrayer = ref.watch(nextPrayerProvider);
    final notifAsync = ref.watch(prayerNotificationSettingsProvider);
    final tradition =
        ref.watch(userTraditionProvider).valueOrNull ?? 'sunni';

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.prayerTimesTitle,
            style: AppTypography.titleLarge.copyWith(color: cs.onSurface)),
        backgroundColor: cs.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
      ),
      body: timesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (e, _) => _buildError(context, l10n, e.toString()),
        data: (times) {
          final log = logAsync.valueOrNull ??
              DayPrayerLog.empty(
                  PrayerTimesService.currentPrayerDateKey(times.fajr));
          final dateKey =
              PrayerTimesService.currentPrayerDateKey(times.fajr);
          final now = DateTime.now();

          return RefreshIndicator(
            color: AppColors.primaryGreen,
            onRefresh: () async {
              await AppPreferences.instance.clearPrayerTimesCache();
              ref.invalidate(todayPrayerTimesProvider);
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: AppSpacing.sm),

                        // ── Location row ──────────────────────────────────
                        _buildLocationRow(context, l10n, cs, times),
                        const SizedBox(height: AppSpacing.sm),

                        // ── City form (expandable) ────────────────────────
                        if (_showCityForm) _buildCityForm(l10n),

                        // ── Cache notice ──────────────────────────────────
                        _buildCacheNotice(l10n, cs, times),
                        const SizedBox(height: AppSpacing.lg),

                        // ── Today heading ─────────────────────────────────
                        Text(l10n.todaysPrayers,
                            style: AppTypography.titleMedium
                                .copyWith(color: cs.onSurface)),
                        const SizedBox(height: AppSpacing.md),

                        // ── Sunrise (display only) ────────────────────────
                        SunriseRow(
                          label: l10n.sunrise,
                          time: _formatTime(times.sunrise),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
                    ),
                  ),
                ),

                // ── Prayer cards ────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  sliver: SliverList.separated(
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemCount: PrayerName.values.length,
                    itemBuilder: (context, i) {
                      final prayer = PrayerName.values[i];
                      final prayerTime = times.timeFor(prayer);
                      final isAvailable = now.isAfter(prayerTime) ||
                          prayerTime.difference(now).inSeconds < 60;
                      return PrayerCard(
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
                    },
                  ),
                ),

                // ── Notification settings ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg,
                        AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
                    child: Text(l10n.notificationSettings,
                        style: AppTypography.titleMedium
                            .copyWith(color: cs.onSurface)),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  sliver: SliverList.separated(
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemCount: PrayerName.values.length,
                    itemBuilder: (context, i) {
                      final prayer = PrayerName.values[i];
                      final settings = notifAsync.valueOrNull ??
                          PrayerNotificationSettings.defaults;
                      return _NotificationRow(
                        label: _prayerLabel(prayer, l10n),
                        currentMode: settings.modeFor(prayer),
                        tradition: tradition,
                        onChanged: (m) => ref
                            .read(prayerNotificationSettingsProvider
                                .notifier)
                            .setMode(prayer, m),
                        modeLabelFor: (m) => _modeLabelFor(m, l10n),
                      );
                    },
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSpacing.xxl),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Sub-builders ──────────────────────────────────────────────────────────

  Widget _buildLocationRow(BuildContext context, AppLocalizations l10n,
      ColorScheme cs, PrayerTimes times) {
    return Row(
      children: [
        const Icon(Icons.location_on_rounded,
            size: 16, color: AppColors.primaryGreen),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            times.locationLabel,
            style: AppTypography.bodySmall
                .copyWith(color: cs.onSurfaceVariant),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(
          onPressed: () =>
              setState(() => _showCityForm = !_showCityForm),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(l10n.changeLocation,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.primaryGreen)),
        ),
      ],
    );
  }

  Widget _buildCityForm(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AmalPrimaryButton(
            label: l10n.useGps,
            onPressed: _switchToGps,
          ),
          const SizedBox(height: AppSpacing.sm),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          AmalTextField(
            label: l10n.cityLabel,
            controller: _cityCtrl,
            prefixIcon: const Icon(Icons.location_city_rounded),
            onChanged: (_) {},
          ),
          const SizedBox(height: AppSpacing.sm),
          AmalTextField(
            label: l10n.countryLabel,
            controller: _countryCtrl,
            prefixIcon: const Icon(Icons.flag_rounded),
            onChanged: (_) {},
          ),
          const SizedBox(height: AppSpacing.md),
          AmalGoldButton(label: l10n.search, onPressed: _saveCity),
        ],
      ),
    );
  }

  Widget _buildCacheNotice(
      AppLocalizations l10n, ColorScheme cs, PrayerTimes times) {
    final age = DateTime.now().difference(times.fetchedAt);
    if (age.inMinutes < 60) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(l10n.usingCachedData,
              style: AppTypography.labelSmall
                  .copyWith(color: AppColors.warning)),
          const Spacer(),
          Text(l10n.lastUpdated(_formatAge(age, l10n)),
              style: AppTypography.labelSmall
                  .copyWith(color: cs.onSurfaceVariant)),
        ],
      ),
    );
  }

  String _formatAge(Duration age, AppLocalizations l10n) {
    if (age.inHours < 1) return l10n.timeMinutesAgo(age.inMinutes);
    if (age.inHours < 24) return l10n.timeHoursAgo(age.inHours);
    return l10n.timeDaysAgo(age.inDays);
  }

  Widget _buildError(
      BuildContext context, AppLocalizations l10n, String message) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 56, color: cs.outline),
            const SizedBox(height: AppSpacing.md),
            Text(message,
                style: AppTypography.bodyMedium
                    .copyWith(color: cs.onSurfaceVariant),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.lg),
            AmalTextField(
              label: l10n.cityLabel,
              controller: _cityCtrl,
              prefixIcon: const Icon(Icons.location_city_rounded),
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.sm),
            AmalTextField(
              label: l10n.countryLabel,
              controller: _countryCtrl,
              prefixIcon: const Icon(Icons.flag_rounded),
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.md),
            AmalPrimaryButton(label: l10n.search, onPressed: _saveCity),
          ],
        ),
      ),
    );
  }
}

// ── Notification mode row ──────────────────────────────────────────────────

class _NotificationRow extends StatelessWidget {
  const _NotificationRow({
    required this.label,
    required this.currentMode,
    required this.tradition,
    required this.onChanged,
    required this.modeLabelFor,
  });

  final String label;
  final PrayerNotificationMode currentMode;
  final String tradition;
  final ValueChanged<PrayerNotificationMode> onChanged;
  final String Function(PrayerNotificationMode) modeLabelFor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style:
                    AppTypography.bodyMedium.copyWith(color: cs.onSurface)),
          ),
          _ModeToggle(
            currentMode: currentMode,
            onChanged: onChanged,
            modeLabelFor: modeLabelFor,
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({
    required this.currentMode,
    required this.onChanged,
    required this.modeLabelFor,
  });

  final PrayerNotificationMode currentMode;
  final ValueChanged<PrayerNotificationMode> onChanged;
  final String Function(PrayerNotificationMode) modeLabelFor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: PrayerNotificationMode.values.map((mode) {
          final selected = mode == currentMode;
          return GestureDetector(
            onTap: () => onChanged(mode),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryGreen
                    : AppColors.transparent,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _iconFor(mode),
                    size: 12,
                    color: selected ? AppColors.white : cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    modeLabelFor(mode),
                    style: AppTypography.labelSmall.copyWith(
                      color:
                          selected ? AppColors.white : cs.onSurfaceVariant,
                      fontWeight: selected
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _iconFor(PrayerNotificationMode mode) {
    switch (mode) {
      case PrayerNotificationMode.silent:
        return Icons.volume_off_rounded;
      case PrayerNotificationMode.notification:
        return Icons.notifications_rounded;
      case PrayerNotificationMode.azan:
        return Icons.volume_up_rounded;
    }
  }
}
