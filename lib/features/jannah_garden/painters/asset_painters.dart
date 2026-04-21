import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../../../core/constants/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// BASE — All asset painters share these parameters
// ═══════════════════════════════════════════════════════════════════════════

/// Health state 1 = pristine, 5 = withered.
/// [glowIntensity] 0.0-1.0 for Sacred Centre ground glow.
/// [animationValue] 0.0-1.0 cycled by the game loop for idle animations.
double _healthSaturation(int healthState) => switch (healthState) {
      1 => 1.0,
      2 => 0.85,
      3 => 0.65,
      4 => 0.40,
      _ => 0.15,
    };

Color _healthAdjust(Color c, int healthState) {
  final sat = _healthSaturation(healthState);
  if (sat >= 1.0) return c;
  final grey = Color.fromRGBO(160, 160, 160, 1.0);
  return Color.lerp(c, grey, 1.0 - sat)!;
}

void _drawGlowBase(Canvas canvas, Size size, double glowIntensity) {
  if (glowIntensity <= 0) return;
  canvas.drawCircle(
    Offset(size.width / 2, size.height * 0.85),
    size.width * 0.4,
    Paint()
      ..color = AppColors.gardenGoldGlow.withValues(alpha: glowIntensity * 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// [1] SIDRA PAINTER — Sidrat al-Muntaha (Quran 53:14)
// ═══════════════════════════════════════════════════════════════════════════

class SidraPainter extends CustomPainter {
  SidraPainter({
    this.healthState = 1,
    this.glowIntensity = 0.0,
    this.animationValue = 0.0,
  });

  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);

    final cx = size.width / 2;
    final baseY = size.height * 0.88;
    final h = _healthAdjust;

    // Background aura
    canvas.drawCircle(
      Offset(cx, size.height * 0.4),
      size.width * 0.45,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, size.height * 0.4),
          size.width * 0.45,
          [
            h(AppColors.gardenGoldGlow, healthState).withValues(alpha: 0.25),
            h(AppColors.gardenGoldGlow, healthState).withValues(alpha: 0.0),
          ],
        ),
    );

    // Trunk — deep pearl-gold, translucent
    final trunkW = size.width * 0.08;
    final trunkTop = size.height * 0.35;
    final trunkPath = Path()
      ..moveTo(cx - trunkW, baseY)
      ..lineTo(cx - trunkW * 0.6, trunkTop)
      ..lineTo(cx + trunkW * 0.6, trunkTop)
      ..lineTo(cx + trunkW, baseY)
      ..close();
    canvas.drawPath(
      trunkPath,
      Paint()..color = h(AppColors.gardenPearl, healthState).withValues(alpha: 0.8),
    );

    // Branches — luminescent white-gold
    final rng = Random(42);
    final branchPaint = Paint()
      ..color = h(AppColors.gardenGoldGlow, healthState).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final angle = -pi / 2 + (i - 3.5) * 0.3;
      final sway = sin(animationValue * pi * 2 + i) * 3;
      final length = size.width * (0.25 + rng.nextDouble() * 0.15);
      final startY = trunkTop + size.height * 0.05 * (i % 3);

      final endX = cx + cos(angle) * length + sway;
      final endY = startY + sin(angle) * length * 0.3;

      final path = Path()
        ..moveTo(cx, startY)
        ..quadraticBezierTo(
          cx + cos(angle) * length * 0.5,
          startY + sin(angle) * length * 0.15 - 8,
          endX,
          endY,
        );
      canvas.drawPath(path, branchPaint);

      // Leaf clusters at tips
      canvas.drawCircle(
        Offset(endX, endY),
        4 + rng.nextDouble() * 3,
        Paint()
          ..color = h(AppColors.gardenLeafLight, healthState).withValues(alpha: 0.6)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Fruit orbs at some branch tips
      if (i.isEven) {
        canvas.drawCircle(
          Offset(endX - 2, endY + 3),
          3,
          Paint()
            ..color = h(AppColors.gardenGoldGlow, healthState).withValues(alpha: 0.8),
        );
      }
    }

    // Halo ring above canopy
    canvas.drawCircle(
      Offset(cx, trunkTop - 10),
      size.width * 0.3,
      Paint()
        ..color = h(AppColors.gardenCelestial, healthState).withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
  }

  @override
  bool shouldRepaint(SidraPainter o) =>
      o.healthState != healthState ||
      o.glowIntensity != glowIntensity ||
      o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [2] PALM TREE PAINTER — Date Palm, Olive, Fig (Quran 55:68, 24:35, 95:1)
// ═══════════════════════════════════════════════════════════════════════════

class PalmTreePainter extends CustomPainter {
  PalmTreePainter({
    this.healthState = 1,
    this.glowIntensity = 0.0,
    this.animationValue = 0.0,
    this.fruitColor = AppColors.gardenAmber,
    this.leafColor = AppColors.gardenLeafDark,
  });

  final int healthState;
  final double glowIntensity;
  final double animationValue;
  final Color fruitColor;
  final Color leafColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);

    final cx = size.width / 2;
    final baseY = size.height * 0.9;
    final crownY = size.height * 0.3;
    final h = _healthAdjust;

    // Trunk — warm brown with texture
    final trunkW = size.width * 0.07;
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(cx, (baseY + crownY) / 2),
        width: trunkW * 2,
        height: baseY - crownY,
      ),
      Paint()..color = h(AppColors.gardenTrunkBrown, healthState),
    );

    // Cross-hatch trunk texture
    final texturePaint = Paint()
      ..color = h(AppColors.gardenTrunkDark, healthState).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (var y = crownY; y < baseY; y += 6) {
      canvas.drawLine(
        Offset(cx - trunkW, y), Offset(cx + trunkW, y), texturePaint);
    }

    // Fronds — 8 curved paths
    final frondPaint = Paint()
      ..color = h(leafColor, healthState)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    for (var i = 0; i < 8; i++) {
      final angle = (i / 8) * pi * 2;
      final sway = sin(animationValue * pi * 2 + i * 0.8) * 4;
      final length = size.width * 0.35;

      final endX = cx + cos(angle) * length + sway;
      final endY = crownY + sin(angle) * length * 0.4 - 5;
      final ctrlX = cx + cos(angle) * length * 0.6;
      final ctrlY = crownY + sin(angle) * length * 0.15 - 12;

      final path = Path()
        ..moveTo(cx, crownY)
        ..quadraticBezierTo(ctrlX, ctrlY, endX, endY);
      canvas.drawPath(path, frondPaint);

      // Leaf pairs along frond
      final leafPaint = Paint()
        ..color = h(leafColor, healthState).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      for (var l = 0.3; l < 0.9; l += 0.15) {
        final lx = cx + (endX - cx) * l;
        final ly = crownY + (endY - crownY) * l;
        final side = l.hashCode.isEven ? 1.0 : -1.0;
        canvas.drawLine(
          Offset(lx, ly),
          Offset(lx + cos(angle + side * 1.2) * 5,
                 ly + sin(angle + side * 1.2) * 4),
          leafPaint,
        );
      }
    }

    // Fruit clusters at crown base
    for (var i = 0; i < 5; i++) {
      final fx = cx + (i - 2) * 6.0;
      final fy = crownY + 4 + (i % 2) * 3;
      canvas.drawCircle(
        Offset(fx, fy),
        2.5,
        Paint()..color = h(fruitColor, healthState),
      );
    }
  }

  @override
  bool shouldRepaint(PalmTreePainter o) =>
      o.healthState != healthState ||
      o.animationValue != animationValue ||
      o.glowIntensity != glowIntensity;
}

