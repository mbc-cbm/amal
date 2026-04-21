import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/noor_coin_values.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/prayer_provider.dart';

// ── Known Ramadan dates (lookup table) ─────────────────────────────────────
/// Each entry: (start, end) in UTC midnight. Actual sighting may shift +/- 1 day.
class _RamadanPeriod {
  const _RamadanPeriod({required this.start, required this.end});
  final DateTime start;
  final DateTime end;

  int get totalDays => end.difference(start).inDays;

  bool contains(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(start) && d.isBefore(end);
  }

  /// 1-based day of Ramadan for the given [date]. Returns null if outside.
  int? dayOf(DateTime date) {
    if (!contains(date)) return null;
    final d = DateTime(date.year, date.month, date.day);
    return d.difference(start).inDays + 1;
  }

  bool isLastTenNights(DateTime date) {
    final day = dayOf(date);
    if (day == null) return false;
    return day >= (totalDays - 9); // last 10 days
  }
}

final List<_RamadanPeriod> _knownRamadans = [
  // Ramadan 1446 AH (2025)
  _RamadanPeriod(
    start: DateTime(2025, 3, 1),
    end: DateTime(2025, 3, 30),
  ),
  // Ramadan 1447 AH (2026)
  _RamadanPeriod(
    start: DateTime(2026, 2, 28),
    end: DateTime(2026, 3, 29),
  ),
  // Ramadan 1448 AH (2027)
  _RamadanPeriod(
    start: DateTime(2027, 2, 17),
    end: DateTime(2027, 3, 18),
  ),
  // Ramadan 1449 AH (2028)
  _RamadanPeriod(
    start: DateTime(2028, 2, 6),
    end: DateTime(2028, 3, 6),
  ),
  // Ramadan 1450 AH (2029)
  _RamadanPeriod(
    start: DateTime(2029, 1, 26),
    end: DateTime(2029, 2, 24),
  ),
];

/// Returns the current Ramadan period if [now] falls within one, else null.
_RamadanPeriod? _currentRamadan(DateTime now) {
  for (final r in _knownRamadans) {
    if (r.contains(now)) return r;
  }
  return null;
}

/// Returns the next upcoming Ramadan start date after [now].
_RamadanPeriod? _nextRamadan(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  for (final r in _knownRamadans) {
    if (r.start.isAfter(today)) return r;
  }
  return null;
}

// ── Screen ──────────────────────────────────────────────────────────────────

class RamadanScreen extends ConsumerStatefulWidget {
  const RamadanScreen({super.key});

  @override
  ConsumerState<RamadanScreen> createState() => _RamadanScreenState();
}

class _RamadanScreenState extends ConsumerState<RamadanScreen> {
  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  // Ramadan log state
  bool _todayFastLogged = false;
  bool _todayTarawihLogged = false;
  int _fastsCompleted = 0;
  bool _isLoggingFast = false;
  bool _isLoggingTarawih = false;

  _RamadanPeriod? _activeRamadan;
  _RamadanPeriod? _upcoming;

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  void _evaluate() {
    final now = DateTime.now();
    _activeRamadan = _currentRamadan(now);
    _upcoming = _activeRamadan == null ? _nextRamadan(now) : null;

    if (_activeRamadan != null) {
      _loadRamadanLog();
    } else if (_upcoming != null) {
      _startCountdown();
    }
  }

  // ── Countdown timer ─────────────────────────────────────────────────────

