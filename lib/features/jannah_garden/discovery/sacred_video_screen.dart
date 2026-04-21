import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SACRED VIDEO SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class SacredVideoScreen extends ConsumerStatefulWidget {
  const SacredVideoScreen({
    super.key,
    required this.questionMarkId,
    required this.videoId,
    required this.videoUrl,
    required this.durationSeconds,
    required this.titleEn,
    this.titleBn = '',
    this.titleAr = '',
    this.titleUr = '',
    required this.contentType,
    this.reflectionLineEn = '',
    this.reflectionLineAr = '',
    this.reflectionLineBn = '',
    this.reflectionLineUr = '',
  });

  final String questionMarkId;
  final String videoId;
  final String videoUrl;
  final int durationSeconds;
  final String titleEn;
  final String titleBn;
  final String titleAr;
  final String titleUr;
  final String contentType;
  final String reflectionLineEn;
  final String reflectionLineAr;
  final String reflectionLineBn;
  final String reflectionLineUr;

  @override
  ConsumerState<SacredVideoScreen> createState() => _SacredVideoScreenState();
}

class _SacredVideoScreenState extends ConsumerState<SacredVideoScreen> {
  VideoPlayerController? _controller;
  bool _hasVideo = false;
  bool _isPlaying = false;
  bool _showControls = true;
  Timer? _controlsTimer;
  Timer? _watchTimer;

  int _watchedSeconds = 0;
  bool _locallyCompleted = false;
  bool _showJazakScreen = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (widget.videoUrl.isEmpty) {
      setState(() => _hasVideo = false);
      return;
    }

    setState(() => _hasVideo = true);

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
      await _controller!.initialize();
      _controller!.addListener(_onVideoTick);
      _controller!.play();
      setState(() => _isPlaying = true);
      _startWatchTimer();
      _startControlsAutoHide();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _onVideoTick() {
    if (_controller == null || _locallyCompleted) return;

    // Check if video naturally ended
    final pos = _controller!.value.position;
    final dur = _controller!.value.duration;
    if (dur > Duration.zero &&
        pos >= dur - const Duration(milliseconds: 500)) {
      _onVideoComplete();
    }
  }

