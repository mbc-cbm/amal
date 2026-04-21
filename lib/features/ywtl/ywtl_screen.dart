import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/noor_coin_values.dart';
import '../../core/l10n/app_localizations.dart';
import '../../shared/widgets/amal_button.dart';

// ── Data Model ───────────────────────────────────────────────────────────────

class YwtlVideo {
  const YwtlVideo({
    required this.videoId,
    required this.videoUrl,
    required this.thumbnail,
    required this.wingCode,
    required this.titleEn,
    this.titleBn = '',
    this.titleUr = '',
    this.titleAr = '',
    required this.availableAt,
    required this.dayOfWeek,
  });

  final String videoId;
  final String videoUrl;
  final String thumbnail;
  final String wingCode; // 'bmm', 'mle', 'rani', 'maya', 'cme', 'impact_wing', 'executives'
  final String titleEn;
  final String titleBn;
  final String titleUr;
  final String titleAr;
  final DateTime availableAt;
  final int dayOfWeek; // 1=Monday, 7=Sunday

  String localizedTitle(String locale) => switch (locale) {
        'bn' => titleBn.isNotEmpty ? titleBn : titleEn,
        'ur' => titleUr.isNotEmpty ? titleUr : titleEn,
        'ar' => titleAr.isNotEmpty ? titleAr : titleEn,
        _ => titleEn,
      };

  bool get isAvailable => DateTime.now().isAfter(availableAt);

  factory YwtlVideo.fromMap(Map<String, dynamic> data) {
    return YwtlVideo(
      videoId: data['videoId'] as String? ?? '',
      videoUrl: data['videoUrl'] as String? ?? '',
      thumbnail: data['thumbnail'] as String? ?? '',
      wingCode: data['wingCode'] as String? ?? '',
      titleEn: data['titleEn'] as String? ?? '',
      titleBn: data['titleBn'] as String? ?? '',
      titleUr: data['titleUr'] as String? ?? '',
      titleAr: data['titleAr'] as String? ?? '',
      availableAt: (data['availableAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      dayOfWeek: data['dayOfWeek'] as int? ?? 1,
    );
  }
}

// ── Wing Schedule ────────────────────────────────────────────────────────────

const _wingSchedule = <int, (String, String)>{
  1: ('bmm', 'BMM — Badruddoza Medical Mandate'),
  2: ('mle', 'MLE — Mary and Ladla Education'),
  3: ('rani', 'RANI — Rapid Assistance and Network Initiatives'),
  4: ('maya', 'MAYA — Mothers Aid for Young Adults'),
  5: ('cme', 'CME — Capacity Building & Mentorship'),
  6: ('impact_wing', 'Impact Wing — Weekly Summary'),
  7: ('executives', 'Executives — Vision & Updates'),
};

// ── Wing icons ───────────────────────────────────────────────────────────────

IconData _wingIcon(String wingCode) => switch (wingCode) {
      'bmm' => Icons.local_hospital_rounded,
      'mle' => Icons.school_rounded,
      'rani' => Icons.handshake_rounded,
      'maya' => Icons.family_restroom_rounded,
      'cme' => Icons.trending_up_rounded,
      'impact_wing' => Icons.summarize_rounded,
      'executives' => Icons.campaign_rounded,
      _ => Icons.play_circle_fill_rounded,
    };

Color _wingColor(String wingCode) => switch (wingCode) {
      'bmm' => const Color(0xFF1565C0),
      'mle' => const Color(0xFF2E7D32),
      'rani' => const Color(0xFFE65100),
      'maya' => const Color(0xFF6A1B9A),
      'cme' => const Color(0xFF00838F),
      'impact_wing' => AppColors.primaryGold,
      'executives' => AppColors.primaryGreen,
      _ => AppColors.primaryGreen,
    };

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Returns the Monday of the current week.
DateTime _mondayOfThisWeek() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day - (now.weekday - 1));
}

