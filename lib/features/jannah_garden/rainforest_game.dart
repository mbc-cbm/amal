import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../../core/constants/app_colors.dart';

// ═══════════════════════════════════════════════════════════════════════════
// RainforestGame — Outer Circle rainforest. Always lush, never withers.
// Intensity (0.0-1.0) from outerGardenIntensityProvider drives rainfall.
// ═══════════════════════════════════════════════════════════════════════════

class RainforestGame extends FlameGame {
  RainforestGame({required int intensity})
      : _intensity = (intensity / 100.0).clamp(0.0, 1.0);

  double _intensity;
  double _targetIntensity = 0;
  bool _burstActive = false;
  double _burstTimer = 0;

  final Random _rng = Random();

  late _ParallaxForestBackground _bg;
  late _AtmosphericMist _mist;
  late _RainSystem _rain;
  late _GlowParticleSystem _glowSystem;

  /// Update intensity smoothly from provider stream.
  void setIntensity(double newIntensity) {
    _targetIntensity = newIntensity.clamp(0.0, 1.0);
  }

  /// Trigger a 3-second referral burst.
  void triggerReferralBurst() {
    _burstActive = true;
    _burstTimer = 3.0;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _targetIntensity = _intensity;

    // Parallax forest background (3 layers)
    _bg = _ParallaxForestBackground(screenSize: size.clone());
    add(_bg);

    // Atmospheric mist
    _mist = _AtmosphericMist(screenSize: size.clone(), rng: _rng);
    add(_mist);

    // Trees (always lush)
    for (var i = 0; i < 20; i++) {
      final treeH = 60.0 + _rng.nextDouble() * 90;
      add(_LushTree(
        position: Vector2(
          _rng.nextDouble() * size.x,
          size.y * 0.4 + _rng.nextDouble() * size.y * 0.45,
        ),
        treeHeight: treeH,
        rng: _rng,
      ));
    }

    // Rain system (pooled)
    _rain = _RainSystem(
      bounds: size.clone(),
      rng: _rng,
      maxParticles: 400,
    );
    add(_rain);

    // Glow particles
    _glowSystem = _GlowParticleSystem(bounds: size.clone(), rng: _rng);
    add(_glowSystem);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Smooth intensity interpolation (3 second transition)
    if ((_intensity - _targetIntensity).abs() > 0.001) {
      final step = dt / 3.0;
      if (_targetIntensity > _intensity) {
        _intensity = (_intensity + step).clamp(0.0, _targetIntensity);
      } else {
        _intensity = (_intensity - step).clamp(_targetIntensity, 1.0);
      }
    }

    // Burst timer
    if (_burstActive) {
      _burstTimer -= dt;
      if (_burstTimer <= 0) {
        _burstActive = false;
      }
    }

    // Drive rain system
    final effectiveIntensity = _burstActive ? 1.0 : _intensity;
    _rain.targetActiveCount = (effectiveIntensity * 400).round().clamp(0, 400);
    _rain.burstMode = _burstActive;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// PARALLAX FOREST BACKGROUND — 3 depth layers
// ═══════════════════════════════════════════════════════════════════════════

class _ParallaxForestBackground extends Component {
  _ParallaxForestBackground({required this.screenSize});
  final Vector2 screenSize;

  @override
  void render(Canvas canvas) {
    final w = screenSize.x;
    final h = screenSize.y;

    // Far background: blue-purple sky with luminous horizon
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = Gradient.linear(
          Offset.zero,
          Offset(0, h),
          [
            const Color(0xFF1A1A3E), // deep blue-purple sky
            const Color(0xFF0D3520), // deep forest base
          ],
        ),
    );

    // Luminous horizon band
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.25, w, h * 0.08),
      Paint()
        ..color = const Color(0xFFFFF8DC).withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Mid background: silhouette tree rows (3 rows, getting smaller)
    final rng = Random(11);
    for (var row = 0; row < 3; row++) {
      final depth = row / 2.0;
      final rowY = h * (0.22 + depth * 0.12);
      final treeH = 25 + (1.0 - depth / 2) * 30;
      final count = 12 + row * 4;
      final alpha = 0.12 + depth * 0.06;

      final paint = Paint()
        ..color = Color.fromRGBO(15, 55, 25, alpha);
      final edgePaint = Paint()
        ..color = const Color(0xFFC9942A).withValues(alpha: 0.03 + depth * 0.01);

      for (var i = 0; i < count; i++) {
        final x = (w / count) * i + rng.nextDouble() * 15;
        final tw = treeH * 0.5;

        // Canopy silhouette (oval)
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x, rowY),
            width: tw * 1.2,
            height: treeH * 0.7,
          ),
          paint,
        );
        // Gold-lit edge (very subtle)
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(x + 2, rowY - 1),
            width: tw * 0.8,
            height: treeH * 0.4,
          ),
          edgePaint,
        );
      }
    }

    // Near background: dense forest wall
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.85, w, h * 0.15),
      Paint()..color = const Color(0xFF0A1F0E),
    );

    // Ground: luminous moss with gold-tipped grass hints
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.88, w, h * 0.12),
      Paint()
        ..shader = Gradient.linear(
          Offset(0, h * 0.88),
          Offset(0, h),
          [
            const Color(0xFF1B4D25).withValues(alpha: 0.8),
            const Color(0xFF0D2E14),
          ],
        ),
    );

    // Gold-tipped grass accents
    for (var i = 0; i < 30; i++) {
      final gx = rng.nextDouble() * w;
      final gy = h * 0.88 + rng.nextDouble() * h * 0.06;
      canvas.drawLine(
        Offset(gx, gy + 6),
        Offset(gx + (rng.nextDouble() - 0.5) * 3, gy),
        Paint()
          ..color = const Color(0xFFC9942A).withValues(alpha: 0.15)
          ..strokeWidth = 1
          ..strokeCap = StrokeCap.round,
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ATMOSPHERIC MIST — drifting wisps
// ═══════════════════════════════════════════════════════════════════════════

class _AtmosphericMist extends Component {
  _AtmosphericMist({required this.screenSize, required this.rng});
  final Vector2 screenSize;
  final Random rng;
  double _time = 0;

  late final List<_MistBlob> _blobs;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _blobs = List.generate(10, (i) => _MistBlob(
      x: rng.nextDouble() * screenSize.x,
      y: screenSize.y * (0.3 + rng.nextDouble() * 0.4),
      radius: 40 + rng.nextDouble() * 60,
      speed: 5 + rng.nextDouble() * 12,
      phase: rng.nextDouble() * pi * 2,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    for (final b in _blobs) {
      final x = (b.x + _time * b.speed + sin(_time * 0.3 + b.phase) * 20)
          % (screenSize.x + b.radius * 2) - b.radius;
      final y = b.y + cos(_time * 0.5 + b.phase) * 8;
      final alpha = (sin(_time * 0.4 + b.phase) * 0.04 + 0.1).clamp(0.08, 0.15);

      canvas.drawCircle(
        Offset(x, y),
        b.radius,
        Paint()
          ..color = Color.fromRGBO(220, 225, 220, alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30),
      );
    }
  }
}

class _MistBlob {
  const _MistBlob({
    required this.x, required this.y,
    required this.radius, required this.speed, required this.phase,
  });
  final double x, y, radius, speed, phase;
}

// ═══════════════════════════════════════════════════════════════════════════
// LUSH TREE — always healthy, gold-edged canopy
// ═══════════════════════════════════════════════════════════════════════════

class _LushTree extends PositionComponent {
  _LushTree({
    required super.position,
    required this.treeHeight,
    required this.rng,
  }) : super(anchor: Anchor.bottomCenter);

  final double treeHeight;
  final Random rng;

  late final Paint _trunkPaint;
  late final Paint _canopyPaint;
  late final Paint _canopyEdgePaint;
  late final double _canopyW;
  double _swayPhase = 0;
  late final double _swaySpeed;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2(treeHeight * 0.6, treeHeight);

    _trunkPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF5D4037),
        const Color(0xFF3E2723),
        rng.nextDouble(),
      )!;

    _canopyPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF2E7D32),
        const Color(0xFF1B5E20),
        rng.nextDouble(),
      )!;

    _canopyEdgePaint = Paint()
      ..color = AppColors.noorGold.withValues(alpha: 0.08 + rng.nextDouble() * 0.06);

    _canopyW = treeHeight * (0.4 + rng.nextDouble() * 0.25);
    _swayPhase = rng.nextDouble() * pi * 2;
    _swaySpeed = 0.6 + rng.nextDouble() * 0.8;
  }

  @override
  void update(double dt) {
    super.update(dt);
    _swayPhase += dt * _swaySpeed;
  }

  @override
  void render(Canvas canvas) {
    final w = size.x;
    final h = size.y;
    final sway = sin(_swayPhase) * 3;

    // Trunk
    final trunkW = w * 0.15;
    canvas.drawRect(
      Rect.fromLTWH((w - trunkW) / 2, h * 0.55, trunkW, h * 0.45),
      _trunkPaint,
    );

    // Canopy
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2 + sway, h * 0.35),
        width: _canopyW * 2,
        height: h * 0.55,
      ),
      _canopyPaint,
    );

    // Gold-lit canopy edge
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2 + sway + 3, h * 0.33),
        width: _canopyW * 1.4,
        height: h * 0.35,
      ),
      _canopyEdgePaint,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// RAIN SYSTEM — Object-pooled multi-colour glowing rain
