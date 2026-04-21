import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import '../../../core/constants/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// HAYAT DROP ANIMATION
// A luminous raindrop descends from top to target, then bursts on impact.
// ═══════════════════════════════════════════════════════════════════════════

class HayatDropAnimation extends PositionComponent {
  HayatDropAnimation({
    required this.targetPosition,
    required this.cellSize,
    this.onComplete,
  }) : super(
          position: Vector2(targetPosition.x, -40),
          size: Vector2(20, 28),
          anchor: Anchor.center,
        );

  final Vector2 targetPosition;
  final double cellSize;
  final VoidCallback? onComplete;

  double _elapsed = 0;
  static const _fallDuration = 1.0;
  bool _impacted = false;
  final List<_ImpactParticle> _particles = [];

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (!_impacted) {
      // Descend
      final t = (_elapsed / _fallDuration).clamp(0.0, 1.0);
      final eased = _easeInCubic(t);
      position.y = -40 + (targetPosition.y + cellSize / 2 + 40) * eased;
      position.x = targetPosition.x + cellSize / 2;

      if (t >= 1.0) {
        _impacted = true;
        _spawnImpactParticles();
      }
    } else {
      // Update particles
      for (final p in _particles) {
        p.life += dt;
      }
      _particles.removeWhere((p) => p.life >= p.maxLife);

      if (_particles.isEmpty) {
        onComplete?.call();
        removeFromParent();
      }
    }
  }

  double _easeInCubic(double t) => t * t * t;

  void _spawnImpactParticles() {
    final rng = Random();
    for (var i = 0; i < 8; i++) {
      final angle = i * pi / 4 + rng.nextDouble() * 0.3;
      _particles.add(_ImpactParticle(
        angle: angle,
        speed: 30 + rng.nextDouble() * 40,
        maxLife: 0.3 + rng.nextDouble() * 0.15,
      ));
    }
  }

  @override
  void render(Canvas canvas) {
    if (!_impacted) {
      // Draw raindrop
      final cx = size.x / 2;
      final cy = size.y / 2;

      // Glow
      canvas.drawCircle(
        Offset(cx, cy + 2),
        10,
        Paint()
          ..color = AppColors.gardenPearl.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );

      // Teardrop shape
      final path = Path()
        ..moveTo(cx, cy - 10)
        ..quadraticBezierTo(cx + 7, cy, cx + 5, cy + 6)
        ..arcToPoint(
          Offset(cx - 5, cy + 6),
          radius: const Radius.circular(5),
          clockwise: true,
        )
        ..quadraticBezierTo(cx - 7, cy, cx, cy - 10);

      canvas.drawPath(
        path,
        Paint()..color = AppColors.gardenPearl.withValues(alpha: 0.9),
      );

      // Light trail behind
      final trailAlpha = (0.3 - _elapsed * 0.2).clamp(0.0, 0.3);
      canvas.drawLine(
        Offset(cx, cy - 12),
        Offset(cx, cy - 30),
        Paint()
          ..color = AppColors.gardenCelestial.withValues(alpha: trailAlpha)
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // Draw impact particles
      for (final p in _particles) {
        final t = p.life / p.maxLife;
        final dist = p.speed * p.life;
        final px = size.x / 2 + cos(p.angle) * dist;
        final py = size.y / 2 + sin(p.angle) * dist;
        final alpha = (1.0 - t) * 0.8;
        final radius = 3.0 * (1.0 - t * 0.5);

        canvas.drawCircle(
          Offset(px, py),
          radius,
          Paint()
            ..color = AppColors.gardenGoldGlow.withValues(alpha: alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }
    }
  }
}

class _ImpactParticle {
  _ImpactParticle({
    required this.angle,
    required this.speed,
    required this.maxLife,
  });

  final double angle;
  final double speed;
  final double maxLife;
  double life = 0;
}

// ═══════════════════════════════════════════════════════════════════════════
// HAYAT BLOOM ANIMATION
// A golden expanding ring from centre, restoring all assets as it passes.
// ═══════════════════════════════════════════════════════════════════════════

class HayatBloomAnimation extends PositionComponent {
  HayatBloomAnimation({
    required this.centrePosition,
    required this.maxRadius,
    this.onComplete,
  }) : super(
          position: centrePosition,
          size: Vector2.all(maxRadius * 2.5),
          anchor: Anchor.center,
        );

  final Vector2 centrePosition;
  final double maxRadius;
  final VoidCallback? onComplete;

  double _elapsed = 0;
  static const _duration = 3.5; // seconds for full expansion

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (_elapsed >= _duration + 0.5) {
      onComplete?.call();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_elapsed / _duration).clamp(0.0, 1.0);
    final currentRadius = maxRadius * t;
    final ringAlpha = (1.0 - t * 0.7).clamp(0.0, 1.0) * 0.6;
    final cx = size.x / 2;
    final cy = size.y / 2;

    // Outer warm glow
    canvas.drawCircle(
      Offset(cx, cy),
      currentRadius + 20,
      Paint()
        ..color = AppColors.gardenGoldGlow.withValues(alpha: ringAlpha * 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Main golden ring
    canvas.drawCircle(
      Offset(cx, cy),
      currentRadius,
      Paint()
        ..color = AppColors.noorGold.withValues(alpha: ringAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12 * (1.0 - t * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Inner bright ring
    canvas.drawCircle(
      Offset(cx, cy),
      currentRadius - 3,
      Paint()
        ..color = AppColors.gardenCelestial.withValues(alpha: ringAlpha * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * (1.0 - t * 0.5),
    );

    // Sparkles along the ring edge
    if (t > 0.1 && t < 0.9) {
      final sparkleCount = (12 * (1.0 - t)).round().clamp(0, 12);
      for (var i = 0; i < sparkleCount; i++) {
        final angle = (i / sparkleCount) * pi * 2 + _elapsed * 2;
        final sx = cx + cos(angle) * currentRadius;
        final sy = cy + sin(angle) * currentRadius;
        canvas.drawCircle(
          Offset(sx, sy),
          2.5,
          Paint()
            ..color = AppColors.gardenCelestial
                .withValues(alpha: ringAlpha * 0.7)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
        );
      }
    }
  }
}