/// Week key for Firestore: YYYY-WW
String _weekKey(DateTime monday) {
  final weekNum = int.parse(DateFormat('ww').format(monday));
  return '${monday.year}-${weekNum.toString().padLeft(2, '0')}';
}

/// Generate placeholder videos for the current week.
List<YwtlVideo> _generatePlaceholders() {
  final monday = _mondayOfThisWeek();
  return List.generate(7, (i) {
    final day = i + 1;
    final entry = _wingSchedule[day]!;
    final date = monday.add(Duration(days: i));
    return YwtlVideo(
      videoId: 'placeholder_${_weekKey(monday)}_$day',
      videoUrl: '',
      thumbnail: '',
      wingCode: entry.$1,
      titleEn: '${entry.$2} — Week of ${DateFormat('MMM d').format(monday)}',
      availableAt: date,
      dayOfWeek: day,
    );
  });
}

String _dayName(int dayOfWeek, AppLocalizations l10n) => switch (dayOfWeek) {
      1 => l10n.ywtlMonday,
      2 => l10n.ywtlTuesday,
      3 => l10n.ywtlWednesday,
      4 => l10n.ywtlThursday,
      5 => l10n.ywtlFriday,
      6 => l10n.ywtlSaturday,
      7 => l10n.ywtlSunday,
      _ => '',
    };

// ══════════════════════════════════════════════════════════════════════════════
// YWTL Screen
// ══════════════════════════════════════════════════════════════════════════════

class YwtlScreen extends ConsumerStatefulWidget {
  const YwtlScreen({super.key});

  @override
  ConsumerState<YwtlScreen> createState() => _YwtlScreenState();
}

class _YwtlScreenState extends ConsumerState<YwtlScreen> {
  List<YwtlVideo> _weekVideos = [];
  int _selectedDay = DateTime.now().weekday; // 1-7
  bool _loading = true;
  final Set<int> _watchedDays = {};

  @override
  void initState() {
    super.initState();
    _loadWeekVideos();
    _loadWatchLog();
  }