// ═══════════════════════════════════════════════════════════════════════════

/// Pool colours for raindrops.
const _rainColors = [
  Color(0xB3FFE44D), // Gold 0.7
  Color(0xB3A5D6A7), // Soft green 0.7
  Color(0xCCF5F5F0), // Pearl white 0.8
  Color(0x99CE93D8), // Blue-violet 0.6
  Color(0xA6F48FB1), // Rose 0.65
];

/// Burst-only colours (gold + pearl).
const _burstColors = [
  Color(0xCCFFE44D),
  Color(0xDDF5F5F0),
];

class _RainSystem extends Component {
  _RainSystem({
    required this.bounds,
    required this.rng,
    required this.maxParticles,
  });

  final Vector2 bounds;
  final Random rng;
  final int maxParticles;

  int targetActiveCount = 0;
  bool burstMode = false;

  late final List<_PooledRainDrop> _pool;
  final List<_ImpactBurst> _impacts = [];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _pool = List.generate(maxParticles, (_) => _PooledRainDrop(rng, bounds));
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Activate/deactivate particles to match target
    var activeCount = _pool.where((d) => d.active).length;

    // Activate
    while (activeCount < targetActiveCount) {
      final inactive = _pool.where((d) => !d.active).firstOrNull;
      if (inactive == null) break;
      inactive.activate(rng, bounds, burstMode);
      activeCount++;
    }

