import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/asset_model.dart';
import '../../core/providers/garden_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/garden_service.dart';
import '../../core/services/garden_share_service.dart';
import '../../core/storage/garden_asset_hive.dart';
import '../../core/utils/app_preferences.dart';
import '../../core/utils/rtl_helper.dart';
import '../../shared/widgets/amal_button.dart';
import 'package:hive/hive.dart';

import './animations/level_up_ceremony.dart';
import './garden_game.dart';
import './discovery/sacred_video_screen.dart';
import './painters/asset_painters.dart';
import './hayat/hayat_purchase_sheet.dart';
import './outer_circle/referral_panel.dart';
import './rainforest_game.dart';
import './widgets/gate_of_jannah_animation.dart';
import './widgets/outer_garden_explainer_screen.dart';
import './widgets/planting_ritual_overlay.dart';

// -- View enum ----------------------------------------------------------------

enum _GardenView { innerCircle, outerCircle }

// -- Screen -------------------------------------------------------------------

class JannahGardenScreen extends ConsumerStatefulWidget {
  const JannahGardenScreen({
    super.key,
    this.showHayatOnLoad = false,
    this.showOuterOnLoad = false,
  });

  final bool showHayatOnLoad;
  final bool showOuterOnLoad;

  @override
  ConsumerState<JannahGardenScreen> createState() => _JannahGardenScreenState();
}

class _JannahGardenScreenState extends ConsumerState<JannahGardenScreen> {
  _GardenView _view = _GardenView.innerCircle;

  late final GardenGame _gardenGame;
  RainforestGame? _rainforestGame;

  Timer? _countdownTimer;
  Duration _remaining = Duration.zero;

  bool _showGateAnimation = true;
  bool _canSkipGate = false;

  // Level-up ceremony
  bool _showLevelUpCeremony = false;
  int _levelUpTarget = 0;

  // Camera mode toggle
  GardenCameraMode _cameraMode = GardenCameraMode.architect;
  bool _showModeLabel = true;
  Timer? _modeLabelTimer;

  // Screenshot capture
  final GlobalKey _gardenBoundaryKey = GlobalKey();

  // -- Lifecycle --------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _gardenGame = GardenGame();

    // Check if user account is > 7 days old for skip button
    final creationTime =
        FirebaseAuth.instance.currentUser?.metadata.creationTime;
    final daysSinceCreation = creationTime == null
        ? 0
        : DateTime.now().difference(creationTime).inDays;
    _canSkipGate = daysSinceCreation >= 7;

    // Wire up Inner Circle callbacks — gated behind access.
    _gardenGame.onEmptySpotTapped = (int x, int y) {
      final pending = ref.read(pendingPlacementProvider);
      if (pending != null) {
        _placePendingAsset(x, y, pending);
      } else {
        _requireAccess(() => _openAssetStore(x, y));
      }
    };
    _gardenGame.onAssetLongPressed = (int x, int y, String assetId) {
      _requireAccess(() => _showAssetPopupMenu(x, y, assetId));
    };
    _gardenGame.onQuestionMarkTapped = (String questionMarkId) {
      _showQuestionMarkDetail(questionMarkId);
    };
    _gardenGame.onQuestionMarkExpired = (String questionMarkId) {
      _showExpiryToast();
    };

    // Listen for camera mode changes from the game
    _gardenGame.onCameraModeChanged = (mode) {
      if (mounted) {
        setState(() => _cameraMode = mode);
        _showModeLabelBriefly();
      }
    };

    // Mark today as active day (fire-and-forget)
    _markActiveDay();

    // Load saved grid state from Hive.
    final svc = ref.read(gardenServiceProvider);
    final hiveAssets = svc.loadAllAssetsFromHive();
    if (hiveAssets.isNotEmpty) {
      _gardenGame.loadState(
        hiveAssets.map((k, v) => MapEntry(k, <String, dynamic>{
          'assetId': v.assetTemplateId,
          'vitality': v.currentHealthState <= 1 ? 100 : (100 - v.currentHealthState * 20).clamp(0, 100),
        })),
      );
    }

