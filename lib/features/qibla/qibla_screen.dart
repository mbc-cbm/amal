import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/prayer_provider.dart';
import '../../shared/widgets/amal_logo.dart';

// ── Kaaba coordinates ──────────────────────────────────────────────────────
const double _kaabaLat = 21.4225;
const double _kaabaLng = 39.8262;

// ── Qibla bearing calculation ──────────────────────────────────────────────

/// Returns the Qibla bearing in degrees (0-360) from the given coordinates.
double _calculateQiblaBearing(double userLat, double userLng) {
  final lat1 = userLat * pi / 180;
  final lat2 = _kaabaLat * pi / 180;
  final dLng = (_kaabaLng - userLng) * pi / 180;

  final y = sin(dLng) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLng);
  final bearing = atan2(y, x) * 180 / pi;
  return (bearing + 360) % 360;
}

// ── Screen ─────────────────────────────────────────────────────────────────

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with SingleTickerProviderStateMixin {
  StreamSubscription<CompassEvent>? _compassSub;
  double _heading = 0;
  double _animatedAngle = 0;
  bool _needsCalibration = false;

  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _startCompass();
  }

  void _startCompass() {
    _compassSub = FlutterCompass.events?.listen((event) {
      if (!mounted) return;
      final heading = event.heading ?? 0;
      final accuracy = event.accuracy ?? 0;

      setState(() {
        _heading = heading;
        // accuracy < 15 degrees is considered low on many devices
        _needsCalibration = accuracy != 0 && accuracy < 15;
      });
    });
  }

  @override
  void dispose() {
    _compassSub?.cancel();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final positionAsync = ref.watch(currentPositionProvider);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          l10n.qibla,
          style: AppTypography.titleLarge.copyWith(color: colorScheme.onSurface),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      body: positionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _buildLocationError(l10n, colorScheme),
        data: (position) {
          if (position == null) {
            return _buildLocationError(l10n, colorScheme);
          }
          return _buildCompass(context, position, l10n, colorScheme, isDark);
        },
      ),
    );
  }

  Widget _buildLocationError(AppLocalizations l10n, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_off_rounded,
              size: AppSpacing.xxxl,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              l10n.qiblaPermissionNeeded,
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: () => Geolocator.openLocationSettings(),
              icon: const Icon(Icons.settings_rounded),
              label: Text(l10n.qiblaOpenSettings),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompass(
    BuildContext context,
    Position position,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final qiblaBearing = _calculateQiblaBearing(
      position.latitude,
      position.longitude,
    );

    // Angle to rotate the compass rose so Qibla points to the top.
    // The compass rose rotates by -heading so north is up, then we
    // additionally offset by qiblaBearing. Combined: -(heading - qiblaBearing).
    final rotationDeg = -(_heading - qiblaBearing);
    final rotationRad = rotationDeg * pi / 180;

    // Smoothly interpolated angle for the compass.
    _animatedAngle = _lerpAngle(_animatedAngle, rotationRad);

    final screenWidth = MediaQuery.of(context).size.width;
    final compassSize = screenWidth * 0.82;

    return Column(
      children: [
        // ── Calibration banner ──────────────────────────────────────────
        if (_needsCalibration)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            color: AppColors.warning.withValues(alpha: 0.15),
            child: Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.warning,
                  size: AppSpacing.iconMd,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.qiblaCalibrationPrompt,
                    style: AppTypography.bodySmall.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),

        const Spacer(),

        // ── Kaaba icon (fixed, does NOT rotate) ────────────────────────
        Icon(
          Icons.mosque_rounded,
          size: AppSpacing.iconXl,
          color: AppColors.primaryGold,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.qiblaKaabaLabel,
          style: AppTypography.labelMedium.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),

        // ── Compass + Amal logo stack ──────────────────────────────────
        SizedBox(
          width: compassSize,
          height: compassSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating compass rose
              TweenAnimationBuilder<double>(
                tween: _AngleTween(end: rotationRad),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                builder: (context, angle, child) {
                  return Transform.rotate(
                    angle: angle,
                    child: CustomPaint(
                      size: Size(compassSize, compassSize),
                      painter: _CompassPainter(
                        isDark: isDark,
                        primaryGreen: AppColors.primaryGreen,
                        primaryGold: AppColors.primaryGold,
                        onSurface: colorScheme.onSurface,
                        onSurfaceVariant: colorScheme.onSurfaceVariant,
                        surface: colorScheme.surface,
                      ),
                    ),
                  );
                },
              ),

              // Fixed Amal logo in center (does NOT rotate)
              const AmalLogo(size: 56),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // ── Bearing readout ────────────────────────────────────────────
        Text(
          '${qiblaBearing.toStringAsFixed(1)}\u00B0',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.primaryGreen,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          l10n.qiblaBearingLabel,
          style: AppTypography.bodySmall.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),

        const Spacer(),
      ],
    );
  }

  /// Interpolates between two radian angles along the shortest arc.
  double _lerpAngle(double from, double to) {
    var diff = (to - from) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;
    return from + diff * 0.3;
  }
}

// ── Angle Tween that wraps around 2*pi correctly ───────────────────────────

class _AngleTween extends Tween<double> {
  _AngleTween({required double end}) : super(end: end);

  double? _previousEnd;

  @override
  double lerp(double t) {
    final b = end ?? 0;
    final a = begin ?? b;

    var diff = (b - a) % (2 * pi);
    if (diff > pi) diff -= 2 * pi;
    if (diff < -pi) diff += 2 * pi;

    return a + diff * t;
  }

