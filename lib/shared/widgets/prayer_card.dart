import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/prayer_times_model.dart';

/// A card representing a single fard prayer with its time and a completion
/// checkbox. Displays a brief celebration overlay when marked complete.
class PrayerCard extends StatefulWidget {
  const PrayerCard({
    super.key,
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

  /// Formatted time string, e.g. "05:23".
  final String time;

  final bool isCompleted;

  /// True when this is the next upcoming prayer (highlighted).
  final bool isNext;

  /// False if prayer time hasn't arrived yet (cannot complete future prayers).
  final bool isAvailable;

  /// Called when the user taps the checkbox; returns Noor Coins awarded.
  final Future<int> Function() onComplete;

  @override
  State<PrayerCard> createState() => _PrayerCardState();
}

class _PrayerCardState extends State<PrayerCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _celebCtrl;
  late final Animation<double> _celebScale;
  late final Animation<double> _celebOpacity;

  bool _loading = false;
  int? _coinsAwarded;

  @override
  void initState() {
    super.initState();
    _celebCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _celebScale = Tween<double>(begin: 0.6, end: 1.1).animate(
      CurvedAnimation(parent: _celebCtrl, curve: Curves.elasticOut),
    );
    _celebOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebCtrl,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _celebCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_loading || widget.isCompleted || !widget.isAvailable) return;
    setState(() => _loading = true);
    try {
      final coins = await widget.onComplete();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _coinsAwarded = coins > 0 ? coins : null;
      });
      if (coins > 0) {
        await _celebCtrl.forward(from: 0);
        await Future<void>.delayed(const Duration(milliseconds: 700));
        if (mounted) _celebCtrl.reverse();
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isNext = widget.isNext;
    final isCompleted = widget.isCompleted;

    return Stack(
      children: [
        _buildCard(cs, isNext, isCompleted),
        if (_coinsAwarded != null) _buildCelebration(),
      ],
    );
  }

  Widget _buildCard(ColorScheme cs, bool isNext, bool isCompleted) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.primaryGreen.withAlpha(18)
            : isNext
                ? cs.surfaceContainerHighest
                : cs.surfaceContainer,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: isCompleted
              ? AppColors.primaryGreen.withAlpha(80)
              : isNext
                  ? AppColors.primaryGold.withAlpha(120)
                  : AppColors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // ── Prayer icon ──────────────────────────────────────────────────
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.primaryGreen.withAlpha(30)
                  : AppColors.primaryGold.withAlpha(20),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _iconFor(widget.prayer),
              size: 20,
              color: isCompleted
                  ? AppColors.primaryGreen
                  : AppColors.primaryGold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),

          // ── Name + time ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: AppTypography.titleSmall.copyWith(
                    color: isCompleted
                        ? AppColors.primaryGreen
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight:
                        isNext ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                Text(
                  widget.time,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // ── Next badge ───────────────────────────────────────────────────
          if (isNext && !isCompleted)
            Container(
              margin: const EdgeInsets.only(right: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryGold.withAlpha(30),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'NEXT',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.primaryGold,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),

          // ── Checkbox ─────────────────────────────────────────────────────
          _buildCheckbox(isCompleted),
        ],
      ),
    );
  }

  Widget _buildCheckbox(bool isCompleted) {
    if (_loading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primaryGreen,
        ),
      );
    }

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isCompleted ? AppColors.primaryGreen : AppColors.transparent,
          border: Border.all(
            color: isCompleted
                ? AppColors.primaryGreen
                : widget.isAvailable
                    ? Theme.of(context).colorScheme.outline
                    : Theme.of(context)
                        .colorScheme
                        .outline
                        .withAlpha(60),
            width: 2,
          ),
        ),
        child: isCompleted
            ? const Icon(Icons.check_rounded,
                size: 16, color: AppColors.white)
            : null,
      ),
    );
  }

  Widget _buildCelebration() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _celebCtrl,
        builder: (context, child) => Opacity(
          opacity: _celebOpacity.value,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withAlpha(220),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Center(
              child: ScaleTransition(
                scale: _celebScale,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.primaryGold,
                      size: 32,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '+${_coinsAwarded!}',
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Noor Coins',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.creamWhite,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _iconFor(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return Icons.wb_twilight_rounded;
      case PrayerName.dhuhr:
        return Icons.wb_sunny_rounded;
      case PrayerName.asr:
        return Icons.light_mode_outlined;
      case PrayerName.maghrib:
        return Icons.nights_stay_rounded;
      case PrayerName.isha:
        return Icons.dark_mode_rounded;
    }
  }
}

/// Smaller non-interactive display row for Sunrise (not tracked, not awarded).
class SunriseRow extends StatelessWidget {
  const SunriseRow({super.key, required this.label, required this.time});

  final String label;
  final String time;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.wb_sunny_outlined,
            size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.bodySmall
              .copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          time,
          style: AppTypography.bodySmall.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
