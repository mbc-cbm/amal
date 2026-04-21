import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';

const _bgColor = Color(0xFF0A2414);

/// Full-screen explainer for the Outer Garden (Sadaqa Zariyah).
/// Shown when outerGardenVisitCount < 5.
class OuterGardenExplainerScreen extends StatelessWidget {
  const OuterGardenExplainerScreen({
    super.key,
    required this.onEnter,
    this.showSkip = false,
  });

  final VoidCallback onEnter;
  final bool showSkip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final locale = Localizations.localeOf(context).languageCode;
    final isRtl = locale == 'ar' || locale == 'ur';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bgColor,
        body: Stack(
        children: [
          // Animated mist background
          const Positioned.fill(child: _MistBackground()),

          // Forest horizon illustration
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: const _ForestHorizon(),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  const Spacer(flex: 4),

                  // Heading
                  Text(
                    l10n.outerGardenTitle,
                    style: AppTypography.headlineMedium.copyWith(
                      color: AppColors.gardenCelestial,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Arabic subheading
                  const Text(
                    'صدقة جارية',
                    style: TextStyle(
                      fontSize: 22,
                      color: AppColors.noorGold,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Body text
                  Text(
                    l10n.outerGardenExplainerBody,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.gardenCelestial.withValues(alpha: 0.85),
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Subtext
                  Text(
                    l10n.outerGardenExplainerSubtext,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.noorGold.withValues(alpha: 0.7),
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const Spacer(flex: 2),

                  // Enter button
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFC9942A), Color(0xFFE8C547)],
                        ),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusLg),
                      ),
                      child: FilledButton(
                        onPressed: onEnter,
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          shadowColor: Colors.transparent,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.md),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusLg),
                          ),
                        ),
                        child: Text(
                          l10n.outerGardenEnterButton,
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),

          // Skip button (top-right, after 5+ visits)
          if (showSkip)
            Positioned(
              top: MediaQuery.of(context).padding.top + 12,
              right: 16,
              child: GestureDetector(
                onTap: onEnter,
                child: Text(
                  'Skip \u2192',
                  style: AppTypography.labelMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.6),
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

// ═══════════════════════════════════════════════════════════════════════════
// MIST BACKGROUND — soft drifting blobs
// ═══════════════════════════════════════════════════════════════════════════

class _MistBackground extends StatefulWidget {
  const _MistBackground();

  @override
  State<_MistBackground> createState() => _MistBackgroundState();
}

class _MistBackgroundState extends State<_MistBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _MistPainter(progress: _ctrl.value),
        );
      },
    );
  }
}

class _MistPainter extends CustomPainter {
  _MistPainter({required this.progress});
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40);

    for (var i = 0; i < 8; i++) {
      final baseX = rng.nextDouble() * size.width;
      final baseY = size.height * (0.3 + rng.nextDouble() * 0.5);
      final dx = sin(progress * pi * 2 + i * 0.8) * 30;
      final dy = cos(progress * pi * 2 + i * 1.2) * 15;
      final opacity = (sin(progress * pi * 4 + i) * 0.02 + 0.03).clamp(0.01, 0.06);

      paint.color = Color.fromRGBO(200, 210, 200, opacity);
      canvas.drawCircle(
        Offset(baseX + dx, baseY + dy),
        50 + rng.nextDouble() * 40,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MistPainter o) => true;
}

// ═══════════════════════════════════════════════════════════════════════════
// FOREST HORIZON — perspective tree silhouettes toward luminous horizon
// ═══════════════════════════════════════════════════════════════════════════

class _ForestHorizon extends StatelessWidget {
  const _ForestHorizon();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _ForestPainter(),
    );
  }
}

class _ForestPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final horizonY = size.height * 0.55;

    // Luminous horizon glow
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()
        ..shader = RadialGradient(
          center: Alignment(0.0, -0.2),
          radius: 0.8,
          colors: [
            const Color(0xFF1A4D2E).withValues(alpha: 0.3),
            _bgColor,
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Horizon light band
    canvas.drawRect(
      Rect.fromLTWH(0, horizonY - 15, size.width, 30),
      Paint()
        ..color = AppColors.gardenCelestial.withValues(alpha: 0.06)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15),
    );

    // Tree rows — closer rows larger, distant rows smaller
    final rng = Random(7);
    final treePaint = Paint()..style = PaintingStyle.fill;

    for (var row = 0; row < 6; row++) {
      final depth = row / 5.0; // 0 = closest, 1 = furthest
      final rowY = horizonY + (1.0 - depth) * size.height * 0.35;
      final treeH = 15 + (1.0 - depth) * 40;
      final treeW = 6 + (1.0 - depth) * 14;
      final count = 8 + row * 3;
      final alpha = (0.15 + depth * 0.1).clamp(0.0, 0.3);

      treePaint.color = Color.fromRGBO(20, 60, 30, alpha);

      for (var i = 0; i < count; i++) {
        final x = (size.width / count) * i + rng.nextDouble() * 20;

        // Simple triangle tree
        final path = Path()
          ..moveTo(x, rowY)
          ..lineTo(x - treeW / 2, rowY + treeH)
          ..lineTo(x + treeW / 2, rowY + treeH)
          ..close();
        canvas.drawPath(path, treePaint);
      }
    }
  }

  @override
  bool shouldRepaint(_ForestPainter oldDelegate) => false;
}
