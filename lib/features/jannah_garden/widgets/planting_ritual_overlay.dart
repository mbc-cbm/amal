import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../painters/asset_painters.dart';

// ═══════════════════════════════════════════════════════════════════════════
// PLANTING RITUAL OVERLAY
// Shows the 9-step planting animation sequence over the garden.
// ═══════════════════════════════════════════════════════════════════════════

class PlantingRitualOverlay extends StatefulWidget {
  const PlantingRitualOverlay({
    super.key,
    required this.assetTemplateId,
    required this.referenceTextAr,
    required this.referenceEn,
    required this.onComplete,
  });

  final String assetTemplateId;
  final String referenceTextAr;
  final String referenceEn;
  final VoidCallback onComplete;

  @override
  State<PlantingRitualOverlay> createState() => _PlantingRitualOverlayState();
}

class _PlantingRitualOverlayState extends State<PlantingRitualOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _plantCtrl;
  late final AnimationController _verseCtrl;
  late final AnimationController _growCtrl;

  bool _showVerse = false;
  bool _showGrowth = false;
  bool _done = false;
  bool _isFirstPlacement = false;

  // Particle burst state
  bool _showBurst = false;
  double _burstProgress = 0;

  @override
  void initState() {
    super.initState();

    // Check first placement
    _checkFirstPlacement();

    // Step 6: Planting descent (0.8s)
    _plantCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Step 7: Verse display (3.0s total: 0.5 fade in + 2.0 hold + 0.5 fade out)
    _verseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // Step 8: Growth animation (2.0s)
    _growCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _startSequence();
  }

  void _checkFirstPlacement() {
    try {
      final box = Hive.box<bool>('firstPlacements');
      _isFirstPlacement = !(box.get(widget.assetTemplateId) ?? false);
      if (_isFirstPlacement) {
        box.put(widget.assetTemplateId, true);
      }
    } catch (_) {
      _isFirstPlacement = false;
    }
  }

  Future<void> _startSequence() async {
    // Step 6: Plant descent
    await _plantCtrl.forward();

    // Burst on touchdown
    setState(() => _showBurst = true);
    _animateBurst();

    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Step 7: First-time verse
    if (_isFirstPlacement && widget.referenceTextAr.isNotEmpty) {
      setState(() => _showVerse = true);
      await _verseCtrl.forward();
      setState(() => _showVerse = false);
    }

    // Step 8: Growth animation
    setState(() => _showGrowth = true);
    await _growCtrl.forward();

    // Done
    setState(() => _done = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    widget.onComplete();
  }

  Future<void> _animateBurst() async {
    const steps = 20;
    for (var i = 0; i <= steps; i++) {
      if (!mounted) return;
      setState(() => _burstProgress = i / steps);
      await Future<void>.delayed(const Duration(milliseconds: 30));
    }
    if (mounted) setState(() => _showBurst = false);
  }

  @override
  void dispose() {
    _plantCtrl.dispose();
    _verseCtrl.dispose();
    _growCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_done) return const SizedBox.shrink();

    return Stack(
      children: [
        // Verse overlay (Step 7)
        if (_showVerse)
          AnimatedBuilder(
            animation: _verseCtrl,
            builder: (context, _) {
              final t = _verseCtrl.value;
              // Fade in 0–0.17, hold 0.17–0.83, fade out 0.83–1.0
              double opacity;
              if (t < 0.17) {
                opacity = t / 0.17;
              } else if (t > 0.83) {
                opacity = (1.0 - t) / 0.17;
              } else {
                opacity = 1.0;
              }

              return Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.7 * opacity),
                  child: Center(
                    child: Opacity(
                      opacity: opacity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xl),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.referenceTextAr,
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
                            Text(
                              widget.referenceEn,
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.gardenCelestial,
                                fontStyle: FontStyle.italic,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

        // Plant descent + burst + growth (centred)
        if (!_showVerse)
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Planting animation
                AnimatedBuilder(
                  animation: Listenable.merge([_plantCtrl, _growCtrl]),
                  builder: (context, _) {
                    double scale;
                    double offsetY = 0;

                    if (_showGrowth) {
                      // Growth: 0.3 → 1.1 → 1.0
                      final t = _growCtrl.value;
                      if (t < 0.8) {
                        scale = 0.3 + (t / 0.8) * 0.8; // 0.3 → 1.1
                      } else {
                        scale = 1.1 - ((t - 0.8) / 0.2) * 0.1; // 1.1 → 1.0
                      }
                    } else {
                      // Descent: scale 0.2 → 1.0, position drops
                      final t = Curves.easeOut.transform(_plantCtrl.value);
                      scale = 0.2 + t * 0.8;
                      offsetY = -60 * (1.0 - t);
                    }

                    return Transform.translate(
                      offset: Offset(0, offsetY),
                      child: Transform.scale(
                        scale: scale,
                        child: SizedBox(
                          width: 80,
                          height: 80,
                          child: CustomPaint(
                            painter: JannahAssetPainterRegistry.getPainter(
                              widget.assetTemplateId,
                              healthState: 1,
                              animationValue: 0.5,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // Burst particles
                if (_showBurst)
                  SizedBox(
                    width: 120,
                    height: 60,
                    child: CustomPaint(
                      painter: _BurstPainter(progress: _burstProgress),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Burst particle painter ────────────────────────────────────────────────

class _BurstPainter extends CustomPainter {
  _BurstPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final rng = Random(42);

    for (var i = 0; i < 12; i++) {
      final angle = (i / 12) * pi * 2 + rng.nextDouble() * 0.3;
      final dist = 30 * progress + rng.nextDouble() * 10;
      final px = cx + cos(angle) * dist;
      final py = cy + sin(angle) * dist - progress * 15; // drift upward
      final alpha = (1.0 - progress) * 0.8;
      final radius = 3.0 * (1.0 - progress * 0.5);

      canvas.drawCircle(
        Offset(px, py),
        radius,
        Paint()
          ..color = AppColors.gardenGoldGlow.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter o) => o.progress != progress;
}