  @override
  set end(double? value) {
    if (_previousEnd != null && value != null) {
      begin = _previousEnd;
    }
    _previousEnd = value;
    super.end = value;
  }
}

// ── Compass CustomPainter ──────────────────────────────────────────────────

class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.isDark,
    required this.primaryGreen,
    required this.primaryGold,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surface,
  });

  final bool isDark;
  final Color primaryGreen;
  final Color primaryGold;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surface;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    _drawOuterRing(canvas, center, radius);
    _drawTickMarks(canvas, center, radius);
    _drawCardinalLabels(canvas, center, radius);
    _drawQiblaArrow(canvas, center, radius);
  }

  void _drawOuterRing(Canvas canvas, Offset center, double radius) {
    // Subtle gradient background circle
    final bgPaint = Paint()
      ..shader = RadialGradient(
        colors: isDark
            ? [
                AppColors.surfaceVariantDark,
                AppColors.surfaceDark,
              ]
            : [
                AppColors.surfaceVariantLight,
                AppColors.surfaceLight,
              ],
        stops: const [0.0, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, bgPaint);

    // Outer ring
    final ringPaint = Paint()
      ..color = primaryGreen.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawCircle(center, radius - 2, ringPaint);

    // Inner ring
    final innerRingPaint = Paint()
      ..color = primaryGreen.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, radius * 0.78, innerRingPaint);
  }

  void _drawTickMarks(Canvas canvas, Offset center, double radius) {
    final majorTickPaint = Paint()
      ..color = onSurface.withValues(alpha: 0.6)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final minorTickPaint = Paint()
      ..color = onSurfaceVariant.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 360; i += 5) {
      final angle = i * pi / 180 - pi / 2; // -90 so 0 is at top
      final isMajor = i % 30 == 0;
      final isMedium = i % 15 == 0;

      final outerR = radius - 6;
      double innerR;
      if (isMajor) {
        innerR = radius - 22;
      } else if (isMedium) {
        innerR = radius - 16;
      } else {
        innerR = radius - 12;
      }

      final outerPoint = Offset(
        center.dx + outerR * cos(angle),
        center.dy + outerR * sin(angle),
      );
      final innerPoint = Offset(
        center.dx + innerR * cos(angle),
        center.dy + innerR * sin(angle),
      );

      canvas.drawLine(
        innerPoint,
        outerPoint,
        isMajor ? majorTickPaint : minorTickPaint,
      );

      // Draw degree numbers at 30-degree intervals (except cardinals)
      if (isMajor && i % 90 != 0) {
        final textR = radius - 32;
        final textOffset = Offset(
          center.dx + textR * cos(angle),
          center.dy + textR * sin(angle),
        );
        _drawText(
          canvas,
          '$i\u00B0',
          textOffset,
          onSurfaceVariant.withValues(alpha: 0.5),
          9,
        );
      }
    }
  }

  void _drawCardinalLabels(Canvas canvas, Offset center, double radius) {
    final labelRadius = radius - 36;

    // Cardinals: N at top, E at right, S at bottom, W at left
    // (before rotation, 0 deg = north = top)
    final cardinals = [
      (label: 'N', angle: -pi / 2, color: primaryGreen),
      (label: 'E', angle: 0.0, color: onSurface.withValues(alpha: 0.7)),
      (label: 'S', angle: pi / 2, color: onSurface.withValues(alpha: 0.7)),
      (label: 'W', angle: pi, color: onSurface.withValues(alpha: 0.7)),
    ];

    for (final c in cardinals) {
      final offset = Offset(
        center.dx + labelRadius * cos(c.angle),
        center.dy + labelRadius * sin(c.angle),
      );
      _drawText(canvas, c.label, offset, c.color, 16, bold: true);
    }
  }

  void _drawQiblaArrow(Canvas canvas, Offset center, double radius) {
    // The Qibla direction is at the TOP (angle = -pi/2) because the whole
    // compass rose is rotated so Qibla faces up.
    final arrowLength = radius * 0.62;
    const arrowAngle = -pi / 2; // top

    // Arrow shaft
    final shaftPaint = Paint()
      ..color = primaryGreen
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final tipPoint = Offset(
      center.dx + arrowLength * cos(arrowAngle),
      center.dy + arrowLength * sin(arrowAngle),
    );

    canvas.drawLine(center, tipPoint, shaftPaint);

    // Arrowhead
    final headPath = Path();
    const headSize = 14.0;
    headPath.moveTo(tipPoint.dx, tipPoint.dy);
    headPath.lineTo(
      tipPoint.dx - headSize * cos(arrowAngle - 0.4),
      tipPoint.dy - headSize * sin(arrowAngle - 0.4),
    );
    headPath.lineTo(
      tipPoint.dx - headSize * cos(arrowAngle + 0.4),
      tipPoint.dy - headSize * sin(arrowAngle + 0.4),
    );
    headPath.close();

    final headPaint = Paint()..color = primaryGreen;
    canvas.drawPath(headPath, headPaint);

    // Small gold circle at center
    final dotPaint = Paint()..color = primaryGold;
    canvas.drawCircle(center, 6, dotPaint);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position,
    Color color,
    double fontSize, {
    bool bold = false,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          fontFamily: 'Roboto',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        position.dx - textPainter.width / 2,
        position.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