  Future<void> _loadWeekVideos() async {
    final monday = _mondayOfThisWeek();
    final key = _weekKey(monday);

    try {
      final snap = await FirebaseFirestore.instance
          .collection('ywtlVideos')
          .doc(key)
          .collection('days')
          .get();

      if (snap.docs.isNotEmpty) {
        final videos = <YwtlVideo>[];
        for (final doc in snap.docs) {
          videos.add(YwtlVideo.fromMap(doc.data()));
        }
        // Fill in any missing days with placeholders
        final placeholders = _generatePlaceholders();
        final byDay = {for (final v in videos) v.dayOfWeek: v};
        for (final p in placeholders) {
          byDay.putIfAbsent(p.dayOfWeek, () => p);
        }
        final merged = List.generate(7, (i) => byDay[i + 1]!);
        if (mounted) setState(() => _weekVideos = merged);
      } else {
        if (mounted) setState(() => _weekVideos = _generatePlaceholders());
      }
    } catch (_) {
      if (mounted) setState(() => _weekVideos = _generatePlaceholders());
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _loadWatchLog() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final monday = _mondayOfThisWeek();
    try {
      // Fetch all 7 days in parallel
      final futures = List.generate(7, (i) {
        final date = monday.add(Duration(days: i));
        final dateKey = DateFormat('yyyy-MM-dd').format(date);
        return FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('ywtlLog')
            .doc(dateKey)
            .get();
      });
      final results = await Future.wait(futures);
      if (!mounted) return;
      for (var i = 0; i < results.length; i++) {
        if (results[i].exists && results[i].data()?['watched'] == true) {
          _watchedDays.add(i + 1);
        }
      }
      setState(() {});
    } catch (_) {
      // ignore — user just won't see watched badges
    }
  }

  YwtlVideo get _selectedVideo {
    if (_weekVideos.isEmpty) {
      return _generatePlaceholders()[_selectedDay - 1];
    }
    return _weekVideos[_selectedDay - 1];
  }

  bool get _isToday => _selectedDay == DateTime.now().weekday;

  void _onDayTap(int dayOfWeek) {
    final video = _weekVideos[dayOfWeek - 1];
    if (video.isAvailable) {
      setState(() => _selectedDay = dayOfWeek);
    }
  }

  Future<void> _openPlayer() async {
    final video = _selectedVideo;
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _YwtlPlayerView(video: video),
      ),
    );
    if (result == true && mounted) {
      setState(() => _watchedDays.add(video.dayOfWeek));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.ywtl)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final video = _selectedVideo;
    final wingEntry = _wingSchedule[_selectedDay]!;
    final watched = _watchedDays.contains(_selectedDay);
    final locale = Localizations.localeOf(context).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.ywtl)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Today's video card ──────────────────────────────────────
              _TodayVideoCard(
                video: video,
                wingLabel: wingEntry.$2,
                wingCode: wingEntry.$1,
                locale: locale,
                watched: watched,
                isToday: _isToday,
                onWatch: _openPlayer,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── This Week section ───────────────────────────────────────
              Text(
                l10n.ywtlThisWeek,
                style: AppTypography.titleMedium.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppSpacing.sm),

              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final dayVideo = _weekVideos[index];
                    final today = DateTime.now().weekday;
                    final isCurrentDay = day == today;
                    final isPast = day < today;
                    final isFuture = day > today;
                    final dayWatched = _watchedDays.contains(day);
                    final isSelected = day == _selectedDay;

                    return _WeekDayCard(
                      dayName: _dayName(day, l10n),
                      wingCode: _wingSchedule[day]!.$1,
                      isToday: isCurrentDay,
                      isPast: isPast,
                      isFuture: isFuture,
                      watched: dayWatched,
                      isSelected: isSelected,
                      daysUntil: isFuture ? day - today : 0,
                      onTap: dayVideo.isAvailable ? () => _onDayTap(day) : null,
                    );
                  },
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Previous weeks note ─────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Row(
                  children: [
                    Icon(Icons.ondemand_video_rounded,
                        color: cs.onSurfaceVariant, size: AppSpacing.iconMd),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        l10n.ywtlPreviousWeeks,
                        style: AppTypography.bodySmall
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Today's Video Card
// ══════════════════════════════════════════════════════════════════════════════

class _TodayVideoCard extends StatelessWidget {
  const _TodayVideoCard({
    required this.video,
    required this.wingLabel,
    required this.wingCode,
    required this.locale,
    required this.watched,
    required this.isToday,
    required this.onWatch,
  });

  final YwtlVideo video;
  final String wingLabel;
  final String wingCode;
  final String locale;
  final bool watched;
  final bool isToday;
  final VoidCallback onWatch;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final color = _wingColor(wingCode);

    return Card(
      elevation: AppSpacing.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Thumbnail area ────────────────────────────────────────────
          Container(
            height: 200,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.8),
                  color.withValues(alpha: 0.4),
                ],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Wing icon in background
                Icon(
                  _wingIcon(wingCode),
                  size: 64,
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
                // Play button
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.9),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.play_circle_fill_rounded,
                    size: 56,
                    color: color,
                  ),
                ),
                // Watched badge
                if (watched)
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.9),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle,
                              size: 14, color: AppColors.white),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            l10n.amalCompleted,
                            style: AppTypography.labelSmall
                                .copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Info area ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Wing code label
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    wingLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Title
                Text(
                  video.localizedTitle(locale),
                  style:
                      AppTypography.titleMedium.copyWith(color: cs.onSurface),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.sm),

                // Coin reward hint
                Row(
                  children: [
                    Icon(Icons.stars_rounded,
                        size: 16, color: AppColors.noorGold),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '+${NoorCoinValues.kYwtlNoorCoins} Noor Coins',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.noorGold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Watch button
                AmalGoldButton(
                  label: watched ? l10n.ywtlWatchAgain : l10n.ywtlWatchToday,
                  onPressed: onWatch,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// Week Day Card
// ══════════════════════════════════════════════════════════════════════════════

class _WeekDayCard extends StatelessWidget {
  const _WeekDayCard({
    required this.dayName,
    required this.wingCode,
    required this.isToday,
    required this.isPast,
    required this.isFuture,
    required this.watched,
    required this.isSelected,
    required this.daysUntil,
    this.onTap,
  });

  final String dayName;
  final String wingCode;
  final bool isToday;
  final bool isPast;
  final bool isFuture;
  final bool watched;
  final bool isSelected;
  final int daysUntil;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final color = _wingColor(wingCode);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 88,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.1)
              : cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isToday
                ? AppColors.primaryGold
                : isSelected
                    ? color
                    : AppColors.transparent,
            width: isToday ? 2.0 : 1.0,
          ),
        ),
        child: Stack(
          children: [
            // Main content
            Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Day name
                  Text(
                    dayName,
                    style: AppTypography.labelSmall.copyWith(
                      color: isFuture
                          ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                          : cs.onSurface,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Wing icon
                  Icon(
                    _wingIcon(wingCode),
                    size: AppSpacing.iconMd,
                    color: isFuture
                        ? cs.onSurfaceVariant.withValues(alpha: 0.3)
                        : color,
                  ),
                  const SizedBox(height: AppSpacing.xs),

                  // Status indicator
                  if (isFuture)
                    Text(
                      l10n.ywtlAvailableIn(daysUntil),
                      style: AppTypography.labelSmall.copyWith(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        fontSize: 9,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                    )
                  else if (watched)
                    const Icon(Icons.check_circle_rounded,
                        size: 18, color: AppColors.success)
                  else
                    Icon(Icons.play_circle_outline_rounded,
                        size: 18, color: color),
                ],
              ),
            ),

            // Lock overlay for future days
            if (isFuture)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: cs.surface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.lock_outline_rounded,
                      size: 16,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.4),
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

// ══════════════════════════════════════════════════════════════════════════════
// YWTL Player View
// ══════════════════════════════════════════════════════════════════════════════

class _YwtlPlayerView extends StatefulWidget {
  const _YwtlPlayerView({required this.video});
  final YwtlVideo video;

  @override
  State<_YwtlPlayerView> createState() => _YwtlPlayerViewState();
}

class _YwtlPlayerViewState extends State<_YwtlPlayerView> {
  VideoPlayerController? _controller;
  bool _videoCompleted = false;
  bool _coinsCollecting = false;
  bool _coinsCollected = false;
  bool _hasVideoUrl = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    final url = widget.video.videoUrl;
    if (url.isEmpty) {
      // Placeholder video — no actual URL yet
      setState(() => _hasVideoUrl = false);
      return;
    }

    setState(() => _hasVideoUrl = true);

    try {
      _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await _controller!.initialize();
      _controller!.addListener(_onVideoProgress);
      _controller!.play();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) setState(() => _errorMsg = e.toString());
    }
  }

  void _onVideoProgress() {
    if (_controller == null || _videoCompleted) return;
    final pos = _controller!.value.position;
    final dur = _controller!.value.duration;
    if (dur > Duration.zero &&
        pos >= dur - const Duration(milliseconds: 500)) {
      setState(() => _videoCompleted = true);
      _controller!.pause();
    }
  }

  Future<void> _collectCoins() async {
    if (_coinsCollecting) return;
    setState(() => _coinsCollecting = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('Not authenticated');

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // Award coins via Cloud Function
      final callable =
          FirebaseFunctions.instance.httpsCallable('updateNoorWallet');
      await callable.call<Map<String, dynamic>>({
        'uid': uid,
        'amount': NoorCoinValues.kYwtlNoorCoins,
        'source': 'ywtl',
      });

      // Write watch log
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('ywtlLog')
          .doc(today)
          .set({
        'videoId': widget.video.videoId,
        'watched': true,
        'coinsCollected': true,
        'collectedAt': FieldValue.serverTimestamp(),
      });

      // Extend garden access timer (6 hours)
      try {
        await FirebaseFunctions.instance
            .httpsCallable('updateGardenAccessTimer')
            .call<Map<String, dynamic>>({
          'uid': uid,
          'hoursToAdd': 6,
        });
      } catch (_) {
        // Non-critical
      }

      if (mounted) {
        setState(() {
          _coinsCollected = true;
          _coinsCollecting = false;
        });

        // Show celebration
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)
                  .ywtlCoinsCollected(NoorCoinValues.kYwtlNoorCoins),
            ),
            backgroundColor: AppColors.primaryGold,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _coinsCollecting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  /// Simulate "watching" for placeholder videos without a real URL.
  Future<void> _simulateWatch() async {
    // Mark as completed immediately for placeholders
    setState(() => _videoCompleted = true);
  }

  @override
  void dispose() {
    _controller?.removeListener(_onVideoProgress);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final wingEntry = _wingSchedule[widget.video.dayOfWeek]!;
    final color = _wingColor(widget.video.wingCode);

    return Scaffold(
      appBar: AppBar(
        title: Text(wingEntry.$2, style: AppTypography.titleSmall),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Video area ────────────────────────────────────────────────
            Expanded(
              child: _hasVideoUrl && _controller != null
                  ? _buildVideoPlayer(cs)
                  : _buildPlaceholderPlayer(color, cs, l10n),
            ),

            // ── Bottom controls ───────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.video.localizedTitle(locale),
                    style: AppTypography.titleMedium
                        .copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  if (_videoCompleted && !_coinsCollected)
                    AmalGoldButton(
                      label: l10n.ywtlCollectCoins,
                      onPressed: _collectCoins,
                      isLoading: _coinsCollecting,
                    )
                  else if (_coinsCollected)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.noorGold.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stars_rounded,
                              color: AppColors.noorGold),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            l10n.ywtlCoinsCollected(
                                NoorCoinValues.kYwtlNoorCoins),
                            style: AppTypography.noorCoinLabel
                                .copyWith(color: AppColors.noorGold),
                          ),
                        ],
                      ),
                    )
                  else
                    _buildProgressInfo(cs, l10n),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(ColorScheme cs) {
    if (!_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
        ),
        // Progress bar
        VideoProgressIndicator(
          _controller!,
          allowScrubbing: true,
          colors: VideoProgressColors(
            playedColor: AppColors.primaryGold,
            bufferedColor: AppColors.primaryGold.withValues(alpha: 0.3),
            backgroundColor: cs.surfaceContainerHighest,
          ),
        ),
        // Play/Pause controls
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _controller!.value.isPlaying
                      ? Icons.pause_circle_filled_rounded
                      : Icons.play_circle_fill_rounded,
                  size: 40,
                  color: cs.primary,
                ),
                onPressed: () {
                  setState(() {
                    _controller!.value.isPlaying
                        ? _controller!.pause()
                        : _controller!.play();
                  });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderPlayer(
      Color color, ColorScheme cs, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.6),
            color.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _wingIcon(widget.video.wingCode),
              size: 80,
              color: AppColors.white.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (!_videoCompleted)
              ElevatedButton.icon(
                onPressed: _simulateWatch,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(l10n.ywtlWatchToday),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              )
            else
              Icon(Icons.check_circle_rounded,
                  size: 64, color: AppColors.success),
            if (_errorMsg != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                _errorMsg!,
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInfo(ColorScheme cs, AppLocalizations l10n) {
    return Row(
      children: [
        Icon(Icons.info_outline_rounded,
            size: 16, color: cs.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            l10n.ywtlWatchFullVideo(NoorCoinValues.kYwtlNoorCoins),
            style: AppTypography.bodySmall
                .copyWith(color: cs.onSurfaceVariant),
          ),
        ),
      ],
    );
  }
}
