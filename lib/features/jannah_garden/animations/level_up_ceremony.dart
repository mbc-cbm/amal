import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// LEVEL UP CEREMONY — 4-phase full-screen animation
// ═══════════════════════════════════════════════════════════════════════════

class LevelUpCeremony extends StatefulWidget {
  const LevelUpCeremony({
    super.key,
    required this.newLevel,
    required this.onComplete,
  });

  final int newLevel; // 2, 3, or 4
  final VoidCallback onComplete;

  @override
  State<LevelUpCeremony> createState() => _LevelUpCeremonyState();
}

class _LevelUpCeremonyState extends State<LevelUpCeremony>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Phase intervals (total 4 seconds)
  late final Animation<double> _phase1; // Land expansion  0.0–1.0s (0–0.25)
  late final Animation<double> _phase2; // Quranic verse   1.0–3.0s (0.25–0.75)
  late final Animation<double> _phase3; // Camera ascension 3.0–4.0s (0.75–1.0)

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    );

    _phase1 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.25, curve: Curves.easeOut),
    );
    _phase2 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.75, curve: Curves.easeInOut),
    );
    _phase3 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.75, 1.0, curve: Curves.easeInOut),
    );

    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Stack(
          fit: StackFit.expand,
          children: [
            // Phase 1: Land expansion wave
            CustomPaint(
              painter: _LandExpansionPainter(
                progress: _phase1.value,
                level: widget.newLevel,
              ),
            ),

            // Phase 2: Quranic verse overlay
            if (_phase2.value > 0 && _phase2.value < 1)
              _buildVerseOverlay(l10n),

            // Phase 3: Noor particle cascade
            if (_phase3.value > 0)
              CustomPaint(
                painter: _NoorCascadePainter(
                  progress: _phase3.value,
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildVerseOverlay(AppLocalizations l10n) {
    final t = _phase2.value;
    // Fade in 0–0.2, hold 0.2–0.8, fade out 0.8–1.0
    double opacity;
    if (t < 0.2) {
      opacity = t / 0.2;
    } else if (t > 0.8) {
      opacity = (1.0 - t) / 0.2;
    } else {
      opacity = 1.0;
    }

    final verseAr = _verseArabic(widget.newLevel);
    final verseEn = _verseEnglish(widget.newLevel, l10n);
    final levelName = _levelName(widget.newLevel, l10n);

    return Container(
      color: Colors.black.withValues(alpha: 0.85 * opacity),
      child: Center(
        child: Opacity(
          opacity: opacity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Arabesque border top
                CustomPaint(
                  size: const Size(200, 16),
                  painter: _ArabesqueBorderPainter(opacity: opacity),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Arabic verse
                Text(
                  verseAr,
                  style: const TextStyle(
                    fontSize: 28,
                    color: AppColors.noorGold,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                    decoration: TextDecoration.none,
                  ),
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),

                // English translation
                Text(
                  verseEn,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gardenCelestial.withValues(alpha: 0.8),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.lg),

                // Level name
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.noorGold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    border: Border.all(
                      color: AppColors.noorGold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    levelName,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.noorGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // Arabesque border bottom
                CustomPaint(
                  size: const Size(200, 16),
                  painter: _ArabesqueBorderPainter(opacity: opacity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _verseArabic(int level) => switch (level) {
        2 => 'وَبَشِّرِ الَّذِينَ آمَنُوا',
        3 => 'إِنَّ الْمُتَّقِينَ فِي جَنَّاتٍ',
        4 => 'فِيهَا أَنْهَارٌ مِّن مَّاءٍ غَيْرِ آسِنٍ',
        _ => '',
      };

  String _verseEnglish(int level, AppLocalizations l10n) => switch (level) {
        2 => l10n.verseLevel2En,
        3 => l10n.verseLevel3En,
        4 => l10n.verseLevel4En,
        _ => '',
      };

  String _levelName(int level, AppLocalizations l10n) => switch (level) {
        1 => l10n.levelAlRawdah,
        2 => l10n.levelAlFirdaws,
        3 => l10n.levelAlNaim,
        4 => l10n.levelJannatAlMawa,
        _ => '',
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// LAND EXPANSION PAINTER — colour wave flooding into new zone
// ═══════════════════════════════════════════════════════════════════════════

class _LandExpansionPainter extends CustomPainter {
  _LandExpansionPainter({required this.progress, required this.level});
  final double progress;
  final int level;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final cx = size.width / 2;
    final cy = size.height / 2;

    // Expanding ring of green from the boundary
    final maxRadius = size.width * 0.6;
    final minRadius = maxRadius * (0.5 + (level - 2) * 0.15);
    final currentRadius = minRadius + (maxRadius - minRadius) * progress;

    // Green wave
    canvas.drawCircle(
      Offset(cx, cy),
      currentRadius,
      Paint()
        ..color = AppColors.gardenGrass.withValues(alpha: 0.15 * (1.0 - progress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 40 * (1.0 - progress * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );

    // Golden edge of the wave
    canvas.drawCircle(
      Offset(cx, cy),
      currentRadius + 5,
      Paint()
        ..color = AppColors.noorGold.withValues(alpha: 0.2 * (1.0 - progress))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Flower blooms along the wave edge
    if (progress > 0.3 && progress < 0.9) {
      final flowerCount = 12;
      for (var i = 0; i < flowerCount; i++) {
        final angle = (i / flowerCount) * pi * 2;
        final fx = cx + cos(angle) * currentRadius;
        final fy = cy + sin(angle) * currentRadius;
        final flowerScale = ((progress - 0.3) / 0.4).clamp(0.0, 1.0);

        // Small flower
        for (var p = 0; p < 5; p++) {
          final pAngle = p * pi * 2 / 5;
          final px = fx + cos(pAngle) * 4 * flowerScale;
          final py = fy + sin(pAngle) * 4 * flowerScale;
          canvas.drawCircle(
            Offset(px, py),
            2 * flowerScale,
            Paint()..color = Colors.white.withValues(alpha: 0.5 * (1.0 - progress)),
          );
        }
        // Gold centre
        canvas.drawCircle(
          Offset(fx, fy),
          1.5 * flowerScale,
          Paint()..color = AppColors.noorGold.withValues(alpha: 0.6 * (1.0 - progress)),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_LandExpansionPainter o) => o.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════
// NOOR CASCADE PAINTER — particles drifting down across new garden
// ═══════════════════════════════════════════════════════════════════════════

class _NoorCascadePainter extends CustomPainter {
  _NoorCascadePainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final rng = Random(42);
    final count = (40 * (1.0 - progress * 0.5)).round().clamp(5, 40);

    for (var i = 0; i < count; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final y = (baseY + progress * size.height * 0.4) % size.height;
      final alpha = (1.0 - progress) * 0.5 * (0.5 + rng.nextDouble() * 0.5);
      final radius = 2 + rng.nextDouble() * 3;

      final isGold = i.isEven;
      final color = isGold ? AppColors.noorGold : AppColors.gardenCelestial;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
    }
  }

  @override
  bool shouldRepaint(_NoorCascadePainter o) => o.progress != progress;
}

// ═══════════════════════════════════════════════════════════════════════════
// ARABESQUE BORDER PAINTER — geometric golden pattern
// ═══════════════════════════════════════════════════════════════════════════

class _ArabesqueBorderPainter extends CustomPainter {
  _ArabesqueBorderPainter({required this.opacity});
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.noorGold.withValues(alpha: 0.4 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final step = size.width / 10;
    for (var i = 0; i < 10; i++) {
      final x = i * step + step / 2;
      final y = size.height / 2;

      // Diamond
      final path = Path()
        ..moveTo(x, y - 6)
        ..lineTo(x + 6, y)
        ..lineTo(x, y + 6)
        ..lineTo(x - 6, y)
        ..close();
      canvas.drawPath(path, paint);

      // Dot at centre
      canvas.drawCircle(
        Offset(x, y),
        1.5,
        Paint()..color = AppColors.noorGold.withValues(alpha: 0.3 * opacity),
      );
    }

    // Horizontal lines
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      Paint()
        ..color = AppColors.noorGold.withValues(alpha: 0.15 * opacity)
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(_ArabesqueBorderPainter o) => o.opacity != opacity;
}