    // Spawn question mark on garden entry (fire-and-forget)
    _trySpawnQuestionMark();

    // Auto-show Hayat sheet if navigated via /jannah-garden/hayat
    if (widget.showHayatOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showHayatPurchaseSheet(context);
      });
    }

    // Auto-navigate to outer garden if navigated via /jannah-garden/outer
    if (widget.showOuterOnLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToOuterGarden();
      });
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _modeLabelTimer?.cancel();
    super.dispose();
  }

  // -- Mode label auto-hide ---------------------------------------------------

  void _showModeLabelBriefly() {
    setState(() => _showModeLabel = true);
    _modeLabelTimer?.cancel();
    _modeLabelTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _showModeLabel = false);
    });
  }

  // -- Screenshot & share -----------------------------------------------------

  Future<void> _captureAndShare() async {
    // Show brief loading indicator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preparing your garden...'),
        duration: Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
      ),
    );

    final viewLabel = _cameraMode == GardenCameraMode.architect
        ? 'Garden View'
        : 'Paradise View';

    await GardenShareService.captureAndShare(
      _gardenBoundaryKey,
      viewLabel,
    );
  }

  // -- Mark active day (fire-and-forget) --------------------------------------

  Future<void> _markActiveDay() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFunctions.instance
          .httpsCallable('markActiveDay')
          .call<Map<String, dynamic>>({'uid': uid});
    } catch (_) {
      // Non-critical — ignore errors
    }
  }

  // -- Question mark spawn (fire-and-forget) -----------------------------------

  Future<void> _trySpawnQuestionMark() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final level = ref.read(gardenLevelProvider);
      await FirebaseFunctions.instance
          .httpsCallable('spawnQuestionMark')
          .call<Map<String, dynamic>>({'uid': uid, 'userLevel': level});
    } catch (_) {
      // Non-critical
    }
  }

  // -- Question mark detail (scroll reveal) -----------------------------------

  void _showQuestionMarkDetail(String questionMarkId) {
    final l10n = AppLocalizations.of(context);
    final qmListAsync = ref.read(questionMarksProvider);
    final qmList = qmListAsync.valueOrNull ?? [];
    final qmData = qmList.where((q) =>
        q['id'] == questionMarkId || q['questionMarkId'] == questionMarkId
    ).firstOrNull;

    final contentType = qmData?['contentType'] as String? ?? 'dua';
    final rewardAssetId = qmData?['rewardAssetTemplateId'] as String? ?? '';

    // Reveal animation on the game component
    _gardenGame.expireQuestionMark(questionMarkId);

    // Show the scroll overlay
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _QuestionMarkScrollReveal(
        contentType: contentType,
        rewardAssetTemplateId: rewardAssetId,
        questionMarkId: questionMarkId,
        l10n: l10n,
      ),
    );
  }

  // -- Question mark expiry toast ---------------------------------------------

  void _showExpiryToast() {
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n.qmMomentPassed,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.gardenCelestial),
        ),
        backgroundColor: const Color(0xFF1A4D2E),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // -- Timer management -------------------------------------------------------

  void _startCountdown(Duration initial) {
    _remaining = initial;
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remaining -= const Duration(seconds: 1);
        if (_remaining.isNegative) {
          _remaining = Duration.zero;
          _countdownTimer?.cancel();
        }
      });
    });
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
  }

  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accessAsync = ref.watch(gardenAccessProvider);

    // Watch QM stream and sync to game
    final qmAsync = ref.watch(questionMarksProvider);
    final qmList = qmAsync.valueOrNull ?? [];
    _gardenGame.loadQuestionMarks(qmList.map((data) {
      final ts = data['expiresAt'];
      DateTime? expires;
      if (ts is Timestamp) {
        expires = ts.toDate();
      }
      return <String, dynamic>{
        'id': data['questionMarkId'] ?? '',
        'positionX': data['positionX'] ?? 10,
        'positionY': data['positionY'] ?? 10,
        'contentType': data['contentType'] ?? 'dua',
        'expiresAt': expires,
      };
    }).toList());

    // Sync neglect state, sacred centre, and level from providers → game
    final neglect = ref.watch(gardenNeglectStateProvider);
    _gardenGame.setNeglectState(neglect);
    _gardenGame.setSacredCentreSlot(ref.watch(sacredCentreProvider));
    _gardenGame.setUserLevel(ref.watch(gardenLevelProvider));

    return accessAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (status) {
        // Start countdown for users with active timer.
        if (!status.isPremium && status.hasActiveTimer && status.remaining != null) {
          if (_countdownTimer == null || !_countdownTimer!.isActive) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startCountdown(status.remaining!);
            });
          }
        }

        // First-time warning check.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _maybeShowFirstTimeWarning(l10n);
        });

        // Level-up detection
        final currentLevel = ref.watch(gardenLevelProvider);
        final metaBox = Hive.box('gardenMeta');
        final lastKnownLevel = metaBox.get('lastKnownLevel', defaultValue: 1) as int;
        if (currentLevel > lastKnownLevel && lastKnownLevel > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_showLevelUpCeremony) {
              metaBox.put('lastKnownLevel', currentLevel);
              setState(() {
                _showLevelUpCeremony = true;
                _levelUpTarget = currentLevel;
              });
            }
          });
        } else if (lastKnownLevel == 0 || lastKnownLevel != currentLevel) {
          metaBox.put('lastKnownLevel', currentLevel);
        }

        final garden = _buildMainGarden(l10n, status);

        // Wrap with gate animation overlay on first load
        if (!_showGateAnimation) return garden;

        return Stack(
          children: [
            garden,
            GateOfJannahAnimation(
              canSkip: _canSkipGate,
              onComplete: () {
                if (mounted) {
                  setState(() => _showGateAnimation = false);
                }
              },
            ),
          ],
        );
      },
    );
  }

  // -- Access requirement helper -----------------------------------------------

  void _requireAccess(VoidCallback action) {
    final accessAsync = ref.read(gardenAccessProvider);
    // If still loading, allow action (don't block on loading state)
    if (accessAsync.isLoading || (accessAsync.valueOrNull?.canDoActions ?? false)) {
      action();
    } else {
      showModalBottomSheet<void>(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXl),
          ),
        ),
        builder: (_) => const _AccessPromptSheet(),
      );
    }
  }

  // -- Outer garden navigation (no access check) ------------------------------

  bool _showExplainer = false;

  void _navigateToOuterGarden() {
    final visitCount = AppPreferences.instance.outerGardenVisitCount;
    AppPreferences.instance.incrementOuterGardenVisitCount();

    if (visitCount < 5) {
      // Show explainer screen
      setState(() => _showExplainer = true);
    } else {
      setState(() => _view = _GardenView.outerCircle);
    }
  }

  // -- First-time Warning -----------------------------------------------------

  void _maybeShowFirstTimeWarning(AppLocalizations l10n) {
    if (AppPreferences.instance.gardenWarningSeen) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.jannahGarden),
        content: Text(l10n.gardenLocalSaveWarning),
        actions: [
          TextButton(
            onPressed: () {
              AppPreferences.instance.setGardenWarningSeen();
              Navigator.of(ctx).pop();
            },
            child: Text(l10n.gardenIUnderstand),
          ),
        ],
      ),
    );
  }

  // -- Main Garden ------------------------------------------------------------

  Widget _buildMainGarden(AppLocalizations l10n, GardenAccessStatus status) {
    return Directionality(
      textDirection: RtlHelper.textDirection(context),
      child: Scaffold(
      appBar: AppBar(
        title: Text(l10n.jannahGarden),
        actions: [
          // Store button — gated behind access.
          IconButton(
            icon: const Icon(Icons.store_rounded),
            tooltip: l10n.gardenAssetStore,
            onPressed: () => _requireAccess(() => _openAssetStore(null, null)),
          ),
          // Toggle Inner / Outer circle — NO access check.
          IconButton(
            icon: Icon(
              _view == _GardenView.innerCircle
                  ? Icons.public_rounded
                  : Icons.grass_rounded,
            ),
            tooltip: _view == _GardenView.innerCircle
                ? l10n.gardenOuterCircle
                : l10n.gardenInnerCircle,
            onPressed: () {
              if (_view == _GardenView.innerCircle) {
                _navigateToOuterGarden();
              } else {
                setState(() => _view = _GardenView.innerCircle);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Garden content.
          _view == _GardenView.innerCircle
              ? _buildInnerCircle()
              : _buildOuterCircle(l10n),

          // Timer overlay.
          _buildTimerOverlay(l10n, status),

          // Camera mode toggle pill (top-centre, auto-hides).
          if (_view == _GardenView.innerCircle && _showModeLabel)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _gardenGame.toggleCameraMode();
                    _showModeLabelBriefly();
                  },
                  child: AnimatedOpacity(
                    opacity: _showModeLabel ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.55),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _cameraMode == GardenCameraMode.architect
                                ? Icons.grid_view_rounded
                                : Icons.visibility_rounded,
                            color: AppColors.gardenCelestial,
                            size: 16,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            _cameraMode == GardenCameraMode.architect
                                ? 'Architect'
                                : 'Immersed',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.gardenCelestial,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Share button (top-right, always visible in inner circle).
          if (_view == _GardenView.innerCircle)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: AppSpacing.md,
              child: GestureDetector(
                onTap: _captureAndShare,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    color: AppColors.gardenCelestial,
                    size: 18,
                  ),
                ),
              ),
            ),

          // Pending placement banner.
          if (ref.watch(pendingPlacementProvider) != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.md),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.noorGold,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Text(
                    l10n.tapSlotToPlace,
                    style: AppTypography.labelLarge
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Moving mode banner.
          if (_isMoving)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.all(AppSpacing.md),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Text(
                    l10n.tapSlotToPlace,
                    style: AppTypography.labelLarge
                        .copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

          // Planting ritual overlay.
          if (_showPlantingRitual && _plantingAssetId != null)
            PlantingRitualOverlay(
              assetTemplateId: _plantingAssetId!,
              referenceTextAr: _getRefTextAr(_plantingAssetId!),
              referenceEn: _getRefEn(_plantingAssetId!),
              onComplete: () {
                setState(() {
                  _showPlantingRitual = false;
                  _plantingAssetId = null;
                });
              },
            ),

          // Outer garden explainer overlay.
          if (_showExplainer)
            OuterGardenExplainerScreen(
              showSkip: AppPreferences.instance.outerGardenVisitCount >= 5,
              onEnter: () {
                setState(() {
                  _showExplainer = false;
                  _view = _GardenView.outerCircle;
                });
              },
            ),

          // Level-up ceremony overlay.
          if (_showLevelUpCeremony)
            LevelUpCeremony(
              newLevel: _levelUpTarget,
              onComplete: () {
                setState(() => _showLevelUpCeremony = false);
                // Show welcome toast
                final levelName = _levelNameForToast(_levelUpTarget);
                if (levelName.isNotEmpty && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(context).welcomeToLevel(levelName),
                        style: AppTypography.titleSmall
                            .copyWith(color: AppColors.noorGold),
                      ),
                      backgroundColor: const Color(0xFF143D1E),
                      duration: const Duration(seconds: 3),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
        ],
      ),
    ),
    );
  }

  String _levelNameForToast(int level) {
    final l10n = AppLocalizations.of(context);
    return switch (level) {
      1 => l10n.levelAlRawdah,
      2 => l10n.levelAlFirdaws,
      3 => l10n.levelAlNaim,
      4 => l10n.levelJannatAlMawa,
      _ => '',
    };
  }

  // -- Inner Circle -----------------------------------------------------------

  Widget _buildInnerCircle() {
    return RepaintBoundary(
      key: _gardenBoundaryKey,
      child: GameWidget(game: _gardenGame),
    );
  }

  // -- Outer Circle -----------------------------------------------------------

  Widget _buildOuterCircle(AppLocalizations l10n) {
    final cs = Theme.of(context).colorScheme;
    final intensityAsync = ref.watch(outerGardenIntensityProvider);
    final referralAsync = ref.watch(referralCodeProvider);

    // Update rainforest intensity from stream
    final currentIntensity = intensityAsync.valueOrNull ?? 0.0;
    _rainforestGame ??= RainforestGame(intensity: (currentIntensity * 100).round());
    _rainforestGame!.setIntensity(currentIntensity);

    return Stack(
      children: [
        Column(
          children: [
            // Rainforest game takes ~60% of screen.
            Expanded(
              flex: 6,
              child: GameWidget(game: _rainforestGame!),
            ),

        // Info section.
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                // Intensity message.
                intensityAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (intensity) {
                    final message = _intensityMessage(l10n, (intensity * 100).round());
                    return Text(
                      message,
                      style: AppTypography.bodyLarge.copyWith(
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // Referral code.
                referralAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (code) {
                    if (code.isEmpty) return const SizedBox.shrink();
                    return Column(
                      children: [
                        Text(
                          l10n.gardenReferralCode,
                          style: AppTypography.labelMedium.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        SelectableText(
                          code,
                          style: AppTypography.titleMedium.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const Spacer(),

                // Share button.
                AmalPrimaryButton(
                  label: l10n.gardenShareAmal,
                  icon: const Icon(Icons.share_rounded, size: AppSpacing.iconSm),
                  onPressed: () {
                    final code = referralAsync.valueOrNull ?? '';
                    Share.share('${l10n.gardenShareAmal}: $code');
                  },
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
          ],
        ),
        // Floating network button
        Positioned(
          bottom: AppSpacing.lg,
          left: 0,
          right: 0,
          child: Center(
            child: NetworkFloatingButton(
              onTap: () => showReferralPanel(context),
            ),
          ),
        ),
      ],
    );
  }

  String _intensityMessage(AppLocalizations l10n, int intensity) {
    if (intensity >= 75) return l10n.gardenIntensityMax;
    if (intensity >= 50) return l10n.gardenIntensityHigh;
    if (intensity >= 25) return l10n.gardenIntensityMedium;
    return l10n.gardenIntensityLow;
  }

  // -- Timer Overlay ----------------------------------------------------------

  Widget _buildTimerOverlay(AppLocalizations l10n, GardenAccessStatus status) {
    final cs = Theme.of(context).colorScheme;

    Widget content;
    if (status.isPremium) {
      // Gold premium badge
      content = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.workspace_premium_rounded,
              size: AppSpacing.iconSm, color: AppColors.primaryGold),
          const SizedBox(width: AppSpacing.sm),
          Text(l10n.gardenPremiumBadge,
              style: AppTypography.labelLarge
                  .copyWith(color: AppColors.primaryGold)),
        ],
      );
    } else if (status.hasActiveTimer) {
      // Warm green countdown
      final isLow = _remaining.inMinutes < 10;
      content = Text(
        l10n.gardenAccessRemaining(_formatDuration(_remaining)),
        style: AppTypography.labelLarge.copyWith(
          color: isLow ? AppColors.warning : AppColors.primaryGreen,
        ),
        textAlign: TextAlign.center,
      );
    } else {
      // Gentle invitation — no lock icon
      content = GestureDetector(
        onTap: () => _requireAccess(() {}),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.play_circle_outline_rounded,
                size: AppSpacing.iconSm, color: cs.onSurfaceVariant),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.gardenWatchToUnlock,
                style: AppTypography.labelMedium
                    .copyWith(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cs.surface.withValues(alpha: 0.9),
          border: Border(
            top: BorderSide(color: cs.outlineVariant, width: 0.5),
          ),
        ),
        child: SafeArea(top: false, child: content),
      ),
    );
  }



  // -- Reference text helpers --------------------------------------------------

  String _getRefTextAr(String assetTemplateId) {
    final storeAssets = ref.read(storeAssetsProvider(null)).valueOrNull ?? [];
    final asset = storeAssets.where((a) => a.id == assetTemplateId).firstOrNull;
    return asset?.referenceTextAr ?? '';
  }

  String _getRefEn(String assetTemplateId) {
    final storeAssets = ref.read(storeAssetsProvider(null)).valueOrNull ?? [];
    final asset = storeAssets.where((a) => a.id == assetTemplateId).firstOrNull;
    return asset?.referenceEn ?? '';
  }

  // -- Asset Store Bottom Sheet -----------------------------------------------

  void _openAssetStore(int? gridX, int? gridY) {
    context.push(AppRoutes.jannahShop);
  }

  // -- Pending placement (after purchase from shop) --------------------------

  bool _showPlantingRitual = false;
  String? _plantingAssetId;

  void _placePendingAsset(int x, int y, String assetTemplateId) {
    // Clear pending
    ref.read(pendingPlacementProvider.notifier).state = null;

    // Place in game immediately
    _gardenGame.placeAsset(x, y, assetTemplateId, 100);

    // Save to Hive
    final storeAssets = ref.read(storeAssetsProvider(null)).valueOrNull ?? [];
    final asset = storeAssets.where((a) => a.id == assetTemplateId).firstOrNull;
    if (asset != null) {
      saveAssetToHive(x, y, asset);
    }

    // Show planting ritual overlay
    setState(() {
      _showPlantingRitual = true;
      _plantingAssetId = assetTemplateId;
    });
  }

  // -- Asset Popup Menu -------------------------------------------------------

  void _showAssetPopupMenu(int x, int y, String assetId) {
    final l10n = AppLocalizations.of(context);

    // Check if withered for restore option
    final svc = ref.read(gardenServiceProvider);
    final allAssets = svc.loadAllAssetsFromHive();
    final hiveAsset = allAssets['$x,$y'];
    final isWithered = hiveAsset != null && hiveAsset.currentHealthState > 1;
    final isDiscoveredAsset = hiveAsset?.purchaseType == 'discovered';

    showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(100, 300, 100, 300),
      items: [
        PopupMenuItem(value: 'move', child: Text(l10n.moveAsset)),
        PopupMenuItem(value: 'info', child: Text(l10n.info)),
        if (isWithered)
          PopupMenuItem(value: 'restore', child: Text(l10n.restore)),
        // Discovered assets cannot be sold
        if (!isDiscoveredAsset)
          PopupMenuItem(
            value: 'sell',
            child: Text(l10n.sellAsset,
                style: TextStyle(color: AppColors.warning)),
          ),
      ],
    ).then((value) {
      if (value == null) return;
      switch (value) {
        case 'move':
          _startMoveFlow(x, y, assetId);
        case 'restore':
          _showRestorationDialog(x, y, assetId);
        case 'info':
          _showAmalDetailDialog(assetId);
        case 'sell':
          _showSellConfirmation(x, y, assetId);
      }
    });
  }

  // -- Move flow --------------------------------------------------------------

  bool _isMoving = false;
  int? _moveFromX;
  int? _moveFromY;

  void _startMoveFlow(int x, int y, String assetId) {
    setState(() {
      _isMoving = true;
      _moveFromX = x;
      _moveFromY = y;
    });

    // Override the empty spot callback temporarily for move
    _gardenGame.onEmptySpotTapped = (int toX, int toY) {
      if (_isMoving && _moveFromX != null && _moveFromY != null) {
        _gardenGame.moveAsset(_moveFromX!, _moveFromY!, toX, toY);

        // Update Hive — remove old, write new
        final svc = ref.read(gardenServiceProvider);
        final allAssets = svc.loadAllAssetsFromHive();
        final old = allAssets['$_moveFromX,$_moveFromY'];
        if (old != null) {
          svc.removeAssetFromHive('$_moveFromX,$_moveFromY');
          old.slotKey = '$toX,$toY';
          old.positionX = toX.toDouble();
          old.positionY = toY.toDouble();
          svc.saveAssetToHive(old);
        }

        // Restore normal callback
        setState(() => _isMoving = false);
        _gardenGame.onEmptySpotTapped = (int x, int y) {
          final pending = ref.read(pendingPlacementProvider);
          if (pending != null) {
            _placePendingAsset(x, y, pending);
          } else {
            _requireAccess(() => _openAssetStore(x, y));
          }
        };
      }
    };
  }

  // -- Sell flow --------------------------------------------------------------

  void _showSellConfirmation(int x, int y, String assetId) {
    final l10n = AppLocalizations.of(context);
    final svc = ref.read(gardenServiceProvider);
    final allAssets = svc.loadAllAssetsFromHive();
    final hiveAsset = allAssets['$x,$y'];
    final sellPrice = hiveAsset != null
        ? (hiveAsset.originalNcPrice * 0.6).ceil()
        : 0;

    final displayName = assetId.replaceAll('_', ' ');

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.sellConfirmTitle(displayName, sellPrice)),
        content: Text(l10n.sellConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.notNow),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.warning,
            ),
            child: Text(l10n.sellButton),
          ),
        ],
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      await _executeSell(x, y, assetId);
    });
  }

  Future<void> _executeSell(int x, int y, String assetId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final slotKey = '$x,$y';

    try {
      await FirebaseFunctions.instance
          .httpsCallable('sellAsset')
          .call({'uid': uid, 'assetId': slotKey});

      // Remove from game and Hive
      _gardenGame.removeAsset(x, y);
      _removeAssetFromHive(x, y);

      ref.invalidate(ownedAssetIdsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  // -- Restoration Dialog (via Hayat) -----------------------------------------

  void _showRestorationDialog(int x, int y, String assetId) {
    final slotKey = '$x,$y';
    showHayatPurchaseSheet(
      context,
      preSelectedDrop: true,
      preSelectedAssetSlotKey: slotKey,
    );
  }

  // -- Amal Detail Dialog -----------------------------------------------------

  void _showAmalDetailDialog(String assetId) {
    final storeAssets = ref.read(storeAssetsProvider(null));
    final assets = storeAssets.valueOrNull;
    if (assets == null) return; // still loading
    final asset = assets.where((a) => a.id == assetId).firstOrNull;
    if (asset == null) return;

    final locale = Localizations.localeOf(context).languageCode;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(asset.localizedName(locale)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Type: ${asset.category}',
              style: AppTypography.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(
                  Icons.monetization_on_rounded,
                  size: AppSpacing.iconSm,
                  color: AppColors.noorGold,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  '${asset.ncPrice}',
                  style: AppTypography.noorCoinLabel,
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(ctx).ok),
          ),
        ],
      ),
    );
  }

  // -- Auto-save --------------------------------------------------------------

  /// Saves a purchased asset to Hive and places it on the game grid.
  /// Called after returning from the shop with a purchased asset.
  void saveAssetToHive(int x, int y, AssetModel asset) {
    final svc = ref.read(gardenServiceProvider);
    final hiveAsset = GardenAssetHive(
      slotKey: '$x,$y',
      assetTemplateId: asset.id,
      positionX: x.toDouble(),
      positionY: y.toDouble(),
      tier: asset.tier,
      isDiscovered: false,
      currentHealthState: 1,
      originalNcPrice: asset.ncPrice,
      purchaseType: 'nc',
      isPlaced: true,
      purchasedAtMs: DateTime.now().millisecondsSinceEpoch,
    );
    svc.saveAssetToHive(hiveAsset);
  }

  void _removeAssetFromHive(int x, int y) {
    final svc = ref.read(gardenServiceProvider);
    svc.removeAssetFromHive('$x,$y');
  }

  /// Updates the health state of an asset in Hive.
  void updateHealthInHive(int x, int y, int healthState) {
    final svc = ref.read(gardenServiceProvider);
    final allAssets = svc.loadAllAssetsFromHive();
    final key = '$x,$y';
    final existing = allAssets[key];
    if (existing != null) {
      existing.currentHealthState = healthState;
      svc.saveAssetToHive(existing);
    }
  }
}

