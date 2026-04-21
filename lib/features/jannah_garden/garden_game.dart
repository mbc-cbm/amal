import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart'
    show Color, Colors, Curves, FontWeight, TextStyle;

import '../../core/constants/app_colors.dart';
import '../../core/services/garden_neglect_service.dart';
import './painters/asset_painters.dart';

// ── Camera mode enum ──────────────────────────────────────────────────────

enum GardenCameraMode { architect, immersion }

// ---------------------------------------------------------------------------
// GardenGame — Flame game for the Inner Circle personal garden (20x20 grid).
// ---------------------------------------------------------------------------

class GardenGame extends FlameGame
    with ScaleCallbacks, TapCallbacks, DoubleTapCallbacks {
  // ── Grid constants ──────────────────────────────────────────────────────
  final int gridSize = 20;
  final double cellSize = 64.0;

  // ── Level gating ───────────────────────────────────────────────────────
  int currentUserLevel = 1;

  // ── Camera mode ────────────────────────────────────────────────────────
  GardenCameraMode _cameraMode = GardenCameraMode.architect;
  GardenCameraMode get cameraMode => _cameraMode;

  /// Callback when camera mode changes (for UI updates).
  void Function(GardenCameraMode mode)? onCameraModeChanged;

  // Transition state
  bool _transitioning = false;
  double _transitionProgress = 0; // 0 = architect, 1 = immersion
  double _transitionTarget = 0;
  static const _transitionDuration = 1.2;

  // Parallax layer offsets (accumulated from camera movement)
  Vector2 _parallaxOffset = Vector2.zero();

  // Architect camera positions
  late Vector2 _architectPos;
  static const _architectZoom = 1.0;

  // Immersion camera positions
  late Vector2 _immersionPos;
  static const _immersionZoom = 1.6;

  // ── Neglect state ──────────────────────────────────────────────────────
  GardenNeglectState neglectState = GardenNeglectState.flourishing;
  String? sacredCentreSlotKey; // "x,y" of the sacred slot

  GardenNeglectOverlay? _neglectOverlay;

  void setNeglectState(GardenNeglectState state) {
    neglectState = state;
    _neglectOverlay?.neglectState = state;
  }

  void setSacredCentreSlot(String? slotKey) {
    sacredCentreSlotKey = slotKey;
  }

  // Zone boundaries (cell ranges for each level)
  // Level 1: Al-Rawdah — centre 8x8 (cells 6-13)
  // Level 2: Al-Firdaws — centre 12x12 (cells 4-15)
  // Level 3: Al-Na'im — centre 16x16 (cells 2-17)
  // Level 4: Jannat al-Ma'wa — full 20x20 (cells 0-19)

  /// Whether a cell is unlocked for the current user level.
  bool isCellUnlocked(int x, int y) {
    final cx = 9.5; // centre of 20x20
    final cy = 9.5;
    final dx = (x - cx).abs();
    final dy = (y - cy).abs();
    final dist = max(dx, dy); // Chebyshev distance

    switch (currentUserLevel) {
      case 1:
        return dist <= 3.5; // 8x8 centre (6-13)
      case 2:
        return dist <= 5.5; // 12x12 (4-15)
      case 3:
        return dist <= 7.5; // 16x16 (2-17)
      default:
        return true; // Level 4+: full grid
    }
  }

  /// Returns the zone level a cell belongs to (1-4).
  int _cellZone(int x, int y) {
    final cx = 9.5;
    final cy = 9.5;
    final dist = max((x - cx).abs(), (y - cy).abs());
    if (dist <= 3.5) return 1;
    if (dist <= 5.5) return 2;
    if (dist <= 7.5) return 3;
    return 4;
  }

  void setUserLevel(int level) {
    currentUserLevel = level.clamp(1, 4);
  }

  // ── Placed items ────────────────────────────────────────────────────────
  final Map<String, GardenAssetComponent> _placedAssets = {};
  final List<QuestionMarkComponent> _questionMarks = [];

  // ── Callbacks (set by the screen that hosts this game) ──────────────────
  void Function(int x, int y)? onEmptySpotTapped;
  void Function(int x, int y, String assetId)? onAssetLongPressed;
  void Function(String questionMarkId)? onQuestionMarkTapped;
  void Function(String questionMarkId)? onQuestionMarkExpired;

  // ── Camera helpers ──────────────────────────────────────────────────────
  late final World _world;
  late final CameraComponent _cam;
  double _currentZoom = 1.0;

  // Track whether a scale gesture is active.
  bool _isScaling = false;

  // ── Internal timer for glow animation ──────────────────────────────────
  double _glowTime = 0;

  // ── Particle cap (max 100 inner garden particles) ──────────────────────
  int _activeParticleCount = 0;
  static const _maxParticles = 100;

  // ── Convenience ─────────────────────────────────────────────────────────
  double get _worldSize => gridSize * cellSize; // 1280

  static String _key(int x, int y) => '$x,$y';

  // ── Camera mode switching ────────────────────────────────────────────────

  void switchToImmersion() {
    if (_cameraMode == GardenCameraMode.immersion || _transitioning) return;
    _cameraMode = GardenCameraMode.immersion;
    _transitioning = true;
    _transitionTarget = 1.0;
    onCameraModeChanged?.call(_cameraMode);
  }

  void switchToArchitect() {
    if (_cameraMode == GardenCameraMode.architect || _transitioning) return;
    _cameraMode = GardenCameraMode.architect;
    _transitioning = true;
    _transitionTarget = 0.0;
    onCameraModeChanged?.call(_cameraMode);
  }

  void toggleCameraMode() {
    if (_cameraMode == GardenCameraMode.architect) {
      switchToImmersion();
    } else {
      switchToArchitect();
    }
  }

  void _updateCameraTransition(double dt) {
    if (!_transitioning) return;

    final step = dt / _transitionDuration;
    if (_transitionTarget > _transitionProgress) {
      _transitionProgress = (_transitionProgress + step).clamp(0.0, 1.0);
    } else {
      _transitionProgress = (_transitionProgress - step).clamp(0.0, 1.0);
    }

    // Ease-in-out curve
    final t = _easeInOut(_transitionProgress);

    // Interpolate position: architect → immersion (lower + offset)
    final targetPos = Vector2.zero()
      ..setFrom(_architectPos)
      ..lerp(_immersionPos, t);
    _cam.viewfinder.position = targetPos;

    // Interpolate zoom
    final targetZoom = _architectZoom + (_immersionZoom - _architectZoom) * t;
    _cam.viewfinder.zoom = targetZoom;
    _currentZoom = targetZoom;

    // Check if transition complete
    if ((_transitionProgress - _transitionTarget).abs() < 0.001) {
      _transitionProgress = _transitionTarget;
      _transitioning = false;
    }
  }

  double _easeInOut(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - (-2 * t + 2) * (-2 * t + 2) * (-2 * t + 2) / 2;
  }

  // ── Parallax layer offsets ──────────────────────────────────────────────

  /// Returns a position offset for a parallax layer.
  /// [speed] 0.0 = static, 1.0 = moves with camera.
  Vector2 parallaxPosition(double speed) {
    return _parallaxOffset * speed;
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _world = World();
    _cam = CameraComponent(world: _world);
    addAll([_world, _cam]);

    // Set up camera positions for both modes.
    _architectPos = Vector2(_worldSize / 2, _worldSize / 2);
    _immersionPos = Vector2(_worldSize / 2, _worldSize / 2 + _worldSize * 0.15);

    // Centre camera on the garden (architect default).
    _cam.viewfinder.position = _architectPos.clone();
    _cam.viewfinder.zoom = _architectZoom;

    // Background grid with zones.
    _world.add(ZonedGardenBackground(game: this));

    // Neglect visual overlay (renders on top of background, under assets).
    _neglectOverlay = GardenNeglectOverlay(
      game: this,
      neglectState: neglectState,
    );
    _world.add(_neglectOverlay!);

    // Question marks loaded dynamically via loadQuestionMarks()
  }

  @override
  void update(double dt) {
    super.update(dt);
    _glowTime += dt;
    _updateCameraTransition(dt);

    // Track parallax offset from camera centre
    _parallaxOffset = _cam.viewfinder.position - _architectPos;

    // In immersion: intensify question marks based on camera distance
    if (_cameraMode == GardenCameraMode.immersion) {
      final camPos = _cam.viewfinder.position;
      for (final qm in _questionMarks) {
        final qmPos = Vector2(
          qm.gridX * cellSize + cellSize / 2,
          qm.gridY * cellSize + cellSize / 2,
        );
        final dist = camPos.distanceTo(qmPos);
        // Intensify glow when within 3 cells
        final proximity = (1.0 - (dist / (cellSize * 3)).clamp(0.0, 1.0));
        qm.immersionGlow = proximity;
      }
    }
  }

  // ── Scale / Pan / Zoom ──────────────────────────────────────────────────

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    _isScaling = true;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    if (_transitioning) return;

    if (event.pointerCount == 1) {
      // Single finger — pan camera with boundary clamping.
      final newPos = _cam.viewfinder.position - event.localDelta / _currentZoom;
      _cam.viewfinder.position = _clampCameraPosition(newPos);

      // In immersion: vertical drag adjusts zoom slightly (tilt effect)
      if (_cameraMode == GardenCameraMode.immersion) {
        final dy = event.localDelta.y / size.y;
        final newZoom = (_currentZoom + dy * 0.3).clamp(1.4, 1.8).toDouble();
        _cam.viewfinder.zoom = newZoom;
        _currentZoom = newZoom;
      }
    } else {
      // Multi-finger — zoom.
      final minZoom = _cameraMode == GardenCameraMode.immersion ? 1.2 : 0.5;
      final maxZoom = _cameraMode == GardenCameraMode.immersion ? 2.0 : 2.5;
      final newZoom = (_currentZoom * event.scale).clamp(minZoom, maxZoom).toDouble();

      // In immersion: pinch fully out → switch to architect
      if (_cameraMode == GardenCameraMode.immersion && newZoom <= 1.2) {
        switchToArchitect();
        return;
      }

      _cam.viewfinder.zoom = newZoom;
      _currentZoom = newZoom;
    }
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    _isScaling = false;
  }

  Vector2 _clampCameraPosition(Vector2 pos) {
    final halfViewW = (size.x / 2) / _currentZoom;
    final halfViewH = (size.y / 2) / _currentZoom;
    return Vector2(
      pos.x.clamp(halfViewW, _worldSize - halfViewW),
      pos.y.clamp(halfViewH, _worldSize - halfViewH),
    );
  }

  // ── Double-tap to zoom in slightly ──────────────────────────────────────

  @override
  void onDoubleTapUp(DoubleTapEvent event) {
    if (_cameraMode == GardenCameraMode.immersion) {
      // Double-tap in immersion → switch back to architect
      switchToArchitect();
    } else {
      _currentZoom = 1.2;
      _cam.viewfinder.zoom = 1.2;
      _cam.viewfinder.position = _architectPos.clone();
    }
  }

  // ── Tap detection ──────────────────────────────────────────────────────

  @override
  void onTapUp(TapUpEvent event) {
    if (_isScaling) return;

    final canvasPos = event.canvasPosition;
    final worldPos = _cam.viewfinder.transform.globalToLocal(canvasPos);

    final gx = (worldPos.x / cellSize).floor();
    final gy = (worldPos.y / cellSize).floor();

    if (gx < 0 || gx >= gridSize || gy < 0 || gy >= gridSize) return;

    // Block interaction with locked cells
    if (!isCellUnlocked(gx, gy)) return;

    final key = _key(gx, gy);

    // Check for question mark.
    for (final qm in _questionMarks) {
      if (qm.gridX == gx && qm.gridY == gy) {
        onQuestionMarkTapped?.call(qm.questionMarkId);
        return;
      }
    }

    // Check placed asset — tap shows gold ring pulse.
    if (_placedAssets.containsKey(key)) {
      _spawnOccupiedPulse(gx, gy);
      return;
    }

    // Empty unlocked spot — spawn particle burst then callback.
    _spawnEmptySlotBurst(gx, gy);
    onEmptySpotTapped?.call(gx, gy);
  }

  // ── Tap feedback particles ─────────────────────────────────────────────

  void _spawnEmptySlotBurst(int x, int y) {
    final centre = Vector2(x * cellSize + cellSize / 2, y * cellSize + cellSize / 2);
    for (var i = 0; i < 8; i++) {
      if (_activeParticleCount >= _maxParticles) break;
      final angle = i * pi / 4;
      _activeParticleCount++;
      _world.add(_NoorParticle(
        startPos: centre.clone(),
        dir: angle,
        travelDistance: cellSize * 0.5,
        onRemoved: () => _activeParticleCount--,
      ));
    }
  }

  void _spawnOccupiedPulse(int x, int y) {
    final centre = Vector2(x * cellSize + cellSize / 2, y * cellSize + cellSize / 2);
    _world.add(_GoldRingPulse(centre: centre, radius: cellSize * 0.4));
  }

  // ── Public API ─────────────────────────────────────────────────────────

  /// Place a new garden asset at [x],[y].
  void placeAsset(int x, int y, String assetId, int vitality) {
    final key = _key(x, y);
    if (_placedAssets.containsKey(key)) return;

    _questionMarks.removeWhere((qm) {
      if (qm.gridX == x && qm.gridY == y) {
        qm.removeFromParent();
        return true;
      }
      return false;
    });

    final comp = GardenAssetComponent(
      assetId: assetId,
      gridX: x,
      gridY: y,
      vitality: vitality,
      cellSize: cellSize,
      onLongPress: () => onAssetLongPressed?.call(x, y, assetId),
    );
    _placedAssets[key] = comp;
    _world.add(comp);
  }

  /// Remove asset at [x],[y].
  void removeAsset(int x, int y) {
    final key = _key(x, y);
    final comp = _placedAssets.remove(key);
    comp?.removeFromParent();
  }

  /// Move asset from one cell to another.
  void moveAsset(int fromX, int fromY, int toX, int toY) {
    final fromKey = _key(fromX, fromY);
    final comp = _placedAssets.remove(fromKey);
    if (comp == null) return;

    comp.position = Vector2(toX * cellSize, toY * cellSize);
    comp.gridX = toX;
    comp.gridY = toY;
    _placedAssets[_key(toX, toY)] = comp;
  }

  /// Update the vitality of the asset at [x],[y].
  void updateVitality(int x, int y, int vitality) {
    final key = _key(x, y);
    _placedAssets[key]?.updateVitality(vitality);
  }

  /// Load question marks from Firestore data (called from screen).
  /// Each entry: { 'id': qmId, 'positionX': int, 'positionY': int,
  ///   'contentType': 'dua'|'history', 'expiresAt': DateTime? }
  void loadQuestionMarks(List<Map<String, dynamic>> qmData) {
    // Remove existing QMs that are no longer in the data
    final activeIds = qmData.map((d) => d['id'] as String).toSet();
    _questionMarks.removeWhere((qm) {
      if (!activeIds.contains(qm.questionMarkId)) {
        qm.fadeOutAndRemove();
        onQuestionMarkExpired?.call(qm.questionMarkId);
        return true;
      }
      return false;
    });

    // Add new QMs not yet on the grid
    final existingIds = _questionMarks.map((qm) => qm.questionMarkId).toSet();
    for (final data in qmData) {
      final id = data['id'] as String? ?? '';
      if (id.isEmpty || existingIds.contains(id)) continue;

      final x = (data['positionX'] as num?)?.toInt() ?? 10;
      final y = (data['positionY'] as num?)?.toInt() ?? 10;
      final contentType = data['contentType'] as String? ?? 'dua';
      final expiresAt = data['expiresAt'] as DateTime?;

      final qm = QuestionMarkComponent(
        gridX: x,
        gridY: y,
        cellSize: cellSize,
        questionMarkId: id,
        contentType: contentType,
        expiresAt: expiresAt,
      );
      _questionMarks.add(qm);
      _world.add(qm);
    }
  }

  /// Expire a specific question mark with gentle fade-out.
  void expireQuestionMark(String qmId) {
    final qm = _questionMarks.where((q) => q.questionMarkId == qmId).firstOrNull;
    if (qm != null) {
      qm.fadeOutAndRemove();
      _questionMarks.remove(qm);
    }
  }

  /// Play the discovered asset reveal animation at a grid position.
  /// Called after SacredVideoScreen returns with success.
  void playDiscoveredAssetReveal(
    int x, int y, String assetTemplateId, {
    VoidCallback? onRevealComplete,
  }) {
    // Step 1: Golden burst at position
    final centre = Vector2(x * cellSize + cellSize / 2, y * cellSize + cellSize / 2);
    for (var i = 0; i < 12; i++) {
      if (_activeParticleCount >= _maxParticles) break;
      _activeParticleCount++;
      _world.add(_NoorParticle(
        startPos: centre.clone(),
        dir: i * pi / 6,
        travelDistance: cellSize * 0.7,
        onRemoved: () => _activeParticleCount--,
      ));
    }

    // Ground glow
    _world.add(_DiscoveryGroundGlow(position: centre.clone(), cellSize: cellSize));

    // Step 2: Asset emerges from earth (delayed 0.3s)
    _world.add(_EmergingAssetComponent(
      assetTemplateId: assetTemplateId,
      gridX: x,
      gridY: y,
      cellSize: cellSize,
      onEmergenceComplete: () {
        // Step 4: Place the permanent asset
        placeAsset(x, y, assetTemplateId, 100);

        // Mark it with discovered glow
        final key = _key(x, y);
        _placedAssets[key]?.isDiscovered = true;

        // Final particle burst
        for (var i = 0; i < 8; i++) {
          if (_activeParticleCount >= _maxParticles) break;
          _activeParticleCount++;
          _world.add(_NoorParticle(
            startPos: centre.clone(),
            dir: i * pi / 4,
            travelDistance: cellSize * 0.5,
            onRemoved: () => _activeParticleCount--,
          ));
        }

        onRevealComplete?.call();
      },
    ));
  }

  /// Load the entire garden state from a map of grid spots.
  void loadState(Map<String, dynamic> gridSpots) {
    for (final comp in _placedAssets.values) {
      comp.removeFromParent();
    }
    _placedAssets.clear();

    gridSpots.forEach((key, value) {
      final parts = key.split(',');
      if (parts.length != 2) return;
      final x = int.tryParse(parts[0]);
      final y = int.tryParse(parts[1]);
      if (x == null || y == null) return;

      final data = value as Map<String, dynamic>;
      placeAsset(
        x, y,
        data['assetId'] as String? ?? 'tree_basic',
        data['vitality'] as int? ?? 100,
      );
    });
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ZonedGardenBackground — 4-zone grass with locked zone overlay + glow dots
// ═══════════════════════════════════════════════════════════════════════════

class ZonedGardenBackground extends Component with HasGameReference<GardenGame> {
  ZonedGardenBackground({required this.game});

  @override
  final GardenGame game;

  // Zone colours
  static const _zone1A = Color(0xFF4CAF50); // Al-Rawdah — lush green
  static const _zone1B = Color(0xFF2E7D32);
  static const _zone2A = Color(0xFF66BB6A); // Al-Firdaws — lighter green, golden tint
  static const _zone2B = Color(0xFF558B2F);
  static const _zone3A = Color(0xFF1B5E20); // Al-Na'im — deep emerald
  static const _zone3B = Color(0xFF4A148C); // purple shimmer
  static const _zone4A = Color(0xFF00695C); // Jannat al-Ma'wa — teal-blue
  static const _zone4B = Color(0xFF004D40);

  static const _lockedOverlay = Color(0x73000000); // 0.45 opacity black
  static const _glowGold = Color(0xFFC9942A);

  late final Paint _gridLinePaint;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _gridLinePaint = Paint()
      ..color = const Color(0x1A4CAF50)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
  }

  @override
  void render(Canvas canvas) {
    final ws = game._worldSize;
    final cs = game.cellSize;
    final gs = game.gridSize;
    final level = game.currentUserLevel;
    final time = game._glowTime;

    // ── Draw each cell with zone-appropriate colour ─────────────────────
    for (var y = 0; y < gs; y++) {
      for (var x = 0; x < gs; x++) {
        final zone = game._cellZone(x, y);
        final rect = Rect.fromLTWH(x * cs, y * cs, cs, cs);

        // Zone base colour
        Color baseColor;
        switch (zone) {
          case 1:
            final t = ((x + y) % 3) / 3.0;
            baseColor = Color.lerp(_zone1A, _zone1B, t)!;
          case 2:
            final t = ((x + y) % 4) / 4.0;
            baseColor = Color.lerp(_zone2A, _zone2B, t)!;
            // Golden tint
            baseColor = Color.lerp(baseColor, const Color(0xFFFFD54F), 0.08)!;
          case 3:
            final t = ((x * 3 + y * 7) % 5) / 5.0;
            baseColor = Color.lerp(_zone3A, _zone3B, t * 0.15)!;
          default:
            final t = ((x + y) % 3) / 3.0;
            baseColor = Color.lerp(_zone4A, _zone4B, t)!;
        }

        canvas.drawRect(rect, Paint()..color = baseColor.withValues(alpha: 0.45));

        // ── Locked zone overlay ────────────────────────────────────────
        if (zone > level) {
          // Dark overlay
          canvas.drawRect(rect, Paint()..color = _lockedOverlay);

          // Animated shimmer band (diagonal sweep)
          final shimmerPhase = (time * 0.33 + (x + y) * 0.05) % 1.0;
          final shimmerOpacity = (sin(shimmerPhase * pi * 2) * 0.08 + 0.04)
              .clamp(0.0, 0.12);
          canvas.drawRect(
            rect,
            Paint()..color = Color.fromRGBO(255, 255, 255, shimmerOpacity),
          );
        }

        // ── Empty slot glow circles (unlocked & empty) ────────────────
        if (zone <= level) {
          final key = '$x,$y';
          final isOccupied = game._placedAssets.containsKey(key);
          final hasQm = game._questionMarks.any(
              (qm) => qm.gridX == x && qm.gridY == y);

          if (!isOccupied && !hasQm) {
            // Pulsing glow with per-cell phase offset
            final phase = (time / 1.8 + (x * 7 + y * 13) * 0.1) % 1.0;
            final pulseAlpha = 0.10 + sin(phase * pi * 2) * 0.09;

            final centre = Offset(x * cs + cs / 2, y * cs + cs / 2);
            final radius = cs * 0.35;

            // Outer glow
            canvas.drawCircle(
              centre,
              radius + 4,
              Paint()
                ..color = _glowGold.withValues(alpha: pulseAlpha * 0.5)
                ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
            );

            // Inner circle
            canvas.drawCircle(
              centre,
              radius,
              Paint()..color = _glowGold.withValues(alpha: pulseAlpha),
            );
          }
        }
      }
    }

    // ── Feathered zone boundaries ─────────────────────────────────────────
    // Soft gradient fade at the edge of each locked boundary
    for (var zone = 2; zone <= 4; zone++) {
      if (zone <= level) continue; // Don't fade unlocked zones

      // Find boundary cells and draw a feather gradient
      for (var y = 0; y < gs; y++) {
        for (var x = 0; x < gs; x++) {
          final thisZone = game._cellZone(x, y);
          if (thisZone != zone) continue;

          // Check if any neighbour is in the previous (unlocked) zone
          var isEdge = false;
          for (final d in [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
            final nx = x + d[0];
            final ny = y + d[1];
            if (nx >= 0 && nx < gs && ny >= 0 && ny < gs) {
              if (game._cellZone(nx, ny) < zone) {
                isEdge = true;
                break;
              }
            }
          }

          if (isEdge) {
            final rect = Rect.fromLTWH(x * cs, y * cs, cs, cs);
            // Soften the edge with partial transparency
            canvas.drawRect(
              rect,
              Paint()..color = const Color(0x20000000),
            );
          }
        }
      }
    }

    // ── Grid lines ────────────────────────────────────────────────────────
    for (var i = 0; i <= gs; i++) {
      final offset = i * cs;
      canvas.drawLine(Offset(offset, 0), Offset(offset, ws), _gridLinePaint);
      canvas.drawLine(Offset(0, offset), Offset(ws, offset), _gridLinePaint);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GardenAssetComponent — a single placed garden asset
// ═══════════════════════════════════════════════════════════════════════════

class GardenAssetComponent extends PositionComponent with HasGameReference {
  GardenAssetComponent({
    required this.assetId,
    required this.gridX,
    required this.gridY,
    required int vitality,
    required this.cellSize,
    this.onLongPress,
  })  : _vitality = vitality,
        super(
          position: Vector2(gridX * cellSize, gridY * cellSize),
          size: Vector2.all(cellSize),
          anchor: Anchor.topLeft,
        );

  final String assetId;
  int gridX;
  int gridY;
  final double cellSize;
  final VoidCallback? onLongPress;

  int _vitality;
  int get vitality => _vitality;

  /// True if this asset was discovered from a question mark (cannot be sold).
  bool isDiscovered = false;

  final Paint _barBgPaint = Paint()..color = const Color(0x44000000);
  final Paint _barPaint = Paint();

  double _bobPhase = 0;

  void updateVitality(int v) {
    _vitality = v.clamp(0, 100);
    children.whereType<Effect>().forEach((e) => e.removeFromParent());
    _applyVitalityEffects();
  }

  void _applyVitalityEffects() {
    if (_vitality > 70) {
      // Healthy — subtle idle bob in update()
    } else if (_vitality > 30) {
      // Slightly desaturated
    } else if (_vitality > 0) {
      add(OpacityEffect.to(
        0.5,
        EffectController(
          duration: 1.0,
          reverseDuration: 1.0,
          infinite: true,
        ),
      ));
    } else {
      scale = Vector2.all(0.6);
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _applyVitalityEffects();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_vitality > 70) {
      _bobPhase += dt * 2;
    }
  }

  @override
  void render(Canvas canvas) {
    // Compute glow intensity for Sacred Centre
    double glowIntensity = 0.0;
    if (game is GardenGame) {
      final g = game as GardenGame;
      final slotKey = '$gridX,$gridY';
      if (g.sacredCentreSlotKey == slotKey) {
        glowIntensity = 1.0;
      }
    }

    // Convert vitality (0-100) to health state (1-5)
    final healthState = _vitality > 80 ? 1
        : _vitality > 60 ? 2
        : _vitality > 40 ? 3
        : _vitality > 10 ? 4
        : 5;

    // Idle bob offset
    final bobOffset = _vitality > 70 ? sin(_bobPhase) * 2.0 : 0.0;

    // Animation value from bob phase (normalized 0-1)
    final animVal = (_bobPhase / (pi * 2)) % 1.0;

    final padding = cellSize * 0.05;
    final paintSize = Size(cellSize - padding * 2, cellSize - padding * 2);

    canvas.save();
    canvas.translate(padding, padding + bobOffset);

    // Render the asset using the painter registry
    final painter = JannahAssetPainterRegistry.getPainter(
      assetId,
      healthState: healthState,
      glowIntensity: glowIntensity,
      animationValue: animVal,
    );
    painter.paint(canvas, paintSize);

    canvas.restore();

    // ── Discovered asset golden base ring ─────────────────────────────────
    if (isDiscovered) {
      canvas.drawCircle(
        Offset(cellSize / 2, cellSize * 0.88),
        cellSize * 0.35,
        Paint()
          ..color = AppColors.noorGold.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // ── Vitality bar at bottom ────────────────────────────────────────────
    final assetW = cellSize - padding * 2;
    const barHeight = 4.0;
    final barY = cellSize - barHeight - 2;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(padding, barY, assetW, barHeight),
        const Radius.circular(2),
      ),
      _barBgPaint,
    );

    final ratio = _vitality / 100.0;
    Color barColor;
    if (ratio > 0.6) {
      barColor = Color.lerp(Colors.yellow, Colors.green, (ratio - 0.6) / 0.4)!;
    } else if (ratio > 0.3) {
      barColor = Color.lerp(Colors.orange, Colors.yellow, (ratio - 0.3) / 0.3)!;
    } else {
      barColor = Color.lerp(Colors.red, Colors.orange, ratio / 0.3)!;
    }
    _barPaint.color = barColor;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(padding, barY, assetW * ratio, barHeight),
        const Radius.circular(2),
      ),
      _barPaint,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// QuestionMarkComponent
// ═══════════════════════════════════════════════════════════════════════════

class QuestionMarkComponent extends PositionComponent with HasGameReference {
  QuestionMarkComponent({
    required this.gridX,
    required this.gridY,
    required this.cellSize,
    required this.questionMarkId,
    this.contentType = 'dua',
    this.expiresAt,
  }) : super(
          position: Vector2(
            gridX * cellSize + cellSize / 2,
            gridY * cellSize + cellSize / 2,
          ),
          size: Vector2.all(cellSize * 0.5),
          anchor: Anchor.center,
        );

  final int gridX;
  final int gridY;
  final double cellSize;
  final String questionMarkId;
  final String contentType; // 'dua' | 'history'
  final DateTime? expiresAt;

  /// Extra glow intensity when camera is near in immersion mode (0.0-1.0).
  double immersionGlow = 0.0;

  double _time = 0;
  bool _expired = false;

  late final TextPaint _textPaint;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _textPaint = TextPaint(
      style: TextStyle(
        color: AppColors.noorGold,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    );

    add(ScaleEffect.to(
      Vector2.all(1.15),
      EffectController(
        duration: 0.9,
        reverseDuration: 0.9,
        infinite: true,
        curve: Curves.easeInOut,
      ),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;

    // Check expiry
    if (!_expired && expiresAt != null && DateTime.now().isAfter(expiresAt!)) {
      _expired = true;
      fadeOutAndRemove();
    }
  }

  @override
  void render(Canvas canvas) {
    final centre = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    // Pulsing glow cycle (1.2s)
    final pulse = (sin(_time / 1.2 * pi * 2) * 0.3 + 0.7).clamp(0.4, 1.0);

    // Immersion mode: intensified glow + ascending particles
    if (immersionGlow > 0) {
      // Large radial glow
      canvas.drawCircle(
        centre,
        radius + 12 + immersionGlow * 8,
        Paint()
          ..color = AppColors.noorGold.withValues(alpha: immersionGlow * 0.45)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
      );

      // Ascending light motes
      for (var i = 0; i < 4; i++) {
        final moteY = centre.dy - ((_time * 15 + i * 8) % 30);
        final moteX = centre.dx + sin(_time * 2 + i * 1.5) * 5;
        final moteAlpha = (1.0 - (centre.dy - moteY) / 30) * immersionGlow * 0.5;
        canvas.drawCircle(
          Offset(moteX, moteY),
          1.5,
          Paint()
            ..color = AppColors.gardenCelestial.withValues(alpha: moteAlpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
        );
      }

      // Larger "?" in immersion
      final immPaint = TextPaint(
        style: TextStyle(
          color: AppColors.noorGold.withValues(alpha: pulse),
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      );
      immPaint.render(canvas, '?', Vector2(centre.dx - 8, centre.dy - 16));
      return;
    }

    // Architect view: glowing golden dot
    // Outer glow
    canvas.drawCircle(
      centre,
      radius + 6,
      Paint()
        ..color = AppColors.noorGoldLight.withValues(alpha: 0.15 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Core dot
    canvas.drawCircle(
      centre,
      8,
      Paint()..color = AppColors.noorGold.withValues(alpha: pulse * 0.8),
    );

    // Small "?" on top
    _textPaint.render(canvas, '?', Vector2(centre.dx - 6, centre.dy - 12));
  }

  /// Dissolve animation — particles scatter outward then fade.
  void reveal({VoidCallback? onComplete}) {
    add(ScaleEffect.to(
      Vector2.all(1.8),
      EffectController(duration: 0.35, curve: Curves.easeOut),
    ));
    add(OpacityEffect.to(
      0.0,
      EffectController(duration: 0.5, curve: Curves.easeIn),
      onComplete: () {
        removeFromParent();
        onComplete?.call();
      },
    ));
  }

  /// Gentle fade-out for expiry or removal.
  void fadeOutAndRemove() {
    add(OpacityEffect.to(
      0.0,
      EffectController(duration: 0.8, curve: Curves.easeOut),
      onComplete: () => removeFromParent(),
    ));
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _NoorParticle — gold dot that expands outward from a tap and fades
// ═══════════════════════════════════════════════════════════════════════════

class _NoorParticle extends PositionComponent {
  _NoorParticle({
    required Vector2 startPos,
    required this.dir,
    required this.travelDistance,
    this.onRemoved,
  }) : super(
          position: startPos,
          size: Vector2.all(6),
          anchor: Anchor.center,
        );

  final double dir;
  final double travelDistance;
  final VoidCallback? onRemoved;
  double _life = 0;
  double _alpha = 1.0;
  static const _duration = 0.4;

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    if (_life >= _duration) {
      onRemoved?.call();
      removeFromParent();
      return;
    }
    final t = _life / _duration;
    position += Vector2(cos(dir), sin(dir)) * (travelDistance * dt / _duration);
    _alpha = 1.0 - t;
    scale = Vector2.all(1.0 - t * 0.5);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      3,
      Paint()
        ..color = const Color(0xFFC9942A).withValues(alpha: _alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _GoldRingPulse — brief gold ring expanding outward on occupied cell tap
// ═══════════════════════════════════════════════════════════════════════════

class _GoldRingPulse extends PositionComponent {
  _GoldRingPulse({required this.centre, required this.radius})
      : super(
          position: centre,
          size: Vector2.all(radius * 3),
          anchor: Anchor.center,
        );

  final Vector2 centre;
  final double radius;
  double _life = 0;
  static const _duration = 0.35;

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    if (_life >= _duration) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final t = (_life / _duration).clamp(0.0, 1.0);
    final currentRadius = radius * (1.0 + t * 0.4);
    final alpha = (1.0 - t) * 0.6;

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      currentRadius,
      Paint()
        ..color = const Color(0xFFC9942A).withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * (1.0 - t),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GardenNeglectOverlay — visual effects layer driven by neglect state
// ═══════════════════════════════════════════════════════════════════════════

class GardenNeglectOverlay extends Component with HasGameReference<GardenGame> {
  GardenNeglectOverlay({
    required this.game,
    required this.neglectState,
  });

  @override
  final GardenGame game;
  GardenNeglectState neglectState;

  double _time = 0;

  // Radiant particles (reused positions)
  late final List<_RadiantParticle> _radiantParticles;
  // Dry leaves
  late final List<_DriftingLeaf> _dryLeaves;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final rng = Random(42);
    final ws = game._worldSize;

    _radiantParticles = List.generate(40, (i) => _RadiantParticle(
      x: rng.nextDouble() * ws,
      y: rng.nextDouble() * ws,
      speed: 15 + rng.nextDouble() * 25,
      size: 2 + rng.nextDouble() * 3,
      phase: rng.nextDouble() * pi * 2,
    ));

    _dryLeaves = List.generate(15, (i) => _DriftingLeaf(
      x: rng.nextDouble() * ws,
      y: rng.nextDouble() * ws,
      speed: 10 + rng.nextDouble() * 20,
      swayAmp: 20 + rng.nextDouble() * 30,
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
    final ws = game._worldSize;

    // ── Grey overlay (resting / longing) ──────────────────────────────────
    final overlayAlpha = neglectState.overlayOpacity;
    if (overlayAlpha > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, ws, ws),
        Paint()..color = Color.fromRGBO(158, 158, 158, overlayAlpha),
      );
    }

    // ── Desaturation overlay for withering ────────────────────────────────
    if (neglectState.desaturation > 0.5) {
      // Draw a semi-transparent grey wash to simulate desaturation
      final desat = neglectState.desaturation;
      canvas.drawRect(
        Rect.fromLTWH(0, 0, ws, ws),
        Paint()..color = Color.fromRGBO(120, 120, 120, desat * 0.35),
      );
    }

    // ── Radiant golden particles (radiant state) ─────────────────────────
    if (neglectState.showRadiantParticles) {
      for (final p in _radiantParticles) {
        final y = (p.y - _time * p.speed) % ws;
        final x = p.x + sin(_time * 0.5 + p.phase) * 12;
        final alpha = (sin(_time * 2 + p.phase) * 0.3 + 0.5).clamp(0.2, 0.8);

        canvas.drawCircle(
          Offset(x, y),
          p.size,
          Paint()
            ..color = const Color(0xFFFFE44D).withValues(alpha: alpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
        );
      }
    }

    // ── Dry leaves drifting down (longing state) ─────────────────────────
    if (neglectState.showDryLeaves) {
      for (final leaf in _dryLeaves) {
        final y = (leaf.y + _time * leaf.speed) % ws;
        final x = leaf.x + sin(_time * 0.7 + leaf.phase) * leaf.swayAmp;
        final rotation = _time * 1.5 + leaf.phase;

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rotation);

        // Simple leaf shape
        final leafPath = Path()
          ..moveTo(0, -5)
          ..quadraticBezierTo(6, -2, 0, 5)
          ..quadraticBezierTo(-6, -2, 0, -5);

        canvas.drawPath(
          leafPath,
          Paint()..color = const Color(0xFF8D6E63).withValues(alpha: 0.5),
        );
        canvas.restore();
      }
    }

    // ── Cracked earth textures (longing + withering) ─────────────────────
    if (neglectState.showCrackedEarth) {
      final crackPaint = Paint()
        ..color = const Color(0xFF795548).withValues(
            alpha: neglectState == GardenNeglectState.withering ? 0.2 : 0.1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;

      final cs = game.cellSize;
      final gs = game.gridSize;
      final rng = Random(7); // deterministic cracks

      // Draw cracks in water-adjacent areas
      for (var y = 0; y < gs; y++) {
        for (var x = 0; x < gs; x++) {
          if ((x + y * 3) % 7 != 0) continue; // sparse distribution

          final cx = x * cs + cs / 2;
          final cy = y * cs + cs / 2;

          // Small crack pattern
          for (var c = 0; c < 3; c++) {
            final angle = rng.nextDouble() * pi * 2;
            final len = cs * (0.2 + rng.nextDouble() * 0.3);
            canvas.drawLine(
              Offset(cx, cy),
              Offset(cx + cos(angle) * len, cy + sin(angle) * len),
              crackPaint,
            );
          }
        }
      }
    }

    // ── Sacred centre ground glow (always, regardless of state) ──────────
    if (game.sacredCentreSlotKey != null) {
      final parts = game.sacredCentreSlotKey!.split(',');
      if (parts.length == 2) {
        final sx = int.tryParse(parts[0]);
        final sy = int.tryParse(parts[1]);
        if (sx != null && sy != null) {
          final cs = game.cellSize;
          final centre = Offset(sx * cs + cs / 2, sy * cs + cs / 2);

          // Pulsing ground glow
          final pulse = sin(_time * 1.5) * 0.08 + 0.35;
          canvas.drawCircle(
            centre,
            cs * 0.6,
            Paint()
              ..color = Color.fromRGBO(255, 228, 77, pulse)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
          );
        }
      }
    }
  }
}

class _RadiantParticle {
  const _RadiantParticle({
    required this.x,
    required this.y,
    required this.speed,
    required this.size,
    required this.phase,
  });
  final double x, y, speed, size, phase;
}

class _DriftingLeaf {
  const _DriftingLeaf({
    required this.x,
    required this.y,
    required this.speed,
    required this.swayAmp,
    required this.phase,
  });
  final double x, y, speed, swayAmp, phase;
}

// ═══════════════════════════════════════════════════════════════════════════
// _DiscoveryGroundGlow — golden ground glow at QM discovery point
// ═══════════════════════════════════════════════════════════════════════════

class _DiscoveryGroundGlow extends PositionComponent {
  _DiscoveryGroundGlow({required Vector2 position, required this.cellSize})
      : super(
          position: position,
          size: Vector2.all(cellSize * 1.5),
          anchor: Anchor.center,
        );

  final double cellSize;
  double _life = 0;
  static const _duration = 2.0;

  @override
  void update(double dt) {
    super.update(dt);
    _life += dt;
    if (_life >= _duration) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final t = (_life / _duration).clamp(0.0, 1.0);
    final alpha = (1.0 - t) * 0.4;
    final r = cellSize * 0.5 * (0.8 + t * 0.4);

    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      r,
      Paint()
        ..color = Color.fromRGBO(255, 228, 77, alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// _EmergingAssetComponent — asset grows from the earth during discovery
// ═══════════════════════════════════════════════════════════════════════════

class _EmergingAssetComponent extends PositionComponent {
  _EmergingAssetComponent({
    required this.assetTemplateId,
    required this.gridX,
    required this.gridY,
    required this.cellSize,
    this.onEmergenceComplete,
  }) : super(
          position: Vector2(gridX * cellSize, gridY * cellSize),
          size: Vector2.all(cellSize),
          anchor: Anchor.topLeft,
        );

  final String assetTemplateId;
  final int gridX;
  final int gridY;
  final double cellSize;
  final VoidCallback? onEmergenceComplete;

  double _elapsed = 0;
  static const _delay = 0.3; // wait for burst
  static const _emergeDuration = 1.5;
  static const _bounceDuration = 0.5;
  static const _totalDuration = _delay + _emergeDuration + _bounceDuration;
  bool _completed = false;

  @override
  void update(double dt) {
    super.update(dt);
    _elapsed += dt;

    if (!_completed && _elapsed >= _totalDuration) {
      _completed = true;
      onEmergenceComplete?.call();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    if (_elapsed < _delay) return;

    final emergeT = ((_elapsed - _delay) / _emergeDuration).clamp(0.0, 1.0);
    final bounceT = ((_elapsed - _delay - _emergeDuration) / _bounceDuration)
        .clamp(0.0, 1.0);

    double currentScale;
    if (bounceT > 0) {
      // Bounce: 0.8 → 1.12 → 1.0
      if (bounceT < 0.5) {
        currentScale = 0.8 + bounceT * 0.64; // 0.8 → 1.12
      } else {
        currentScale = 1.12 - (bounceT - 0.5) * 0.24; // 1.12 → 1.0
      }
    } else {
      // Emerge: 0.05 → 0.8 with ease-out
      final eased = 1.0 - (1.0 - emergeT) * (1.0 - emergeT);
      currentScale = 0.05 + eased * 0.75;
    }

    // Gold halo that fades as asset grows
    final haloAlpha = (1.0 - emergeT) * 0.4;
    if (haloAlpha > 0.01) {
      canvas.drawCircle(
        Offset(cellSize / 2, cellSize / 2),
        cellSize * 0.4 * currentScale,
        Paint()
          ..color = Color.fromRGBO(255, 228, 77, haloAlpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }

    // Ground crack of light
    if (emergeT > 0 && emergeT < 0.6) {
      final crackW = cellSize * 0.3 * (1.0 - emergeT / 0.6);
      canvas.drawLine(
        Offset(cellSize / 2 - crackW, cellSize * 0.85),
        Offset(cellSize / 2 + crackW, cellSize * 0.85),
        Paint()
          ..color = Color.fromRGBO(255, 228, 77, 0.6 * (1.0 - emergeT / 0.6))
          ..strokeWidth = 2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // Draw the asset scaled
    final padding = cellSize * 0.05;
    final paintSize = Size(cellSize - padding * 2, cellSize - padding * 2);

    canvas.save();
    canvas.translate(cellSize / 2, cellSize / 2);
    canvas.scale(currentScale);
    canvas.translate(-cellSize / 2, -cellSize / 2);
    canvas.translate(padding, padding);

    final painter = JannahAssetPainterRegistry.getPainter(
      assetTemplateId,
      healthState: 1,
      animationValue: emergeT * 0.5,
    );
    painter.paint(canvas, paintSize);

    canvas.restore();
  }
}