  void _startWatchTimer() {
    _watchTimer?.cancel();
    _watchTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_controller != null && _controller!.value.isPlaying) {
        _watchedSeconds++;

        // Check completion threshold
        if (!_locallyCompleted &&
            _watchedSeconds >= widget.durationSeconds - 5) {
          _onVideoComplete();
        }
      }
    });
  }

  Future<void> _onVideoComplete() async {
    if (_locallyCompleted) return;
    _locallyCompleted = true;

    _controller?.pause();
    _watchTimer?.cancel();

    // Call Cloud Function
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFunctions.instance
            .httpsCallable('recordQuestionMarkCompletion')
            .call({
          'uid': uid,
          'questionMarkId': widget.questionMarkId,
          'watchedSeconds': _watchedSeconds,
        });
      }
    } catch (e) {
      debugPrint('recordQuestionMarkCompletion failed: $e');
    }

    // Show JazakAllahu Khairan screen
    if (mounted) {
      setState(() => _showJazakScreen = true);

      // Auto-return after 2.5 seconds
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (mounted) {
          Navigator.of(context).pop(true); // true = completed
        }
      });
    }
  }

  // ── Abandon flow ─────────────────────────────────────────────────────────

  Future<void> _abandon() async {
    _controller?.pause();
    _watchTimer?.cancel();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('questionMarks')
            .doc(widget.questionMarkId)
            .update({'abandonedAt': FieldValue.serverTimestamp()});
      }
    } catch (_) {}

    if (mounted) {
      Navigator.of(context).pop(false); // false = abandoned
    }
  }

  // ── Controls visibility ──────────────────────────────────────────────────

  void _togglePlayPause() {
    if (_controller == null) return;
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
    _startControlsAutoHide();
  }

  void _onScreenTap() {
    setState(() => _showControls = true);
    _startControlsAutoHide();
  }

  void _startControlsAutoHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isPlaying) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoTick);
    _controller?.dispose();
    _watchTimer?.cancel();
    _controlsTimer?.cancel();
    super.dispose();
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    if (_showJazakScreen) {
      return _buildJazakScreen(l10n, locale);
    }

    if (!_hasVideo) {
      return _buildPlaceholder(l10n);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onScreenTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Video
            if (_controller != null && _controller!.value.isInitialized)
              Center(
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
              )
            else if (_error != null)
              _buildPlaceholder(l10n)
            else
              const Center(
                child: CircularProgressIndicator(color: AppColors.noorGold),
              ),

            // Top bar (always visible)
            _buildTopBar(l10n, locale),

            // Play/Pause (visible on tap, auto-hides)
            if (_showControls && _controller != null)
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    child: Icon(
                      _isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 42,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Top bar ──────────────────────────────────────────────────────────────

  Widget _buildTopBar(AppLocalizations l10n, String locale) {
    final isDua = widget.contentType == 'dua';

    final title = switch (locale) {
      'bn' => widget.titleBn.isNotEmpty ? widget.titleBn : widget.titleEn,
      'ur' => widget.titleUr.isNotEmpty ? widget.titleUr : widget.titleEn,
      'ar' => widget.titleAr.isNotEmpty ? widget.titleAr : widget.titleEn,
      _ => widget.titleEn,
    };

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              // Content type badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.noorGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  border: Border.all(
                    color: AppColors.noorGold.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  isDua ? '\u2726 ${l10n.qmDua}' : '\u2726 ${l10n.qmHistory}',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.noorGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.titleSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // X button
              GestureDetector(
                onTap: _abandon,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── JazakAllahu Khairan screen ───────────────────────────────────────────

  Widget _buildJazakScreen(AppLocalizations l10n, String locale) {
    final reflection = switch (locale) {
      'bn' => widget.reflectionLineBn.isNotEmpty
          ? widget.reflectionLineBn
          : widget.reflectionLineEn,
      'ur' => widget.reflectionLineUr.isNotEmpty
          ? widget.reflectionLineUr
          : widget.reflectionLineEn,
      'ar' => widget.reflectionLineAr.isNotEmpty
          ? widget.reflectionLineAr
          : widget.reflectionLineEn,
      _ => widget.reflectionLineEn,
    };

    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Golden radial glow
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    AppColors.noorGold.withValues(alpha: 0.15),
                    Colors.transparent,
                  ]),
                ),
                child: const Center(
                  child: Icon(Icons.auto_awesome_rounded,
                      color: AppColors.noorGold, size: 40),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Arabic: جَزَاكَ اللَّهُ خَيْرًا
              const Text(
                'جَزَاكَ اللَّهُ خَيْرًا',
                style: TextStyle(
                  fontSize: 36,
                  color: AppColors.noorGold,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  decoration: TextDecoration.none,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // English transliteration
              Text(
                l10n.jazakAllahuKhairan,
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.gardenCelestial,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Reflection line
              if (reflection.isNotEmpty)
                Text(
                  reflection,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.gardenCelestial.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Placeholder (no video URL) ───────────────────────────────────────────

  Widget _buildPlaceholder(AppLocalizations l10n) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Arabesque background pattern
          CustomPaint(
            painter: _ArabesquePainter(),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.auto_awesome_rounded,
                      size: 48, color: AppColors.noorGold.withValues(alpha: 0.6)),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    l10n.sacredContentComingSoon,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.gardenCelestial,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.noorGold,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                        ),
                      ),
                      child: Text(l10n.returnToGarden),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ARABESQUE BACKGROUND PAINTER
// ═══════════════════════════════════════════════════════════════════════════

class _ArabesquePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.noorGold.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // Repeating diamond-star pattern
    const step = 60.0;
    for (var y = 0.0; y < size.height + step; y += step) {
      for (var x = 0.0; x < size.width + step; x += step) {
        // Diamond
        final path = Path()
          ..moveTo(x, y - step * 0.4)
          ..lineTo(x + step * 0.4, y)
          ..lineTo(x, y + step * 0.4)
          ..lineTo(x - step * 0.4, y)
          ..close();
        canvas.drawPath(path, paint);

        // Small star at centre
        canvas.drawCircle(
          Offset(x, y),
          2,
          Paint()..color = AppColors.noorGold.withValues(alpha: 0.04),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_ArabesquePainter oldDelegate) => false;
}
