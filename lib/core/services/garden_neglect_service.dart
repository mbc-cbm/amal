import 'dart:ui';

/// The 5 visual states of a garden based on user activity.
enum GardenNeglectState {
  /// 7+ consecutive active days — golden light particles, glowing water.
  radiant,

  /// 3-6 active days — normal beautiful state, no special overlay.
  flourishing,

  /// 7-13 days inactive — gentle grey-blue tint, narrower water.
  resting,

  /// 14-20 days inactive — stronger grey, dry patches, drooping flowers.
  longing,

  /// 21+ days inactive — near-monochrome, cracked earth, cold grey sky.
  withering,
}

/// Extension providing visual properties for each neglect state.
extension GardenNeglectStateX on GardenNeglectState {
  /// Sky gradient top colour.
  Color get skyColorTop => switch (this) {
        GardenNeglectState.radiant => const Color(0xFFFFF8DC),
        GardenNeglectState.flourishing => const Color(0xFFE3F2FD),
        GardenNeglectState.resting => const Color(0xFFB0BEC5),
        GardenNeglectState.longing => const Color(0xFF78909C),
        GardenNeglectState.withering => const Color(0xFF546E7A),
      };

  /// Sky gradient bottom colour.
  Color get skyColorBottom => switch (this) {
        GardenNeglectState.radiant => const Color(0xFFFFE082),
        GardenNeglectState.flourishing => const Color(0xFFFFF9C4),
        GardenNeglectState.resting => const Color(0xFF90A4AE),
        GardenNeglectState.longing => const Color(0xFF607D8B),
        GardenNeglectState.withering => const Color(0xFF455A64),
      };

  /// Grey overlay opacity (0 = none).
  double get overlayOpacity => switch (this) {
        GardenNeglectState.radiant => 0.0,
        GardenNeglectState.flourishing => 0.0,
        GardenNeglectState.resting => 0.12,
        GardenNeglectState.longing => 0.22,
        GardenNeglectState.withering => 0.0, // uses desaturation instead
      };

  /// Water feature width scale (1.0 = normal).
  double get waterWidthScale => switch (this) {
        GardenNeglectState.radiant => 1.1,
        GardenNeglectState.flourishing => 1.0,
        GardenNeglectState.resting => 0.7,
        GardenNeglectState.longing => 0.4,
        GardenNeglectState.withering => 0.15,
      };

  /// Flower scale (1.0 = normal, < 1.0 = closed/drooping).
  double get flowerScale => switch (this) {
        GardenNeglectState.radiant => 1.0,
        GardenNeglectState.flourishing => 1.0,
        GardenNeglectState.resting => 0.85,
        GardenNeglectState.longing => 0.7,
        GardenNeglectState.withering => 0.5,
      };

  /// Colour desaturation amount (0.0 = normal, 1.0 = fully grey).
  double get desaturation => switch (this) {
        GardenNeglectState.radiant => 0.0,
        GardenNeglectState.flourishing => 0.0,
        GardenNeglectState.resting => 0.0,
        GardenNeglectState.longing => 0.15,
        GardenNeglectState.withering => 0.80,
      };

  /// Whether to show golden radiant particles.
  bool get showRadiantParticles => this == GardenNeglectState.radiant;

  /// Whether to show dry leaves drifting down.
  bool get showDryLeaves => this == GardenNeglectState.longing;

  /// Whether to show cracked earth textures.
  bool get showCrackedEarth =>
      this == GardenNeglectState.longing || this == GardenNeglectState.withering;
}

/// Computes the current garden neglect state from activity data.
class GardenNeglectService {
  /// Computes the neglect state.
  ///
  /// [lastActiveDate] — the last date the user opened the garden.
  /// [consecutiveActiveDays] — how many consecutive days they were active.
  GardenNeglectState computeState({
    required DateTime? lastActiveDate,
    required int consecutiveActiveDays,
  }) {
    if (lastActiveDate == null) {
      return GardenNeglectState.flourishing; // new garden, benefit of doubt
    }

    final daysSince = DateTime.now().difference(lastActiveDate).inDays;

    if (daysSince >= 21) return GardenNeglectState.withering;
    if (daysSince >= 14) return GardenNeglectState.longing;
    if (daysSince >= 7) return GardenNeglectState.resting;

    // Active recently
    if (consecutiveActiveDays >= 7) return GardenNeglectState.radiant;
    return GardenNeglectState.flourishing;
  }
}
