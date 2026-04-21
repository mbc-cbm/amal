import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/amal_model.dart';
import '../../core/providers/amal_gallery_provider.dart';
import '../../shared/widgets/amal_button.dart';

class AmalDetailScreen extends ConsumerStatefulWidget {
  const AmalDetailScreen({super.key, required this.amal});

  final AmalModel amal;

  @override
  ConsumerState<AmalDetailScreen> createState() => _AmalDetailScreenState();
}

class _AmalDetailScreenState extends ConsumerState<AmalDetailScreen> {
  bool _completing = false;
  bool _completed = false;
  int _completionCount = 0;
  bool _videoFinished = false;

  VideoPlayerController? _videoCtrl;

  AmalModel get amal => widget.amal;

  @override
  void initState() {
    super.initState();
    _loadCompletionCount();

    if (amal.contentType == AmalContentType.video && amal.videoUrl.isNotEmpty) {
      _videoCtrl = VideoPlayerController.networkUrl(Uri.parse(amal.videoUrl))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _videoCtrl!.play();
          }
        });
      _videoCtrl!.addListener(_onVideoUpdate);
    }
  }

  void _onVideoUpdate() {
    final ctrl = _videoCtrl;
    if (ctrl == null) return;
    if (ctrl.value.isInitialized &&
        ctrl.value.position >= ctrl.value.duration &&
        ctrl.value.duration > Duration.zero &&
        !_videoFinished) {
      setState(() => _videoFinished = true);
    }
  }

  Future<void> _loadCompletionCount() async {
    final period = switch (amal.completionType) {
      AmalCompletionType.daily => 'today',
      AmalCompletionType.weekly => 'this_week',
      AmalCompletionType.oneTime => 'all_time',
      AmalCompletionType.ongoing => 'all_time',
    };

    try {
      final count = await ref.read(
        amalCompletionCountProvider(
          (amalId: amal.id, period: period),
        ).future,
      );
      if (mounted) {
        setState(() {
          _completionCount = count;
          if (amal.completionType == AmalCompletionType.oneTime && count > 0) {
            _completed = true;
          }
        });
      }
    } catch (_) {
      // Silently handle — count stays 0.
    }
  }

  @override
  void dispose() {
    _videoCtrl?.removeListener(_onVideoUpdate);
    _videoCtrl?.dispose();
    super.dispose();
  }

  Future<void> _onComplete() async {
    setState(() => _completing = true);

    try {
      await ref.read(amalGalleryServiceProvider).completeAmal(
            amalId: amal.id,
            noorCoins: amal.noorCoins,
          );

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.stars_rounded,
                    color: AppColors.noorGold, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.tasbeehCoinsAwarded(amal.noorCoins),
                  style: AppTypography.labelLarge
                      .copyWith(color: AppColors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.primaryGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
        );

        setState(() {
          _completing = false;
          _completionCount++;
          if (amal.completionType == AmalCompletionType.oneTime) {
            _completed = true;
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _completing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorGeneric),
          ),
        );
      }
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _difficultyColor(AmalDifficulty difficulty) {
    return switch (difficulty) {
      AmalDifficulty.easy => AppColors.success,
      AmalDifficulty.medium => AppColors.warning,
      AmalDifficulty.high => AppColors.error,
    };
  }

  String _difficultyLabel(AmalDifficulty difficulty, AppLocalizations l10n) {
    return switch (difficulty) {
      AmalDifficulty.easy => l10n.amalDifficultyEasy,
      AmalDifficulty.medium => l10n.amalDifficultyMedium,
      AmalDifficulty.high => l10n.amalDifficultyHigh,
    };
  }

  String _completionTypeLabel(
      AmalCompletionType type, AppLocalizations l10n) {
    return switch (type) {
      AmalCompletionType.oneTime => l10n.amalOneTime,
      AmalCompletionType.daily => l10n.amalDaily,
      AmalCompletionType.weekly => l10n.amalWeekly,
      AmalCompletionType.ongoing => l10n.amalOngoing,
    };
  }

  String? _completionStatusText(AppLocalizations l10n) {
    if (amal.completionType == AmalCompletionType.oneTime && _completed) {
      return l10n.amalCompleted;
    }
    if (_completionCount > 0 &&
        (amal.completionType == AmalCompletionType.daily ||
            amal.completionType == AmalCompletionType.weekly)) {
      return l10n.amalCompletedTimes(_completionCount);
    }
    return null;
  }

  bool get _canComplete {
    if (_completing) return false;
    if (amal.completionType == AmalCompletionType.oneTime && _completed) {
      return false;
    }
    if (amal.contentType == AmalContentType.video && !_videoFinished) {
      return false;
    }
    return true;
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    final favouriteIdsAsync = ref.watch(favouriteAmalIdsProvider);
    final isFavourite =
        favouriteIdsAsync.valueOrNull?.contains(amal.id) ?? false;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          amal.localizedTitle(locale),
          style: AppTypography.titleLarge.copyWith(color: cs.onSurface),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isFavourite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavourite ? AppColors.error : cs.onSurface,
            ),
            onPressed: () {
              ref.read(amalGalleryServiceProvider).toggleFavourite(amal.id);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Video player (video amals only) ─────────────────────────
            if (amal.contentType == AmalContentType.video) ...[
              _buildVideoPlayer(cs, l10n),
              const SizedBox(height: AppSpacing.lg),
            ],

            // ── Title ───────────────────────────────────────────────────
            Text(
              amal.localizedTitle(locale),
              style:
                  AppTypography.headlineSmall.copyWith(color: cs.onSurface),
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Source chip ─────────────────────────────────────────────
            if (amal.source.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: AppSpacing.iconSm,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        '${l10n.amalSource}: ${amal.source}',
                        style: AppTypography.labelSmall
                            .copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Metadata row: difficulty + completion type ──────────────
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                // Difficulty badge
                _MetadataChip(
                  leading: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _difficultyColor(amal.difficulty),
                    ),
                  ),
                  label: _difficultyLabel(amal.difficulty, l10n),
                  cs: cs,
                ),
                // Completion type
                _MetadataChip(
                  leading: Icon(
                    Icons.repeat_rounded,
                    size: AppSpacing.iconSm,
                    color: cs.onSurfaceVariant,
                  ),
                  label: _completionTypeLabel(amal.completionType, l10n),
                  cs: cs,
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Noor Coins reward ───────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.noorGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.noorGold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    color: AppColors.noorGold,
                    size: AppSpacing.iconLg,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.tasbeehCoinsAwarded(amal.noorCoins),
                    style: AppTypography.noorCoinLabel.copyWith(
                      color: AppColors.noorGold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Description ─────────────────────────────────────────────
            Text(
              amal.localizedDescription(locale),
              style: AppTypography.bodyLarge.copyWith(
                color: cs.onSurface,
                height: 1.6,
              ),
            ),

            // ── Dua text (video amals) ──────────────────────────────────
            if (amal.contentType == AmalContentType.video &&
                amal.duaTextAr.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.lg),
              Text(
                amal.duaTextAr,
                style: AppTypography.arabicBody.copyWith(
                  color: cs.onSurface,
                ),
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
              ),
              if (amal.duaTextEn.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  amal.duaTextEn,
                  style: AppTypography.bodyMedium.copyWith(
                    color: cs.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],

            const SizedBox(height: AppSpacing.xl),

            // ── Completion status ───────────────────────────────────────
            if (_completionStatusText(l10n) != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primaryGreen,
                        size: AppSpacing.iconSm,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        _completionStatusText(l10n)!,
                        style: AppTypography.labelLarge.copyWith(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Watch-to-complete prompt (video amals) ──────────────────
            if (amal.contentType == AmalContentType.video &&
                !_videoFinished &&
                !_completed) ...[
              Center(
                child: Text(
                  l10n.amalWatchToComplete,
                  style: AppTypography.bodySmall
                      .copyWith(color: cs.onSurfaceVariant),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            // ── Complete button ─────────────────────────────────────────
            if (_shouldShowCompleteButton())
              AmalPrimaryButton(
                label: l10n.amalCompleteButton,
                onPressed: _canComplete ? _onComplete : null,
                isLoading: _completing,
                icon: const Icon(
                  Icons.check_rounded,
                  color: AppColors.white,
                  size: 20,
                ),
              ),

            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }

  bool _shouldShowCompleteButton() {
    // One-time that is already completed: hide button.
    if (amal.completionType == AmalCompletionType.oneTime && _completed) {
      return false;
    }
    // Video amals: show button only after video finishes.
    if (amal.contentType == AmalContentType.video && !_videoFinished) {
      return false;
    }
    return true;
  }

  // ── Video player widget ────────────────────────────────────────────────────

  Widget _buildVideoPlayer(ColorScheme cs, AppLocalizations l10n) {
    final ctrl = _videoCtrl;
    if (ctrl == null || !ctrl.value.isInitialized) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: AspectRatio(
        aspectRatio: ctrl.value.aspectRatio,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(ctrl),
            // Play/pause overlay
            GestureDetector(
              onTap: () {
                setState(() {
                  ctrl.value.isPlaying ? ctrl.pause() : ctrl.play();
                });
              },
              child: AnimatedOpacity(
                opacity: ctrl.value.isPlaying ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  width: AppSpacing.iconXl,
                  height: AppSpacing.iconXl,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.black.withValues(alpha: 0.5),
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: AppSpacing.iconLg,
                  ),
                ),
              ),
            ),
            // Progress bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                ctrl,
                allowScrubbing: true,
                colors: const VideoProgressColors(
                  playedColor: AppColors.primaryGreen,
                  bufferedColor: AppColors.primaryGreen,
                  backgroundColor: AppColors.divider,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Metadata chip ────────────────────────────────────────────────────────────

class _MetadataChip extends StatelessWidget {
  const _MetadataChip({
    required this.leading,
    required this.label,
    required this.cs,
  });

  final Widget leading;
  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading,
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style:
                AppTypography.labelSmall.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