// =============================================================================
// -- Access Prompt Sheet (shown when free user tries an action) ----------------
// =============================================================================

class _AccessPromptSheet extends StatelessWidget {
  const _AccessPromptSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Directionality(
      textDirection: RtlHelper.textDirection(context),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Garden gate icon
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen.withValues(alpha: 0.15),
                    AppColors.primaryGold.withValues(alpha: 0.1),
                  ],
                ),
              ),
              child: const Icon(
                Icons.spa_rounded,
                size: 36,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Title
            Text(
              l10n.gardenAwaitsTitle,
              style: AppTypography.headlineSmall.copyWith(
                color: cs.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Body
            Text(
              l10n.gardenAwaitsBody,
              style: AppTypography.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Subscribe — gold, most prominent
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).push('/profile'); // subscription is in profile
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(l10n.gardenSubscribe,
                    style: AppTypography.labelLarge
                        .copyWith(color: Colors.white)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Complete Soul Stack
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).push('/soul-stack');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: const BorderSide(color: AppColors.primaryGreen),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(l10n.gardenCompleteSoulStack),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Watch a Video
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  GoRouter.of(context).push('/ywtl');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: cs.onSurfaceVariant,
                  side: BorderSide(color: cs.outline),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(l10n.gardenWatchVideo),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Not now — dismiss
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Text(
                l10n.gardenNotNow,
                style: AppTypography.bodySmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

// =============================================================================
// -- Question Mark Scroll Reveal (sacred parchment unroll) --------------------
// =============================================================================

class _QuestionMarkScrollReveal extends StatefulWidget {
  const _QuestionMarkScrollReveal({
    required this.contentType,
    required this.rewardAssetTemplateId,
    required this.questionMarkId,
    required this.l10n,
  });

  final String contentType;
  final String rewardAssetTemplateId;
  final String questionMarkId;
  final AppLocalizations l10n;

  @override
  State<_QuestionMarkScrollReveal> createState() =>
      _QuestionMarkScrollRevealState();
}

class _QuestionMarkScrollRevealState extends State<_QuestionMarkScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _unrollAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _unrollAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDua = widget.contentType == 'dua';

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final unroll = _unrollAnim.value;
        final contentOpacity = _fadeAnim.value;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          margin: const EdgeInsets.all(AppSpacing.lg),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            child: Container(
              // Parchment background
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFFF5E6C8),
                    const Color(0xFFEDD9A3),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(
                  color: AppColors.noorGold.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              // Vertical unroll clip
              height: 350 * unroll,
              child: SingleChildScrollView(
                physics: const NeverScrollableScrollPhysics(),
                child: SizedBox(
                  height: 350,
                  child: Opacity(
                    opacity: contentOpacity,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Content type badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.noorGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusFull),
                              border: Border.all(
                                color: AppColors.noorGold.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Text(
                              isDua
                                  ? '\u2726 ${widget.l10n.qmDua}'
                                  : '\u2726 ${widget.l10n.qmHistory}',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.noorGold,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),

                          // Reward silhouette (asset shape in dark)
                          if (widget.rewardAssetTemplateId.isNotEmpty)
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: ColorFiltered(
                                colorFilter: const ColorFilter.mode(
                                  Color(0xFF2A2A2A),
                                  BlendMode.srcIn,
                                ),
                                child: CustomPaint(
                                  painter:
                                      JannahAssetPainterRegistry.getPainter(
                                    widget.rewardAssetTemplateId,
                                    healthState: 1,
                                    animationValue: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: AppSpacing.md),

                          // "Watch to discover your gift"
                          Text(
                            widget.l10n.qmWatchToDiscover,
                            style: AppTypography.titleSmall.copyWith(
                              color: const Color(0xFF5D4037),
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const Spacer(),

                          // Watch button
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                // Navigate to sacred video player
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SacredVideoScreen(
                                      questionMarkId: widget.questionMarkId,
                                      videoId: '', // populated from Firestore
                                      videoUrl: '', // populated from Firestore
                                      durationSeconds: 0,
                                      titleEn: '',
                                      contentType: widget.contentType,
                                    ),
                                  ),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.noorGold,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusLg),
                                ),
                              ),
                              child: Text(widget.l10n.qmWatchToDiscover),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