  void _startCountdown() {
    _updateRemaining();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _updateRemaining(),
    );
  }

  void _updateRemaining() {
    if (_upcoming == null) return;
    final now = DateTime.now();
    final diff = _upcoming!.start.difference(now);
    if (diff.isNegative) {
      _countdownTimer?.cancel();
      setState(() {
        _activeRamadan = _currentRamadan(now);
        _upcoming = null;
      });
      if (_activeRamadan != null) _loadRamadanLog();
      return;
    }
    setState(() => _remaining = diff);
  }

  // ── Firestore log ───────────────────────────────────────────────────────

  Future<void> _loadRamadanLog() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _activeRamadan == null) return;

    final year = _activeRamadan!.start.year.toString();
    final today = DateTime.now();
    final dayOfRamadan = _activeRamadan!.dayOf(today);

    final logRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('ramadanLog')
        .doc(year);

    try {
      final snapshot = await logRef.get();
      final data = snapshot.data();
      if (data != null) {
        // Count completed fasts
        int count = 0;
        bool fastToday = false;
        bool tarawihToday = false;

        for (final entry in data.entries) {
          if (entry.key.startsWith('day_')) {
            final dayData = entry.value as Map<String, dynamic>?;
            if (dayData != null && dayData['fasted'] == true) {
              count++;
            }
            // Check today
            if (entry.key == 'day_$dayOfRamadan') {
              fastToday = dayData?['fasted'] == true;
              tarawihToday = dayData?['tarawih'] == true;
            }
          }
        }

        if (mounted) {
          setState(() {
            _fastsCompleted = count;
            _todayFastLogged = fastToday;
            _todayTarawihLogged = tarawihToday;
          });
        }
      }
    } catch (_) {
      // Silently fail — user can retry by logging
    }
  }

  Future<void> _logFast() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _activeRamadan == null) return;

    final today = DateTime.now();
    final dayOfRamadan = _activeRamadan!.dayOf(today);
    if (dayOfRamadan == null) return;

    setState(() => _isLoggingFast = true);

    try {
      final year = _activeRamadan!.start.year.toString();
      final dateStr = DateFormat('yyyy-MM-dd').format(today);

      // Write to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('ramadanLog')
          .doc(year)
          .set({
        'day_$dayOfRamadan': {
          'fasted': true,
          'date': dateStr,
          'loggedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      // Award Noor Coins
      await FirebaseFunctions.instance
          .httpsCallable('updateNoorWallet')
          .call(<String, dynamic>{
        'uid': uid,
        'amount': NoorCoinValues.kFastNoorCoins,
        'source': 'ramadan_fast',
        'date': dateStr,
      });

      if (mounted) {
        setState(() {
          _todayFastLogged = true;
          _fastsCompleted++;
          _isLoggingFast = false;
        });

        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.fastLogged(NoorCoinValues.kFastNoorCoins)),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _isLoggingFast = false);
    }
  }

  Future<void> _logTarawih() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _activeRamadan == null) return;

    final today = DateTime.now();
    final dayOfRamadan = _activeRamadan!.dayOf(today);
    if (dayOfRamadan == null) return;

    setState(() => _isLoggingTarawih = true);

    try {
      final year = _activeRamadan!.start.year.toString();
      final dateStr = DateFormat('yyyy-MM-dd').format(today);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('ramadanLog')
          .doc(year)
          .set({
        'day_$dayOfRamadan': {
          'tarawih': true,
          'date': dateStr,
          'tarawihLoggedAt': FieldValue.serverTimestamp(),
        },
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _todayTarawihLogged = true;
          _isLoggingTarawih = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoggingTarawih = false);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.ramadan),
        centerTitle: true,
      ),
      body: _activeRamadan != null
          ? _buildDuringRamadan(context, l10n, colorScheme, isDark)
          : _buildCountdown(context, l10n, colorScheme, isDark),
    );
  }

  // ── Countdown View (outside Ramadan) ────────────────────────────────────

  Widget _buildCountdown(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final days = _remaining.inDays;
    final hours = _remaining.inHours % 24;
    final minutes = _remaining.inMinutes % 60;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Crescent moon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGold.withValues(alpha: 0.3),
                    AppColors.transparent,
                  ],
                ),
              ),
              child: const Icon(
                Icons.nightlight_round,
                size: AppSpacing.xxxl,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              l10n.ramadanCountdown,
              style: AppTypography.headlineMedium.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Countdown digits
            if (_upcoming != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CountdownUnit(
                    value: days,
                    label: l10n.countdownDays,
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    ':',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _CountdownUnit(
                    value: hours,
                    label: l10n.countdownHours,
                    isDark: isDark,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    ':',
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _CountdownUnit(
                    value: minutes,
                    label: l10n.countdownMinutes,
                    isDark: isDark,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  l10n.ramadanDaysRemaining(days, hours, minutes),
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyLarge.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceVariantDark
                        : AppColors.onSurfaceVariantLight,
                  ),
                ),
              ),
            ] else
              Text(
                l10n.ramadan,
                style: AppTypography.bodyLarge.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── During Ramadan View ────────────────────────────────────────────────

  Widget _buildDuringRamadan(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final now = DateTime.now();
    final dayOfRamadan = _activeRamadan!.dayOf(now) ?? 1;
    final totalDays = _activeRamadan!.totalDays;
    final isLastTen = _activeRamadan!.isLastTenNights(now);
    final prayerTimesAsync = ref.watch(todayPrayerTimesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header: Ramadan Mubarak + Day ──
          _RamadanHeader(
            l10n: l10n,
            dayOfRamadan: dayOfRamadan,
            totalDays: totalDays,
            isDark: isDark,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Suhoor / Iftar times ──
          prayerTimesAsync.when(
            data: (times) => _SuhoorIftarCard(
              l10n: l10n,
              suhoorTime: times.fajr,
              iftarTime: times.maghrib,
              isDark: isDark,
            ),
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Fasting log button ──
          _FastingLogCard(
            l10n: l10n,
            isDark: isDark,
            isLogged: _todayFastLogged,
            isLoading: _isLoggingFast,
            onLog: _logFast,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Tarawih toggle ──
          _TarawihCard(
            l10n: l10n,
            isDark: isDark,
            isLogged: _todayTarawihLogged,
            isLoading: _isLoggingTarawih,
            onLog: _logTarawih,
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Fasts completed counter ──
          _FastsCompletedCard(
            l10n: l10n,
            isDark: isDark,
            count: _fastsCompleted,
            total: totalDays,
          ),

          // ── Last 10 nights highlight ──
          if (isLastTen) ...[
            const SizedBox(height: AppSpacing.md),
            _LastTenNightsCard(
              l10n: l10n,
              isDark: isDark,
              dayOfRamadan: dayOfRamadan,
            ),
          ],

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Countdown Unit Widget ──────────────────────────────────────────────────

class _CountdownUnit extends StatelessWidget {
  const _CountdownUnit({
    required this.value,
    required this.label,
    required this.isDark,
  });

  final int value;
  final String label;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 80,
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.surfaceVariantDark
                : AppColors.surfaceVariantLight,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: AppColors.primaryGold.withValues(alpha: 0.3),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            value.toString().padLeft(2, '0'),
            style: AppTypography.displaySmall.copyWith(
              color: AppColors.primaryGold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark
                ? AppColors.onSurfaceVariantDark
                : AppColors.onSurfaceVariantLight,
          ),
        ),
      ],
    );
  }
}

// ── Ramadan Header ─────────────────────────────────────────────────────────

class _RamadanHeader extends StatelessWidget {
  const _RamadanHeader({
    required this.l10n,
    required this.dayOfRamadan,
    required this.totalDays,
    required this.isDark,
  });

  final AppLocalizations l10n;
  final int dayOfRamadan;
  final int totalDays;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.nightlight_round,
                color: AppColors.primaryGold,
                size: AppSpacing.iconLg,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  l10n.ramadanMubarak,
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.ramadanDay(dayOfRamadan),
                style: AppTypography.titleLarge.copyWith(
                  color: AppColors.primaryGold,
                ),
              ),
              Text(
                '$dayOfRamadan / $totalDays',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            child: LinearProgressIndicator(
              value: dayOfRamadan / totalDays,
              backgroundColor: AppColors.white.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primaryGold,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Suhoor / Iftar Card ────────────────────────────────────────────────────

class _SuhoorIftarCard extends StatelessWidget {
  const _SuhoorIftarCard({
    required this.l10n,
    required this.suhoorTime,
    required this.iftarTime,
    required this.isDark,
  });

  final AppLocalizations l10n;
  final DateTime suhoorTime;
  final DateTime iftarTime;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.jm();

    return Card(
      elevation: AppSpacing.cardElevation,
      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            // Suhoor
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.wb_twilight,
                    color: AppColors.info,
                    size: AppSpacing.iconLg,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.ramadanSuhoor,
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariantLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    timeFormat.format(suhoorTime),
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurfaceLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              width: 1,
              height: 64,
              color: isDark ? AppColors.dividerDark : AppColors.divider,
            ),

            // Iftar
            Expanded(
              child: Column(
                children: [
                  Icon(
                    Icons.nights_stay,
                    color: AppColors.warning,
                    size: AppSpacing.iconLg,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l10n.ramadanIftar,
                    style: AppTypography.labelLarge.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceVariantDark
                          : AppColors.onSurfaceVariantLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    timeFormat.format(iftarTime),
                    style: AppTypography.headlineSmall.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurfaceLight,
                      fontWeight: FontWeight.w700,
                    ),
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

// ── Fasting Log Card ───────────────────────────────────────────────────────

class _FastingLogCard extends StatelessWidget {
  const _FastingLogCard({
    required this.l10n,
    required this.isDark,
    required this.isLogged,
    required this.isLoading,
    required this.onLog,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final bool isLogged;
  final bool isLoading;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: InkWell(
        onTap: isLogged || isLoading ? null : onLog,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: AppSpacing.iconXl,
                height: AppSpacing.iconXl,
                decoration: BoxDecoration(
                  color: isLogged
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primaryGreen.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isLogged ? Icons.check_circle : Icons.restaurant,
                        color: isLogged
                            ? AppColors.success
                            : AppColors.primaryGreen,
                        size: AppSpacing.iconMd,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isLogged ? l10n.ramadanFastLogged : l10n.ramadanLogFast,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark
                            ? AppColors.onSurfaceDark
                            : AppColors.onSurfaceLight,
                      ),
                    ),
                    if (!isLogged)
                      Text(
                        '+${NoorCoinValues.kFastNoorCoins} ${l10n.noorCoins}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.noorGold,
                        ),
                      ),
                  ],
                ),
              ),
              if (isLogged)
                const Icon(
                  Icons.check,
                  color: AppColors.success,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tarawih Card ───────────────────────────────────────────────────────────

class _TarawihCard extends StatelessWidget {
  const _TarawihCard({
    required this.l10n,
    required this.isDark,
    required this.isLogged,
    required this.isLoading,
    required this.onLog,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final bool isLogged;
  final bool isLoading;
  final VoidCallback onLog;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: InkWell(
        onTap: isLogged || isLoading ? null : onLog,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: AppSpacing.iconXl,
                height: AppSpacing.iconXl,
                decoration: BoxDecoration(
                  color: isLogged
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.primaryGold.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(AppSpacing.sm),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        isLogged
                            ? Icons.check_circle
                            : Icons.nightlight_round,
                        color: isLogged
                            ? AppColors.success
                            : AppColors.primaryGold,
                        size: AppSpacing.iconMd,
                      ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  isLogged
                      ? l10n.ramadanTarawihLogged
                      : l10n.ramadanLogTarawih,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.onSurfaceDark
                        : AppColors.onSurfaceLight,
                  ),
                ),
              ),
              if (isLogged)
                const Icon(
                  Icons.check,
                  color: AppColors.success,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Fasts Completed Card ───────────────────────────────────────────────────

class _FastsCompletedCard extends StatelessWidget {
  const _FastsCompletedCard({
    required this.l10n,
    required this.isDark,
    required this.count,
    required this.total,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final int count;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppSpacing.cardElevation,
      color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              width: AppSpacing.iconXl,
              height: AppSpacing.iconXl,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events,
                color: AppColors.primaryGold,
                size: AppSpacing.iconMd,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.ramadanFastsCompleted(count),
                    style: AppTypography.titleMedium.copyWith(
                      color: isDark
                          ? AppColors.onSurfaceDark
                          : AppColors.onSurfaceLight,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    child: LinearProgressIndicator(
                      value: total > 0 ? count / total : 0,
                      backgroundColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceVariantLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGreen,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              '$count/$total',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Last 10 Nights Card ────────────────────────────────────────────────────

class _LastTenNightsCard extends StatelessWidget {
  const _LastTenNightsCard({
    required this.l10n,
    required this.isDark,
    required this.dayOfRamadan,
  });

  final AppLocalizations l10n;
  final bool isDark;
  final int dayOfRamadan;

  @override
  Widget build(BuildContext context) {
    final isOddNight = dayOfRamadan.isOdd;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.noorGold.withValues(alpha: 0.15),
            AppColors.noorGoldLight.withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(
          color: AppColors.noorGold.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.noorGold.withValues(alpha: 0.12),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.noorGold,
                size: AppSpacing.iconMd,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                l10n.ramadanLastTenNights,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.noorGold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            l10n.ramadanSeekLaylatulQadr,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark
                  ? AppColors.onSurfaceDark
                  : AppColors.onSurfaceLight,
            ),
          ),
          if (isOddNight) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.noorGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.star,
                    color: AppColors.noorGold,
                    size: AppSpacing.iconSm,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${l10n.ramadanDay(dayOfRamadan)} — Odd Night',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.noorGold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