// ═══════════════════════════════════════════════════════════════════════════
// [3] GRAPE CANOPY PAINTER (Quran 56:29)
// ═══════════════════════════════════════════════════════════════════════════

class GrapeCanopyPainter extends CustomPainter {
  GrapeCanopyPainter({
    this.healthState = 1,
    this.glowIntensity = 0.0,
    this.animationValue = 0.0,
  });

  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);

    final h = _healthAdjust;
    final canopyTop = size.height * 0.1;
    final canopyBottom = size.height * 0.35;

    // Lattice frame
    final framePaint = Paint()
      ..color = h(AppColors.gardenTrunkBrown, healthState)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var x = 0.1; x < 0.95; x += 0.2) {
      canvas.drawLine(
        Offset(size.width * x, canopyTop),
        Offset(size.width * x, canopyBottom),
        framePaint,
      );
    }
    for (var y = canopyTop; y <= canopyBottom; y += (canopyBottom - canopyTop) / 3) {
      canvas.drawLine(
        Offset(size.width * 0.05, y),
        Offset(size.width * 0.95, y),
        framePaint,
      );
    }

    // Vine leaves
    final leafPaint = Paint()
      ..color = h(AppColors.gardenLeafDark, healthState).withValues(alpha: 0.6);
    final rng = Random(7);
    for (var i = 0; i < 10; i++) {
      final lx = size.width * (0.1 + rng.nextDouble() * 0.8);
      final ly = canopyTop + rng.nextDouble() * (canopyBottom - canopyTop);
      _drawVineLeaf(canvas, Offset(lx, ly), 6, leafPaint);
    }

    // Grape bunches hanging below canopy
    for (var i = 0; i < 7; i++) {
      final bx = size.width * (0.12 + i * 0.12);
      final by = canopyBottom + 8 + sin(animationValue * pi * 2 + i) * 3;
      _drawGrapeBunch(canvas, Offset(bx, by), h, healthState);
    }

    // Light shimmer through canopy
    final shimmer = (sin(animationValue * pi * 4) * 0.5 + 0.5);
    canvas.drawRect(
      Rect.fromLTWH(0, canopyTop, size.width, canopyBottom - canopyTop),
      Paint()
        ..color = h(AppColors.gardenCelestial, healthState)
            .withValues(alpha: 0.04 + shimmer * 0.04),
    );
  }

  void _drawVineLeaf(Canvas canvas, Offset pos, double size, Paint paint) {
    final path = Path()
      ..moveTo(pos.dx, pos.dy - size)
      ..quadraticBezierTo(pos.dx + size, pos.dy - size * 0.5, pos.dx + size * 0.5, pos.dy + size * 0.3)
      ..quadraticBezierTo(pos.dx, pos.dy + size * 0.5, pos.dx - size * 0.5, pos.dy + size * 0.3)
      ..quadraticBezierTo(pos.dx - size, pos.dy - size * 0.5, pos.dx, pos.dy - size);
    canvas.drawPath(path, paint);
  }

  void _drawGrapeBunch(Canvas canvas, Offset pos, Color Function(Color, int) h, int hs) {
    final grape = Paint()..color = h(const Color(0xFF7B1FA2), hs).withValues(alpha: 0.7);
    for (var r = 0; r < 3; r++) {
      for (var c = 0; c < (3 - r); c++) {
        canvas.drawCircle(
          Offset(pos.dx + (c - (2 - r) * 0.5) * 5, pos.dy + r * 4.5),
          2.5,
          grape,
        );
      }
    }
  }

  @override
  bool shouldRepaint(GrapeCanopyPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [4] KAWTHAR RIVER PAINTER (Quran 108:1)
// ═══════════════════════════════════════════════════════════════════════════

class KawtharPainter extends CustomPainter {
  KawtharPainter({
    this.healthState = 1,
    this.glowIntensity = 0.0,
    this.animationValue = 0.0,
  });

  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);

    final h = _healthAdjust;
    final riverY = size.height * 0.5;
    final riverH = size.height * 0.3;

    // Luminous white-silver water
    for (var i = 0; i < 4; i++) {
      final phase = animationValue * pi * 2 + i * 0.4;
      final path = Path();
      for (var x = 0.0; x <= size.width; x += 2) {
        final y = riverY + sin(x / 20 + phase) * (4 + i * 2) + i * 3;
        if (x == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = h(AppColors.gardenIvory, healthState)
              .withValues(alpha: 0.4 - i * 0.08)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0 - i * 0.5
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // Gold-rimmed stones on banks
    final stonePaint = Paint()..color = h(AppColors.gardenAmber, healthState).withValues(alpha: 0.5);
    final rng = Random(12);
    for (var i = 0; i < 6; i++) {
      final sx = rng.nextDouble() * size.width;
      final sy = (i < 3 ? riverY - riverH * 0.3 : riverY + riverH * 0.5) + rng.nextDouble() * 5;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(sx, sy), width: 6, height: 4),
        stonePaint,
      );
    }

    // Fish of light (animated dots)
    for (var i = 0; i < 4; i++) {
      final fishX = (size.width * (0.1 + i * 0.25) + animationValue * size.width * 0.3 + i * 30) % size.width;
      final fishY = riverY + sin(animationValue * pi * 3 + i * 2) * 6;
      canvas.drawCircle(
        Offset(fishX, fishY),
        2,
        Paint()
          ..color = h(AppColors.gardenCelestial, healthState).withValues(alpha: 0.7)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // Mist rising
    for (var i = 0; i < 5; i++) {
      final mx = size.width * (0.15 + i * 0.18);
      final my = riverY - 10 - (animationValue * 15 + i * 4) % 20;
      canvas.drawCircle(
        Offset(mx, my),
        5 + i.toDouble(),
        Paint()
          ..color = h(AppColors.gardenIvory, healthState).withValues(alpha: 0.08)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  @override
  bool shouldRepaint(KawtharPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [5] MILK RIVER PAINTER (Quran 47:15)
// ═══════════════════════════════════════════════════════════════════════════

class MilkRiverPainter extends CustomPainter {
  MilkRiverPainter({this.healthState = 1, this.glowIntensity = 0.0, this.animationValue = 0.0});

  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final riverY = size.height * 0.5;

    // Pearl-white creamy water — wider, slower strokes
    for (var i = 0; i < 5; i++) {
      final phase = animationValue * pi + i * 0.3;
      final path = Path();
      for (var x = 0.0; x <= size.width; x += 3) {
        final y = riverY + sin(x / 30 + phase) * (3 + i) + i * 2;
        if (x == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      canvas.drawPath(path, Paint()
        ..color = h(AppColors.gardenMilk, healthState).withValues(alpha: 0.5 - i * 0.08)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 - i * 0.6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // Cream foam at edges
    for (var i = 0; i < 8; i++) {
      final fx = size.width * (i / 8.0 + 0.05);
      canvas.drawCircle(
        Offset(fx, riverY + 12),
        3, Paint()..color = h(AppColors.gardenPearl, healthState).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }

    // Warm under-glow
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width / 2, riverY), width: size.width, height: 20),
      Paint()..color = h(AppColors.gardenCelestial, healthState).withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
  }

  @override
  bool shouldRepaint(MilkRiverPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [6] HONEY RIVER PAINTER (Quran 47:15)
// ═══════════════════════════════════════════════════════════════════════════

class HoneyRiverPainter extends CustomPainter {
  HoneyRiverPainter({this.healthState = 1, this.glowIntensity = 0.0, this.animationValue = 0.0});
  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final riverY = size.height * 0.5;

    // Deep amber-gold thick flowing water
    for (var i = 0; i < 6; i++) {
      final phase = animationValue * pi * 0.8 + i * 0.25;
      final path = Path();
      for (var x = 0.0; x <= size.width; x += 4) {
        final y = riverY + sin(x / 35 + phase) * (2 + i) + i * 1.5;
        if (x == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      canvas.drawPath(path, Paint()
        ..color = h(AppColors.gardenHoney, healthState).withValues(alpha: 0.45 - i * 0.06)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0 - i * 0.6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    }

    // Honey drip effects at edges
    final rng = Random(9);
    for (var i = 0; i < 5; i++) {
      final dx = size.width * (0.1 + rng.nextDouble() * 0.8);
      final dy = riverY + 14 + sin(animationValue * pi * 2 + i) * 3;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(dx, dy), width: 4, height: 6),
        Paint()..color = h(AppColors.gardenHoney, healthState).withValues(alpha: 0.5));
    }

    // Golden self-glow
    canvas.drawRect(
      Rect.fromCenter(center: Offset(size.width / 2, riverY), width: size.width, height: 24),
      Paint()..color = h(AppColors.gardenGoldGlow, healthState).withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
  }

  @override
  bool shouldRepaint(HoneyRiverPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [7] MOSQUE PAINTER — Grand + Small (Pearl and Gold)
// ═══════════════════════════════════════════════════════════════════════════

class MosquePainter extends CustomPainter {
  MosquePainter({
    this.healthState = 1,
    this.glowIntensity = 0.0,
    this.animationValue = 0.0,
    this.isSacred = false,
  });
  final int healthState;
  final double glowIntensity;
  final double animationValue;
  final bool isSacred;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final cx = size.width / 2;
    final baseY = size.height * 0.88;

    // Sacred version pearl radiance
    if (isSacred) {
      canvas.drawCircle(
        Offset(cx, size.height * 0.4),
        size.width * 0.4,
        Paint()..color = h(AppColors.gardenPearl, healthState).withValues(alpha: 0.1)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16));
    }

    // Main building body
    final bodyRect = Rect.fromLTRB(
      size.width * 0.2, size.height * 0.45, size.width * 0.8, baseY);
    canvas.drawRect(bodyRect,
      Paint()..color = h(AppColors.gardenPearl, healthState).withValues(alpha: 0.9));

    // Main dome
    final domeR = size.width * (isSacred ? 0.22 : 0.18);
    final domeY = size.height * 0.42;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, domeY), width: domeR * 2, height: domeR * 2),
      pi, pi, true,
      Paint()..shader = ui.Gradient.linear(
        Offset(cx - domeR, domeY - domeR),
        Offset(cx + domeR, domeY),
        [h(AppColors.gardenIvory, healthState), h(AppColors.gardenGoldGlow, healthState)],
      ));

    // Gold crescent at dome top
    canvas.drawCircle(Offset(cx, domeY - domeR + 2), 3,
      Paint()..color = h(AppColors.noorGold, healthState));

    // Minarets
    final minaretPositions = isSacred
        ? [0.15, 0.35, 0.65, 0.85]
        : [0.22, 0.78];
    for (final mx in minaretPositions) {
      final mh = isSacred ? size.height * 0.55 : size.height * 0.48;
      final mw = size.width * 0.04;
      final mTop = baseY - mh;
      canvas.drawRect(
        Rect.fromLTWH(size.width * mx - mw / 2, mTop, mw, mh),
        Paint()..color = h(AppColors.gardenPearl, healthState));
      // Gold rim
      canvas.drawRect(
        Rect.fromLTWH(size.width * mx - mw / 2, mTop, mw, 3),
        Paint()..color = h(AppColors.noorGold, healthState));
      // Crescent at tip
      canvas.drawCircle(Offset(size.width * mx, mTop - 3), 2,
        Paint()..color = h(AppColors.noorGold, healthState));
    }

    // Arched windows with interior glow
    for (var i = 0; i < 3; i++) {
      final wx = size.width * (0.3 + i * 0.15);
      final wy = size.height * 0.58;
      final ww = size.width * 0.08;
      final wh = size.height * 0.12;

      // Glow inside
      canvas.drawOval(
        Rect.fromCenter(center: Offset(wx, wy), width: ww, height: wh),
        Paint()..color = h(AppColors.gardenCelestial, healthState).withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));

      // Arch outline
      canvas.drawOval(
        Rect.fromCenter(center: Offset(wx, wy), width: ww, height: wh),
        Paint()..color = h(AppColors.noorGold, healthState).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(MosquePainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [8] PEACOCK PAINTER (White Peacock — Premium)
// ═══════════════════════════════════════════════════════════════════════════

class PeacockPainter extends CustomPainter {
  PeacockPainter({this.healthState = 1, this.glowIntensity = 0.0, this.animationValue = 0.0});
  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final cx = size.width / 2;
    final bodyY = size.height * 0.65;

    // Tail fan — 12 feathers spread behind
    final tailColors = [
      AppColors.gardenTeal, AppColors.gardenGoldGlow,
      AppColors.gardenPurpleIridescent, AppColors.gardenEmerald,
    ];
    for (var i = 0; i < 12; i++) {
      final angle = -pi * 0.8 + (i / 11) * pi * 0.6;
      final sway = sin(animationValue * pi * 2 + i * 0.3) * 0.03;
      final featherLen = size.height * 0.45;
      final endX = cx + cos(angle + sway) * featherLen;
      final endY = bodyY - 5 + sin(angle + sway) * featherLen * 0.5;

      canvas.drawLine(
        Offset(cx, bodyY - 5),
        Offset(endX, endY),
        Paint()..color = h(AppColors.gardenPearl, healthState).withValues(alpha: 0.4)
          ..strokeWidth = 1..style = PaintingStyle.stroke);

      // Eye at tip
      final eyeColor = tailColors[i % tailColors.length];
      canvas.drawCircle(Offset(endX, endY), 4,
        Paint()..color = h(eyeColor, healthState).withValues(alpha: 0.6));
      canvas.drawCircle(Offset(endX, endY), 2,
        Paint()..color = h(AppColors.gardenCelestial, healthState));
    }

    // Body — white oval with pearl shimmer
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, bodyY), width: size.width * 0.25, height: size.height * 0.15),
      Paint()..color = h(AppColors.gardenPearl, healthState).withValues(alpha: 0.9));

    // Head
    canvas.drawCircle(Offset(cx + 8, bodyY - size.height * 0.1), 5,
      Paint()..color = h(AppColors.white, healthState));
    // Beak
    canvas.drawLine(
      Offset(cx + 13, bodyY - size.height * 0.1),
      Offset(cx + 17, bodyY - size.height * 0.09),
      Paint()..color = h(AppColors.gardenAmber, healthState)..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(PeacockPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [9] BUTTERFLIES PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class ButterfliesPainter extends CustomPainter {
  ButterfliesPainter({this.healthState = 1, this.glowIntensity = 0.0, this.animationValue = 0.0});
  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final rng = Random(17);

    for (var i = 0; i < 7; i++) {
      final baseCx = size.width * (0.1 + rng.nextDouble() * 0.8);
      final baseCy = size.height * (0.15 + rng.nextDouble() * 0.6);
      final t = animationValue + i * 0.14;

      // Figure-8 path
      final x = baseCx + sin(t * pi * 2) * 10;
      final y = baseCy + sin(t * pi * 4) * 6;
      final wingFlap = sin(t * pi * 12 + i) * 0.5 + 0.5; // 0-1

      final wingColor = h(AppColors.gardenGoldGlow, healthState).withValues(alpha: 0.5);

      canvas.save();
      canvas.translate(x, y);

      // Left wing
      canvas.save();
      canvas.scale(wingFlap * 0.5 + 0.5, 1);
      final leftWing = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(-8, -6, -5, -10)
        ..quadraticBezierTo(-1, -7, 0, 0);
      canvas.drawPath(leftWing, Paint()..color = wingColor);
      canvas.restore();

      // Right wing
      canvas.save();
      canvas.scale(wingFlap * 0.5 + 0.5, 1);
      final rightWing = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(8, -6, 5, -10)
        ..quadraticBezierTo(1, -7, 0, 0);
      canvas.drawPath(rightWing, Paint()..color = wingColor);
      canvas.restore();

      // Body
      canvas.drawLine(Offset(0, -2), Offset(0, 3),
        Paint()..color = h(AppColors.gardenTrunkBrown, healthState)..strokeWidth = 1);

      // Sparkle trail
      canvas.drawCircle(Offset(-3, 4), 1.5,
        Paint()..color = h(AppColors.gardenGoldGlow, healthState).withValues(alpha: 0.3)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(ButterfliesPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [10] WATERFALL PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class WaterfallPainter extends CustomPainter {
  WaterfallPainter({this.healthState = 1, this.glowIntensity = 0.0, this.animationValue = 0.0});
  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final cx = size.width / 2;
    final fallTop = size.height * 0.15;
    final fallBottom = size.height * 0.7;

    // Water column — animated sine paths
    for (var i = 0; i < 4; i++) {
      final path = Path();
      final phase = animationValue * pi * 3 + i * 0.5;
      final xOff = (i - 1.5) * 4;
      for (var y = fallTop; y <= fallBottom; y += 2) {
        final x = cx + xOff + sin(y / 8 + phase) * (3 + i);
        if (y == fallTop) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      }
      canvas.drawPath(path, Paint()
        ..color = h(AppColors.gardenWaterGlow, healthState).withValues(alpha: 0.5 - i * 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 - i * 0.5
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    }

    // Mist pool at base
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, fallBottom + 8), width: size.width * 0.6, height: 16),
      Paint()..color = h(AppColors.gardenWaterGlow, healthState).withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));

    // Splash particles
    final rng = Random(3);
    for (var i = 0; i < 6; i++) {
      final sx = cx + (rng.nextDouble() - 0.5) * size.width * 0.4;
      final sy = fallBottom + 5 - (animationValue * 10 + i * 3) % 12;
      canvas.drawCircle(Offset(sx, sy), 1.5,
        Paint()..color = h(AppColors.gardenIvory, healthState).withValues(alpha: 0.4));
    }

    // Cliff/rock edges
    canvas.drawLine(
      Offset(cx - size.width * 0.2, fallTop), Offset(cx - size.width * 0.35, fallTop + 10),
      Paint()..color = h(AppColors.gardenTrunkDark, healthState).withValues(alpha: 0.5)
        ..strokeWidth = 2..strokeCap = StrokeCap.round);
    canvas.drawLine(
      Offset(cx + size.width * 0.2, fallTop), Offset(cx + size.width * 0.35, fallTop + 10),
      Paint()..color = h(AppColors.gardenTrunkDark, healthState).withValues(alpha: 0.5)
        ..strokeWidth = 2..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(WaterfallPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [11] FLOWER PAINTER — Rose, Jasmine, Lotus, Lily, Lavender
// ═══════════════════════════════════════════════════════════════════════════

enum FlowerType { rose, jasmine, lotus, lily, lavender, wildflower }

class FlowerPainter extends CustomPainter {
  FlowerPainter({
    this.flowerType = FlowerType.rose,
    this.healthState = 1,
    this.glowIntensity = 0.0,
    this.animationValue = 0.0,
  });

  final FlowerType flowerType;
  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final cx = size.width / 2;
    final baseY = size.height * 0.85;
    final h = _healthAdjust;
    final sway = sin(animationValue * pi * 2) * 2;

    // Stem
    canvas.drawLine(
      Offset(cx + sway * 0.3, baseY),
      Offset(cx + sway, size.height * 0.35),
      Paint()..color = h(AppColors.gardenLeafDark, healthState)
        ..strokeWidth = 2..strokeCap = StrokeCap.round);

    final flowerCx = cx + sway;
    final flowerCy = size.height * 0.3;

    // Glow around flower
    canvas.drawCircle(
      Offset(flowerCx, flowerCy), 10,
      Paint()..color = h(AppColors.gardenGoldGlow, healthState).withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));

    switch (flowerType) {
      case FlowerType.rose:
        _drawRose(canvas, flowerCx, flowerCy, h);
      case FlowerType.jasmine:
        _drawJasmine(canvas, flowerCx, flowerCy, h);
      case FlowerType.lotus:
        _drawLotus(canvas, size, flowerCx, flowerCy, h);
      case FlowerType.lily:
        _drawLily(canvas, flowerCx, flowerCy, h);
      case FlowerType.lavender:
        _drawLavender(canvas, size, cx, baseY, sway, h);
      case FlowerType.wildflower:
        _drawJasmine(canvas, flowerCx, flowerCy, h); // simplified
    }
  }

  void _drawRose(Canvas canvas, double cx, double cy, Color Function(Color, int) h) {
    // Tight spiral petals
    for (var ring = 0; ring < 3; ring++) {
      final r = 4.0 + ring * 3;
      for (var i = 0; i < 5 + ring * 2; i++) {
        final angle = (i / (5 + ring * 2)) * pi * 2 + ring * 0.3;
        final px = cx + cos(angle) * r;
        final py = cy + sin(angle) * r;
        canvas.drawOval(
          Rect.fromCenter(center: Offset(px, py), width: 4, height: 6),
          Paint()..color = h(AppColors.gardenRuby, healthState)
              .withValues(alpha: 0.7 - ring * 0.15));
      }
    }
    canvas.drawCircle(Offset(cx, cy), 2,
      Paint()..color = h(AppColors.gardenAmber, healthState));
  }

  void _drawJasmine(Canvas canvas, double cx, double cy, Color Function(Color, int) h) {
    for (var i = 0; i < 5; i++) {
      final angle = i * pi * 2 / 5 - pi / 2;
      final px = cx + cos(angle) * 7;
      final py = cy + sin(angle) * 7;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, py), width: 4, height: 8),
        Paint()..color = h(AppColors.white, healthState).withValues(alpha: 0.85));
    }
    canvas.drawCircle(Offset(cx, cy), 2.5,
      Paint()..color = h(AppColors.gardenGoldGlow, healthState));
  }

  void _drawLotus(Canvas canvas, Size size, double cx, double cy, Color Function(Color, int) h) {
    // Water circle beneath
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy + 8), width: 24, height: 8),
      Paint()..color = h(AppColors.gardenAquamarine, healthState).withValues(alpha: 0.3));

    // Broad rounded petals
    for (var i = 0; i < 6; i++) {
      final angle = i * pi / 3 - pi / 2;
      final px = cx + cos(angle) * 8;
      final py = cy + sin(angle) * 5;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(px, py), width: 7, height: 10),
        Paint()..color = Color.lerp(
          h(AppColors.white, healthState),
          h(const Color(0xFFE91E63), healthState), 0.3)!.withValues(alpha: 0.7));
    }
    canvas.drawCircle(Offset(cx, cy), 3,
      Paint()..color = h(AppColors.gardenAmber, healthState));
  }

  void _drawLily(Canvas canvas, double cx, double cy, Color Function(Color, int) h) {
    // Trumpet shape
    final path = Path()
      ..moveTo(cx, cy - 8)
      ..quadraticBezierTo(cx - 8, cy - 3, cx - 6, cy + 5)
      ..lineTo(cx + 6, cy + 5)
      ..quadraticBezierTo(cx + 8, cy - 3, cx, cy - 8);
    canvas.drawPath(path,
      Paint()..color = h(AppColors.gardenCelestial, healthState).withValues(alpha: 0.8));
    canvas.drawCircle(Offset(cx, cy), 2,
      Paint()..color = h(AppColors.gardenAmber, healthState));
  }

  void _drawLavender(Canvas canvas, Size size, double cx, double baseY, double sway, Color Function(Color, int) h) {
    // Tall spike with small purple dots
    for (var y = size.height * 0.2; y < size.height * 0.55; y += 4) {
      final x = cx + sway * (1.0 - y / size.height);
      canvas.drawCircle(Offset(x, y), 2,
        Paint()..color = h(AppColors.featureTasbeeh, healthState).withValues(alpha: 0.6));
    }
  }

  @override
  bool shouldRepaint(FlowerPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue || o.flowerType != flowerType;
}

// ═══════════════════════════════════════════════════════════════════════════
// [12] LANTERN PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class LanternPainter extends CustomPainter {
  LanternPainter({this.healthState = 1, this.glowIntensity = 0.0, this.animationValue = 0.0});
  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final lw = size.width * 0.25;
    final lh = size.height * 0.35;

    // Pulsing inner glow (1.5s cycle)
    final pulse = sin(animationValue * pi * 2 / 1.5) * 0.15 + 0.35;

    // Inner light fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: lw, height: lh),
        const Radius.circular(4)),
      Paint()..color = h(AppColors.gardenCelestial, healthState).withValues(alpha: pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6));

    // Gold frame
    final framePaint = Paint()
      ..color = h(AppColors.noorGold, healthState).withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: lw, height: lh),
        const Radius.circular(4)),
      framePaint);

    // Filigree cross-hatch inside
    final filigree = Paint()
      ..color = h(AppColors.noorGold, healthState).withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (var i = 0; i < 5; i++) {
      final y = cy - lh / 2 + lh * (i + 1) / 6;
      canvas.drawLine(Offset(cx - lw / 2, y), Offset(cx + lw / 2, y), filigree);
    }
    for (var i = 0; i < 3; i++) {
      final x = cx - lw / 2 + lw * (i + 1) / 4;
      canvas.drawLine(Offset(x, cy - lh / 2), Offset(x, cy + lh / 2), filigree);
    }

    // Top hook
    canvas.drawLine(Offset(cx, cy - lh / 2), Offset(cx, cy - lh / 2 - 6),
      Paint()..color = h(AppColors.noorGold, healthState)..strokeWidth = 1.5);
    canvas.drawCircle(Offset(cx, cy - lh / 2 - 7), 2,
      Paint()..color = h(AppColors.noorGold, healthState));
  }

  @override
  bool shouldRepaint(LanternPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [13] QASR PALACE PAINTER (22,000 NC Sacred)
// ═══════════════════════════════════════════════════════════════════════════

class QasrPalacePainter extends CustomPainter {
  QasrPalacePainter({this.healthState = 1, this.glowIntensity = 0.0, this.animationValue = 0.0});
  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final cx = size.width / 2;
    final baseY = size.height * 0.9;

    // White radiance
    canvas.drawCircle(Offset(cx, size.height * 0.45), size.width * 0.4,
      Paint()..color = h(AppColors.gardenPearl, healthState).withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20));

    // Main facade
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.1, size.height * 0.35, size.width * 0.9, baseY),
      Paint()..color = h(AppColors.gardenPearl, healthState).withValues(alpha: 0.85));

    // Gold trim border
    canvas.drawRect(
      Rect.fromLTRB(size.width * 0.1, size.height * 0.35, size.width * 0.9, baseY),
      Paint()..color = h(AppColors.noorGold, healthState).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke..strokeWidth = 1.5);

    // Central grand arch
    final archW = size.width * 0.25;
    final archPath = Path()
      ..moveTo(cx - archW / 2, baseY)
      ..lineTo(cx - archW / 2, size.height * 0.45)
      ..quadraticBezierTo(cx, size.height * 0.3, cx + archW / 2, size.height * 0.45)
      ..lineTo(cx + archW / 2, baseY);
    canvas.drawPath(archPath, Paint()
      ..color = h(AppColors.gardenCelestial, healthState).withValues(alpha: 0.5));
    canvas.drawPath(archPath, Paint()
      ..color = h(AppColors.noorGold, healthState).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke..strokeWidth = 2);

    // Side arched windows
    for (final offset in [-0.25, 0.25]) {
      final wx = cx + size.width * offset;
      canvas.drawOval(
        Rect.fromCenter(center: Offset(wx, size.height * 0.55), width: size.width * 0.1, height: size.height * 0.15),
        Paint()..color = h(AppColors.gardenCelestial, healthState).withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
      canvas.drawOval(
        Rect.fromCenter(center: Offset(wx, size.height * 0.55), width: size.width * 0.1, height: size.height * 0.15),
        Paint()..color = h(AppColors.noorGold, healthState).withValues(alpha: 0.4)
          ..style = PaintingStyle.stroke..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(QasrPalacePainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// [14] PEARL DOME PAINTER (18,000 NC Sacred)
// ═══════════════════════════════════════════════════════════════════════════

class PearlDomePainter extends CustomPainter {
  PearlDomePainter({this.healthState = 1, this.glowIntensity = 0.0, this.animationValue = 0.0});
  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final cx = size.width / 2;
    final domeR = size.width * 0.35;
    final domeY = size.height * 0.55;

    // Dome hemisphere — opalescent gradient
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, domeY), width: domeR * 2, height: domeR * 2),
      pi, pi, true,
      Paint()..shader = ui.Gradient.radial(
        Offset(cx - domeR * 0.3, domeY - domeR * 0.5),
        domeR * 1.5,
        [
          h(AppColors.gardenIvory, healthState),
          h(AppColors.gardenPearl, healthState),
          h(AppColors.gardenOpal, healthState),
        ],
        [0.0, 0.5, 1.0],
      ));

    // Gold ribbing
    final ribPaint = Paint()
      ..color = h(AppColors.noorGold, healthState).withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (var i = 0; i < 8; i++) {
      final angle = pi + (i / 7) * pi;
      canvas.drawLine(
        Offset(cx + cos(angle) * domeR, domeY + sin(angle) * domeR),
        Offset(cx, domeY - domeR),
        ribPaint);
    }

    // Gold finial with glowing orb at top
    canvas.drawLine(
      Offset(cx, domeY - domeR), Offset(cx, domeY - domeR - 8),
      Paint()..color = h(AppColors.noorGold, healthState)..strokeWidth = 2);
    canvas.drawCircle(Offset(cx, domeY - domeR - 10), 4, Paint()
      ..color = h(AppColors.gardenGoldGlow, healthState).withValues(alpha: 0.8)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));

    // Iridescence shimmer
    final shimPhase = animationValue * pi * 2;
    canvas.drawArc(
      Rect.fromCenter(center: Offset(cx, domeY), width: domeR * 2, height: domeR * 2),
      pi, pi, true,
      Paint()..color = Color.fromRGBO(
        (sin(shimPhase) * 30 + 200).round().clamp(0, 255),
        (sin(shimPhase + 2) * 20 + 220).round().clamp(0, 255),
        (sin(shimPhase + 4) * 30 + 210).round().clamp(0, 255),
        0.06));

    // Base platform
    canvas.drawRect(
      Rect.fromLTRB(cx - domeR * 1.1, domeY, cx + domeR * 1.1, domeY + 6),
      Paint()..color = h(AppColors.gardenPearl, healthState));
  }

  @override
  bool shouldRepaint(PearlDomePainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// GENERIC PAINTERS for Standard / Common tier items
// ═══════════════════════════════════════════════════════════════════════════

class FountainPainter extends CustomPainter {
  FountainPainter({this.healthState = 1, this.glowIntensity = 0.0, this.animationValue = 0.0});
  final int healthState;
  final double glowIntensity;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final cx = size.width / 2;
    final baseY = size.height * 0.8;

    // Basin
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, baseY), width: size.width * 0.7, height: 14),
      Paint()..color = h(AppColors.gardenSilver, healthState));

    // Water jet
    final jetH = size.height * 0.45;
    for (var i = 0; i < 3; i++) {
      final phase = animationValue * pi * 3 + i * 0.5;
      final xOff = (i - 1) * 3.0;
      canvas.drawLine(
        Offset(cx + xOff, baseY - 5),
        Offset(cx + xOff + sin(phase) * 2, baseY - 5 - jetH),
        Paint()..color = h(AppColors.gardenAquamarine, healthState).withValues(alpha: 0.5)
          ..strokeWidth = 2..strokeCap = StrokeCap.round);
    }

    // Splash drops
    for (var i = 0; i < 4; i++) {
      final angle = (i / 4) * pi + animationValue * pi;
      final r = 12.0 + sin(animationValue * pi * 4 + i) * 5;
      canvas.drawCircle(
        Offset(cx + cos(angle) * r, baseY - 5 - jetH + sin(angle) * 4),
        1.5,
        Paint()..color = h(AppColors.gardenWaterGlow, healthState).withValues(alpha: 0.4));
    }
  }

  @override
  bool shouldRepaint(FountainPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

class GenericPlantPainter extends CustomPainter {
  GenericPlantPainter({
    this.healthState = 1,
    this.glowIntensity = 0.0,
    this.animationValue = 0.0,
    this.plantColor = AppColors.gardenLeafDark,
  });
  final int healthState;
  final double glowIntensity;
  final double animationValue;
  final Color plantColor;

  @override
  void paint(Canvas canvas, Size size) {
    _drawGlowBase(canvas, size, glowIntensity);
    final h = _healthAdjust;
    final cx = size.width / 2;
    final baseY = size.height * 0.85;

    // Simple bush/plant
    for (var i = 0; i < 5; i++) {
      final angle = (i - 2) * 0.4;
      final sway = sin(animationValue * pi * 2 + i) * 3;
      final length = size.height * (0.25 + (i % 2) * 0.1);
      final endX = cx + cos(angle - pi / 2) * 12 + sway;
      final endY = baseY - length;

      canvas.drawLine(Offset(cx, baseY), Offset(endX, endY),
        Paint()..color = h(AppColors.gardenLeafDark, healthState).withValues(alpha: 0.6)
          ..strokeWidth = 1.5..strokeCap = StrokeCap.round);

      // Leaf cluster at top
      canvas.drawCircle(Offset(endX, endY), 6,
        Paint()..color = h(plantColor, healthState).withValues(alpha: 0.5));
    }
  }

  @override
  bool shouldRepaint(GenericPlantPainter o) =>
      o.healthState != healthState || o.animationValue != animationValue;
}

// ═══════════════════════════════════════════════════════════════════════════
// ASSET REGISTRY
// ═══════════════════════════════════════════════════════════════════════════

class JannahAssetPainterRegistry {
  JannahAssetPainterRegistry._();

  static CustomPainter getPainter(
    String assetTemplateId, {
    int healthState = 1,
    double glowIntensity = 0.0,
    double animationValue = 0.0,
  }) {
    // Normalize ID
    final id = assetTemplateId.toLowerCase();

    // Sacred tier
    if (id.contains('sidrat')) {
      return SidraPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('qasr')) {
      return QasrPalacePainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('pearl_dome')) {
      return PearlDomePainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('kawthar')) {
      return KawtharPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('milk')) {
      return MilkRiverPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('honey')) {
      return HoneyRiverPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('pure_water') || id.contains('river_of_pure')) {
      return KawtharPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('grand_mosque') || id.contains('mosque_of_light')) {
      return MosquePainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue, isSacred: true);
    }

    // Premium tier
    if (id.contains('date_palm') || id.contains('palm')) {
      return PalmTreePainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('pomegranate')) {
      return PalmTreePainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue, fruitColor: AppColors.gardenRuby);
    }
    if (id.contains('fig')) {
      return PalmTreePainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue, fruitColor: const Color(0xFF6D4C41));
    }
    if (id.contains('olive')) {
      return PalmTreePainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue, fruitColor: AppColors.gardenEmerald, leafColor: AppColors.gardenLeafLight);
    }
    if (id.contains('grape')) {
      return GrapeCanopyPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('peacock')) {
      return PeacockPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('butterfl')) {
      return ButterfliesPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('waterfall')) {
      return WaterfallPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('small_mosque')) {
      return MosquePainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue, isSacred: false);
    }

    // Flowers
    if (id.contains('rose')) {
      return FlowerPainter(flowerType: FlowerType.rose, healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('jasmine')) {
      return FlowerPainter(flowerType: FlowerType.jasmine, healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('lotus')) {
      return FlowerPainter(flowerType: FlowerType.lotus, healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('lily') || id.contains('golden_lil')) {
      return FlowerPainter(flowerType: FlowerType.lily, healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('lavender')) {
      return FlowerPainter(flowerType: FlowerType.lavender, healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }
    if (id.contains('wildflower')) {
      return FlowerPainter(flowerType: FlowerType.wildflower, healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }

    // Lanterns
    if (id.contains('lantern') || id.contains('noor_lantern')) {
      return LanternPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }

    // Fountains
    if (id.contains('fountain') || id.contains('crystal_fountain')) {
      return FountainPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
    }

    // Default generic plant for anything unmatched
    return GenericPlantPainter(healthState: healthState, glowIntensity: glowIntensity, animationValue: animationValue);
  }
}
