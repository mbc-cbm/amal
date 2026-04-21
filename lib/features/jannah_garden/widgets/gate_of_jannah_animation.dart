import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Full-screen Gate of Jannah entry animation.
/// 6 beats over ~8 seconds, entirely CustomPainter-driven.
class GateOfJannahAnimation extends StatefulWidget {
  const GateOfJannahAnimation({
    super.key,
    required this.onComplete,
    this.canSkip = false,
  });

  final VoidCallback onComplete;
  final bool canSkip;

  @override
  State<GateOfJannahAnimation> createState() => _GateOfJannahAnimationState();
}

class _GateOfJannahAnimationState extends State<GateOfJannahAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Beat intervals (normalized 0–1 over 8 seconds total)
  late final Animation<double> _beat1; // Darkness       0.0s–0.5s
  late final Animation<double> _beat2; // Clouds         0.5s–2.0s
  late final Animation<double> _beat3; // Life enters    2.0s–3.5s
  late final Animation<double> _beat4; // Gate appears   3.5s–5.5s
  late final Animation<double> _beat5; // Opening        5.5s–7.0s
  late final Animation<double> _beat6; // Entry          7.0s–8.0s

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 8000),
    );

    _beat1 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.0625, curve: Curves.easeOut), // 0–0.5s
    );
    _beat2 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0625, 0.25, curve: Curves.easeInOut), // 0.5–2.0s
    );
    _beat3 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.4375, curve: Curves.easeInOut), // 2.0–3.5s
    );
    _beat4 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.4375, 0.6875, curve: Curves.easeOut), // 3.5–5.5s
    );
    _beat5 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.6875, 0.875, curve: Curves.easeInOut), // 5.5–7.0s
    );
    _beat6 = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.875, 1.0, curve: Curves.easeIn), // 7.0–8.0s
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

  void _skip() {
    _ctrl.stop();
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _ctrl,
          builder: (context, _) {
            return CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _GatePainter(
                beat1: _beat1.value,
                beat2: _beat2.value,
                beat3: _beat3.value,
                beat4: _beat4.value,
                beat5: _beat5.value,
                beat6: _beat6.value,
                totalProgress: _ctrl.value,
              ),
            );
          },
        ),
        // Skip button
        if (widget.canSkip)
          AnimatedBuilder(
            animation: _ctrl,
            builder: (context, child) {
              if (_ctrl.value < 0.25) return const SizedBox.shrink();
              return Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                right: 16,
                child: Opacity(
                  opacity: 0.6,
                  child: GestureDetector(
                    onTap: _skip,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Skip',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GATE PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _GatePainter extends CustomPainter {
  _GatePainter({
    required this.beat1,
    required this.beat2,
    required this.beat3,
    required this.beat4,
    required this.beat5,
    required this.beat6,
    required this.totalProgress,
  });

  final double beat1;
  final double beat2;
  final double beat3;
  final double beat4;
  final double beat5;
  final double beat6;
  final double totalProgress;

  static const _bgDark = Color(0xFF0A0A12);
  static const _cloudWhite = Color(0xFFFFFDF5);
  static const _glowGold = Color(0xFFFFE44D);
  static const _gateGold = Color(0xFFC9942A);
  static const _gatePearl = Color(0xFFF5F0E8);
  static const _lightWarm = Color(0xFFFFFFF0);
  static const _lightGlow = Color(0xFFFFF8DC);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Beat 6: zoom + white fade
    if (beat6 > 0) {
      final scale = 1.0 + beat6 * 0.4;
      canvas.save();
      canvas.translate(cx, cy);
      canvas.scale(scale);
      canvas.translate(-cx, -cy);
    }

    // ── BEAT 1: Darkness ──────────────────────────────────────────────────
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _bgDark,
    );

    // Slow pulsing circle at centre
    if (beat1 > 0) {
      final pulsePhase = math.sin(totalProgress * math.pi * 4);
      final pulseOpacity = 0.03 + pulsePhase * 0.02;
      canvas.drawCircle(
        Offset(cx, cy),
        size.width * 0.3,
        Paint()
          ..color = Colors.black.withValues(alpha: pulseOpacity.clamp(0.0, 1.0))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40),
      );
    }

    // ── BEAT 2: Clouds ────────────────────────────────────────────────────
    if (beat2 > 0) {
      _drawClouds(canvas, size, beat2);
    }

    // ── BEAT 3: Life enters ───────────────────────────────────────────────
    if (beat3 > 0) {
      _drawVines(canvas, size, beat3);
      _drawBirds(canvas, size, beat3);
    }

    // ── BEAT 4: Gate appears (clouds part) ────────────────────────────────
    if (beat4 > 0) {
      // Draw parting clouds
      _drawClouds(canvas, size, 1.0, partProgress: beat4);

      // Draw gate
      _drawGate(canvas, size, beat4, doorOpenProgress: 0.0);
    } else if (beat2 > 0 && beat4 <= 0) {
      // Clouds still gathered (beat 2–3)
      _drawClouds(canvas, size, beat2 > 1 ? 1.0 : beat2);
    }

    // ── BEAT 5: Opening ───────────────────────────────────────────────────
    if (beat5 > 0) {
      // Keep clouds parted
      _drawClouds(canvas, size, 1.0, partProgress: 1.0);
      // Draw gate with opening doors
      _drawGate(canvas, size, 1.0, doorOpenProgress: beat5);
    }

    // ── BEAT 6: White fade ────────────────────────────────────────────────
    if (beat6 > 0) {
      canvas.restore(); // undo zoom

      // White overlay
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = Colors.white.withValues(alpha: beat6),
      );
    }
  }

  // ── CLOUDS ──────────────────────────────────────────────────────────────

  void _drawClouds(Canvas canvas, Size size, double progress,
      {double partProgress = 0.0}) {
    // 8 clouds from edges converging to centre, then parting in beat 4
    final cloudDefs = <_CloudDef>[
      _CloudDef(-0.3, 0.3, 0.15, 0.35, 140, 70), // left top
      _CloudDef(-0.2, 0.5, 0.25, 0.45, 160, 80), // left mid
      _CloudDef(1.3, 0.2, 0.75, 0.30, 150, 65),  // right top
      _CloudDef(1.2, 0.6, 0.65, 0.50, 170, 75),  // right mid
      _CloudDef(0.3, -0.2, 0.35, 0.20, 130, 60), // top left
      _CloudDef(0.7, -0.15, 0.60, 0.25, 155, 70), // top right
      _CloudDef(0.2, 1.2, 0.40, 0.60, 145, 65),  // bottom left
      _CloudDef(0.8, 1.15, 0.55, 0.55, 135, 60), // bottom right
    ];

    for (var i = 0; i < cloudDefs.length; i++) {
      final c = cloudDefs[i];
      final t = progress.clamp(0.0, 1.0);

      // Converge to target position
      var x = ui.lerpDouble(c.startX * size.width, c.targetX * size.width, t)!;
      var y = ui.lerpDouble(c.startY * size.height, c.targetY * size.height, t)!;

      // Part clouds in beat 4
      if (partProgress > 0) {
        final isLeft = c.startX < 0.5;
        final partOffset = partProgress * size.width * 0.5;
        x += isLeft ? -partOffset : partOffset;
      }

      final opacity = (t * 0.85).clamp(0.0, 0.85);

      // Glow halo behind cloud
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(x, y),
            width: c.width * 1.3,
            height: c.height * 1.3),
        Paint()
          ..color = _glowGold.withValues(alpha: opacity * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25),
      );

      // Cloud body
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(x, y), width: c.width, height: c.height),
        Paint()
          ..color = _cloudWhite.withValues(alpha: opacity)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );

      // Layered inner lighter core
      canvas.drawOval(
        Rect.fromCenter(
            center: Offset(x, y),
            width: c.width * 0.6,
            height: c.height * 0.6),
        Paint()
          ..color = Colors.white.withValues(alpha: opacity * 0.5)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
  }

  // ── VINES ───────────────────────────────────────────────────────────────

  void _drawVines(Canvas canvas, Size size, double progress) {
    final vineXPositions = [0.15, 0.3, 0.45, 0.55, 0.7, 0.85];

    for (var i = 0; i < vineXPositions.length; i++) {
      final baseX = vineXPositions[i] * size.width;
      final baseY = size.height;
      final targetY = size.height * (0.35 + (i % 3) * 0.05);
      final height = baseY - targetY;

      // Stagger each vine slightly
      final staggeredProgress =
          ((progress - i * 0.05) / 0.7).clamp(0.0, 1.0);

      final path = Path();
      path.moveTo(baseX, baseY);

      // Gently curving vine
      final sway = math.sin(i * 1.2) * 15;
      final currentHeight = height * staggeredProgress;
      final midY = baseY - currentHeight * 0.5;
      final tipY = baseY - currentHeight;

      path.quadraticBezierTo(
        baseX + sway,
        midY,
        baseX + sway * 0.5,
        tipY,
      );

      // Draw vine glow
      canvas.drawPath(
        path,
        Paint()
          ..color = _glowGold.withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Draw vine line
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF8BC34A).withValues(alpha: staggeredProgress * 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round,
      );

      // Leaves sprouting from sides
      if (staggeredProgress > 0.3) {
        final leafCount = (staggeredProgress * 4).floor().clamp(0, 4);
        for (var l = 0; l < leafCount; l++) {
          final leafY = baseY - currentHeight * (0.2 + l * 0.2);
          final leafX = baseX + sway * (0.2 + l * 0.15);
          final side = l.isEven ? 1.0 : -1.0;
          final leafScale = ((staggeredProgress - 0.3) * 2).clamp(0.0, 1.0);

          canvas.save();
          canvas.translate(leafX, leafY);
          canvas.rotate(side * 0.4);
          canvas.scale(leafScale * 0.8);

          final leafPath = Path()
            ..moveTo(0, 0)
            ..quadraticBezierTo(side * 8, -6, side * 14, -2)
            ..quadraticBezierTo(side * 8, 2, 0, 0);

          canvas.drawPath(
            leafPath,
            Paint()
              ..color = const Color(0xFF66BB6A).withValues(alpha: 0.7)
              ..style = PaintingStyle.fill,
          );
          canvas.restore();
        }
      }

      // Flower at tip
      if (staggeredProgress > 0.8) {
        final flowerScale =
            ((staggeredProgress - 0.8) / 0.2).clamp(0.0, 1.0);
        final tipX = baseX + sway * 0.5;

        // Glow
        canvas.drawCircle(
          Offset(tipX, tipY),
          8 * flowerScale,
          Paint()
            ..color = _glowGold.withValues(alpha: 0.3 * flowerScale)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
        );

        // Centre
        canvas.drawCircle(
          Offset(tipX, tipY),
          3 * flowerScale,
          Paint()..color = _glowGold.withValues(alpha: flowerScale),
        );

        // Petals
        for (var p = 0; p < 6; p++) {
          final angle = p * math.pi / 3;
          final px = tipX + math.cos(angle) * 6 * flowerScale;
          final py = tipY + math.sin(angle) * 6 * flowerScale;
          canvas.drawOval(
            Rect.fromCenter(
                center: Offset(px, py),
                width: 4 * flowerScale,
                height: 6 * flowerScale),
            Paint()
              ..color = Colors.white.withValues(alpha: 0.8 * flowerScale),
          );
        }
      }
    }
  }

  // ── BIRDS ───────────────────────────────────────────────────────────────

  void _drawBirds(Canvas canvas, Size size, double progress) {
    if (progress < 0.1) return;

    final birdProgress = ((progress - 0.1) / 0.9).clamp(0.0, 1.0);

    for (var b = 0; b < 2; b++) {
      final startX = b == 0 ? size.width * 0.2 : size.width * 0.8;
      final startY = size.height * 0.35;
      final endX = size.width * (0.4 + b * 0.2);
      final endY = size.height * 0.25;

      final x = ui.lerpDouble(startX, endX, birdProgress)!;
      final y = ui.lerpDouble(startY, endY, birdProgress)! +
          math.sin(birdProgress * math.pi * 6) * 8;

      // Wing flap
      final flapAngle = math.sin(birdProgress * math.pi * 8) * 0.4;

      final birdPaint = Paint()
        ..color = Colors.white.withValues(alpha: birdProgress * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      // M-shaped bird
      final birdPath = Path()
        ..moveTo(x - 12, y + 4 * flapAngle)
        ..quadraticBezierTo(x - 5, y - 8 + 6 * flapAngle, x, y)
        ..quadraticBezierTo(x + 5, y - 8 + 6 * flapAngle, x + 12, y + 4 * flapAngle);

      canvas.drawPath(birdPath, birdPaint);

      // Light trail
      if (birdProgress > 0.2) {
        for (var d = 0; d < 5; d++) {
          final trailT = (birdProgress - d * 0.04).clamp(0.0, 1.0);
          final tx = ui.lerpDouble(startX, endX, trailT)!;
          final ty = ui.lerpDouble(startY, endY, trailT)! +
              math.sin(trailT * math.pi * 6) * 8;
          canvas.drawCircle(
            Offset(tx, ty),
            1.5,
            Paint()
              ..color = Colors.white.withValues(alpha: (0.3 - d * 0.05).clamp(0.0, 1.0)),
          );
        }
      }
    }
  }

  // ── GATE ─────────────────────────────────────────────────────────────────

  void _drawGate(Canvas canvas, Size size, double appearProgress,
      {required double doorOpenProgress}) {
    final cx = size.width / 2;
    final cy = size.height * 0.45;
    final gateWidth = size.width * 0.7;
    final gateHeight = size.height * 0.55;

    // Scale in
    final scale = 0.3 + appearProgress * 0.7;
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(scale);
    canvas.translate(-cx, -cy);

    final gateLeft = cx - gateWidth / 2;
    final gateTop = cy - gateHeight / 2;

    // Radiant glow behind gate
    canvas.drawCircle(
      Offset(cx, cy),
      gateWidth * 0.6,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          gateWidth * 0.6,
          [
            _lightGlow.withValues(alpha: 0.4 * appearProgress),
            _lightGlow.withValues(alpha: 0.0),
          ],
        ),
    );

    // Light pouring through seam (intensifies as doors open)
    final seamGlow = (doorOpenProgress * 0.8).clamp(0.0, 0.8);
    canvas.drawRect(
      Rect.fromCenter(
          center: Offset(cx, cy),
          width: 4 + doorOpenProgress * gateWidth * 0.5,
          height: gateHeight * 0.8),
      Paint()
        ..color = _lightWarm.withValues(alpha: 0.3 + seamGlow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Draw left door
    _drawDoor(canvas, gateLeft, gateTop, gateWidth / 2 - 2, gateHeight,
        cx, cy, -doorOpenProgress * 60, appearProgress, isLeft: true);

    // Draw right door
    _drawDoor(canvas, cx + 2, gateTop, gateWidth / 2 - 2, gateHeight,
        cx, cy, doorOpenProgress * 60, appearProgress, isLeft: false);

    // Arabic text above gate
    if (appearProgress > 0.3) {
      final textOpacity = ((appearProgress - 0.3) / 0.7).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: 'ادخلوها بسلام آمنين',
          style: TextStyle(
            fontSize: 18,
            color: _gateGold.withValues(alpha: textOpacity),
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();

      // Amber glow behind text
      canvas.drawRect(
        Rect.fromCenter(
            center: Offset(cx, gateTop - 20),
            width: tp.width + 24,
            height: tp.height + 12),
        Paint()
          ..color = const Color(0xFFFFAA00).withValues(alpha: textOpacity * 0.15)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      tp.paint(canvas, Offset(cx - tp.width / 2, gateTop - 20 - tp.height / 2));
    }

    canvas.restore();
  }

  void _drawDoor(Canvas canvas, double left, double top, double width,
      double height, double pivotX, double pivotY, double angleDeg,
      double opacity,
      {required bool isLeft}) {
    canvas.save();

    // Simulate perspective rotation
    if (angleDeg.abs() > 0.1) {
      final pivX = isLeft ? left + width : left;
      canvas.translate(pivX, top + height / 2);
      // Fake perspective by scaling X based on angle
      final angleRad = angleDeg * math.pi / 180;
      final scaleX = math.cos(angleRad).abs().clamp(0.3, 1.0);
      canvas.scale(isLeft ? scaleX : scaleX, 1.0);
      canvas.translate(-pivX, -(top + height / 2));
    }

    // Door frame (ogee arch shape)
    final doorPath = Path();
    doorPath.moveTo(left, top + height);
    doorPath.lineTo(left, top + height * 0.25);

    // Ogee arch top
    final archCx = left + width / 2;
    doorPath.quadraticBezierTo(left, top - height * 0.05, archCx, top);
    doorPath.quadraticBezierTo(
        left + width, top - height * 0.05, left + width, top + height * 0.25);
    doorPath.lineTo(left + width, top + height);
    doorPath.close();

    // Fill with pearl white
    canvas.drawPath(
      doorPath,
      Paint()..color = _gatePearl.withValues(alpha: opacity * 0.9),
    );

    // Gold frame border
    canvas.drawPath(
      doorPath,
      Paint()
        ..color = _gateGold.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Inner geometric pattern — repeating diamond grid
    final patternPaint = Paint()
      ..color = _gateGold.withValues(alpha: opacity * 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final patternStep = width / 5;
    for (var py = top + height * 0.3; py < top + height - patternStep; py += patternStep) {
      for (var px = left + patternStep * 0.5;
          px < left + width - patternStep * 0.3;
          px += patternStep) {
        // Diamond
        final dPath = Path()
          ..moveTo(px, py - patternStep * 0.3)
          ..lineTo(px + patternStep * 0.3, py)
          ..lineTo(px, py + patternStep * 0.3)
          ..lineTo(px - patternStep * 0.3, py)
          ..close();
        canvas.drawPath(dPath, patternPaint);

        // Small star at centre
        canvas.drawCircle(
            Offset(px, py), 1.5, Paint()..color = _gateGold.withValues(alpha: opacity * 0.25));
      }
    }

    // Inner golden border line
    final insetPath = Path();
    final inset = 6.0;
    insetPath.moveTo(left + inset, top + height - inset);
    insetPath.lineTo(left + inset, top + height * 0.27);
    insetPath.quadraticBezierTo(
        left + inset, top + height * 0.05, archCx, top + inset);
    insetPath.quadraticBezierTo(
        left + width - inset, top + height * 0.05, left + width - inset, top + height * 0.27);
    insetPath.lineTo(left + width - inset, top + height - inset);

    canvas.drawPath(
      insetPath,
      Paint()
        ..color = _gateGold.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GatePainter oldDelegate) => true;
}

// ── Cloud definition helper ──────────────────────────────────────────────

class _CloudDef {
  const _CloudDef(
      this.startX, this.startY, this.targetX, this.targetY, this.width, this.height);
  final double startX, startY, targetX, targetY;
  final double width, height;
}