    // Deactivate (don't kill mid-fall, just don't reactivate)
    // Handled naturally as particles fall off screen

    // Update active particles
    for (final drop in _pool) {
      if (!drop.active) continue;

      drop.y += drop.speed * dt;
      drop.x += 15 * dt; // wind drift

      // Intensity-based distribution
      if (targetActiveCount < 120) {
        // Low: concentrate in centre
        if ((drop.x - bounds.x / 2).abs() > bounds.x * 0.3) {
          drop.x = bounds.x * 0.3 + rng.nextDouble() * bounds.x * 0.4;
        }
      }

      // Off screen: recycle or deactivate
      if (drop.y > bounds.y + 10) {
        // Spawn impact burst
        _impacts.add(_ImpactBurst(
          x: drop.x,
          y: bounds.y - 5,
          color: drop.color,
        ));

        if (activeCount <= targetActiveCount) {
          drop.activate(rng, bounds, burstMode);
        } else {
          drop.active = false;
          activeCount--;
        }
      }
    }

    // Update impact bursts
    for (final impact in _impacts) {
      impact.life += dt;
    }
    _impacts.removeWhere((i) => i.life >= 0.4);
  }

  @override
  void render(Canvas canvas) {
    // Render rain drops
    for (final drop in _pool) {
      if (!drop.active) continue;
      canvas.drawLine(
        Offset(drop.x, drop.y),
        Offset(drop.x + 1, drop.y + drop.length),
        Paint()
          ..color = drop.color
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }

    // Render impact bursts
    for (final impact in _impacts) {
      final t = impact.life / 0.4;
      final r = 6.0 * t;
      final alpha = (1.0 - t) * 0.5;
      canvas.drawCircle(
        Offset(impact.x, impact.y),
        r,
        Paint()
          ..color = impact.color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }
  }
}

class _PooledRainDrop {
  _PooledRainDrop(Random rng, Vector2 bounds) {
    // Start inactive
    active = false;
  }

  double x = 0;
  double y = 0;
  double speed = 300;
  double length = 12;
  Color color = _rainColors[0];
  bool active = false;

  void activate(Random rng, Vector2 bounds, bool burst) {
    active = true;
    x = rng.nextDouble() * bounds.x;
    y = -(rng.nextDouble() * bounds.y * 0.5);
    speed = 200 + rng.nextDouble() * 200;
    length = 10 + rng.nextDouble() * 6;

    if (burst) {
      color = _burstColors[rng.nextInt(_burstColors.length)];
    } else {
      color = _rainColors[rng.nextInt(_rainColors.length)];
    }
  }
}

class _ImpactBurst {
  _ImpactBurst({required this.x, required this.y, required this.color});
  final double x, y;
  final Color color;
  double life = 0;
}

// ═══════════════════════════════════════════════════════════════════════════
// GLOW PARTICLES — floating gold/green lights
// ═══════════════════════════════════════════════════════════════════════════

class _GlowParticleSystem extends Component {
  _GlowParticleSystem({required this.bounds, required this.rng});
  final Vector2 bounds;
  final Random rng;
  double _time = 0;

  late final List<_GlowMote> _motes;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _motes = List.generate(25, (i) => _GlowMote(
      x: rng.nextDouble() * bounds.x,
      y: rng.nextDouble() * bounds.y,
      driftX: (rng.nextDouble() - 0.5) * 25,
      speed: 12 + rng.nextDouble() * 25,
      phase: rng.nextDouble() * pi * 2,
      twinkleSpeed: 1.5 + rng.nextDouble() * 2,
      radius: 2 + rng.nextDouble() * 3,
      isGold: rng.nextBool(),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    for (final m in _motes) {
      var y = (m.y - _time * m.speed) % bounds.y;
      if (y < 0) y += bounds.y;
      final x = m.x + sin(_time * 0.6 + m.phase) * m.driftX;
      final alpha = ((sin(_time * m.twinkleSpeed + m.phase) + 1) / 2 * 0.6 + 0.2)
          .clamp(0.0, 0.8);

      final color = m.isGold ? AppColors.noorGold : AppColors.gardenGrass;
      canvas.drawCircle(
        Offset(x, y),
        m.radius,
        Paint()
          ..color = color.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }
  }
}

class _GlowMote {
  const _GlowMote({
    required this.x, required this.y,
    required this.driftX, required this.speed, required this.phase,
    required this.twinkleSpeed, required this.radius, required this.isGold,
  });
  final double x, y, driftX, speed, phase, twinkleSpeed, radius;
  final bool isGold;
}
