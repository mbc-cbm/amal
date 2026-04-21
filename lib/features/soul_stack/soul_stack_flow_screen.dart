import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/noor_coin_values.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/soul_stack_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/services/soul_stack_service.dart';

// ── Flow step state machine ─────────────────────────────────────────────────

enum _FlowStep {
  adsStart,
  titleReveal,
  waitStart,
  swipeInstruction,
  whatIsStack,
  adsMiddle,
  waitReady,
  videos,
  adsEnd,
  achievement,
}

// ── Soul Stack Flow Screen ──────────────────────────────────────────────────

class SoulStackFlowScreen extends ConsumerStatefulWidget {
  const SoulStackFlowScreen({super.key, required this.stackName});

  final StackName stackName;

  @override
  ConsumerState<SoulStackFlowScreen> createState() =>
      _SoulStackFlowScreenState();
}

class _SoulStackFlowScreenState extends ConsumerState<SoulStackFlowScreen>
    with TickerProviderStateMixin {
  _FlowStep _step = _FlowStep.adsStart;
  bool _swipeLocked = true;
  bool _showingAds = false;

  // Video page state
  late final PageController _pageController;
  int _currentVideoIndex = 0;
  static const int _totalVideos = 5;

  // Title reveal animation
  late final AnimationController _titleAnimController;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _titleScale;

  // Swipe instruction animation
  late final AnimationController _arrowAnimController;
  late final Animation<double> _arrowOffset;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _titleAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _titleOpacity = CurvedAnimation(
      parent: _titleAnimController,
      curve: Curves.easeIn,
    );
    _titleScale = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _titleAnimController, curve: Curves.elasticOut),
    );

    _arrowAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _arrowOffset = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(parent: _arrowAnimController, curve: Curves.easeInOut),
    );

    // Start the flow
    _runAds();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _titleAnimController.dispose();
    _arrowAnimController.dispose();
    super.dispose();
  }

  // ── Step transitions ──────────────────────────────────────────────────────

  void _advance() {
    if (!mounted) return;
    final steps = _FlowStep.values;
    final idx = steps.indexOf(_step);
    if (idx < steps.length - 1) {
      setState(() => _step = steps[idx + 1]);
      _onStepEntered();
    }
  }

  void _onStepEntered() {
    switch (_step) {
      case _FlowStep.adsStart:
      case _FlowStep.adsMiddle:
      case _FlowStep.adsEnd:
        _runAds();
      case _FlowStep.titleReveal:
        _titleAnimController.forward();
        Future.delayed(const Duration(seconds: 2), _advance);
      case _FlowStep.waitStart:
        setState(() => _swipeLocked = true);
      case _FlowStep.swipeInstruction:
        Future.delayed(const Duration(seconds: 2), _advance);
      case _FlowStep.whatIsStack:
        Future.delayed(const Duration(seconds: 3), () {
          if (_step == _FlowStep.whatIsStack) _advance();
        });
      case _FlowStep.waitReady:
        setState(() => _swipeLocked = true);
      case _FlowStep.videos:
        setState(() {
          _swipeLocked = false;
          _currentVideoIndex = 0;
        });
      case _FlowStep.achievement:
        _completeStack();
    }
  }

  Future<void> _runAds() async {
    setState(() => _showingAds = true);
    try {
      final adService = ref.read(adServiceProvider);
      await adService.loadInterstitial();
      await adService.showDoubleInterstitial();
    } catch (_) {
      // Graceful degradation — ads may fail in dev
    }
    if (!mounted) return;
    setState(() => _showingAds = false);
    _advance();
  }

  Future<void> _completeStack() async {
    try {
      final svc = ref.read(soulStackServiceProvider);
      await svc.completeStack(widget.stackName);
    } catch (_) {
      // Best-effort
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_showingAds,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: _buildStepContent(),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step) {
      case _FlowStep.adsStart:
      case _FlowStep.adsMiddle:
      case _FlowStep.adsEnd:
        return _buildLoadingStep();
      case _FlowStep.titleReveal:
        return _buildTitleReveal();
      case _FlowStep.waitStart:
        return _buildWaitButton(isStart: true);
      case _FlowStep.swipeInstruction:
        return _buildSwipeInstruction();
      case _FlowStep.whatIsStack:
        return _buildWhatIsStack();
      case _FlowStep.waitReady:
        return _buildWaitButton(isStart: false);
      case _FlowStep.videos:
        return _buildVideos();
      case _FlowStep.achievement:
        return _buildAchievement();
    }
  }

  // ── Loading / Ad placeholder ──────────────────────────────────────────────

  Widget _buildLoadingStep() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          const SizedBox(height: AppSpacing.md),
          Text(
            AppLocalizations.of(context).loading,
            style: AppTypography.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  // ── Title reveal ──────────────────────────────────────────────────────────

  Widget _buildTitleReveal() {
    final cs = Theme.of(context).colorScheme;
    final displayName = widget.stackName.name[0].toUpperCase() +
        widget.stackName.name.substring(1);

    return Center(
      child: FadeTransition(
        opacity: _titleOpacity,
        child: ScaleTransition(
          scale: _titleScale,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForStack(widget.stackName),
                size: 80,
                color: AppColors.primaryGold,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                displayName,
                style: AppTypography.displayLarge.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Wait buttons (Start / Ready) ─────────────────────────────────────────

  Widget _buildWaitButton({required bool isStart}) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final label = isStart ? l10n.soulStackStart : l10n.soulStackReady;

    return GestureDetector(
      // Block all swipe gestures when locked
      onVerticalDragUpdate: _swipeLocked ? (_) {} : null,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _iconForStack(widget.stackName),
              size: AppSpacing.iconXl,
              color: AppColors.primaryGold,
            ),
            const SizedBox(height: AppSpacing.xxl),
            SizedBox(
              width: 200,
              height: 56,
              child: FilledButton(
                onPressed: () {
                  setState(() => _swipeLocked = false);
                  _advance();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(
                  label,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              l10n.soulStack,
              style: AppTypography.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Swipe instruction ─────────────────────────────────────────────────────

  Widget _buildSwipeInstruction() {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _arrowOffset,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _arrowOffset.value),
                child: child,
              );
            },
            child: Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 72,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.soulStackSwipeUp,
            style: AppTypography.titleLarge.copyWith(
              color: cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  // ── What is this stack ────────────────────────────────────────────────────

  Widget _buildWhatIsStack() {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    final String explanation;
    switch (widget.stackName) {
      case StackName.rise:
        explanation = l10n.soulStackWhatIsRise;
      case StackName.shine:
        explanation = l10n.soulStackWhatIsShine;
      case StackName.glow:
        explanation = l10n.soulStackWhatIsGlow;
    }

    return GestureDetector(
      onTap: _advance,
      behavior: HitTestBehavior.opaque,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _iconForStack(widget.stackName),
                size: 64,
                color: AppColors.primaryGold,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                explanation,
                textAlign: TextAlign.center,
                style: AppTypography.bodyLarge.copyWith(
                  color: cs.onSurface,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Video pages ───────────────────────────────────────────────────────────

  Widget _buildVideos() {
    final content = ref.watch(
      dailyStackContentProvider(widget.stackName),
    );

    return content.when(
      loading: () => _buildLoadingStep(),
      error: (_, _) => _buildLoadingStep(),
      data: (dailyContent) => _buildVideoPageView(dailyContent),
    );
  }

  Widget _buildVideoPageView(DailyStackContent dailyContent) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onVerticalDragEnd: _swipeLocked
          ? null
          : (details) {
              // Swipe up to advance
              if (details.primaryVelocity != null &&
                  details.primaryVelocity! < -200) {
                if (_currentVideoIndex < _totalVideos - 1) {
                  setState(() => _currentVideoIndex++);
                  _pageController.animateToPage(
                    _currentVideoIndex,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                } else {
                  // After 5th video, advance to next step
                  _advance();
                }
              }
            },
      child: Column(
        children: [
          // ── Progress indicator ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: cs.onSurface),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentVideoIndex + 1) / _totalVideos,
                    backgroundColor: cs.onSurface.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryGold,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.soulStackProgress(
                    _currentVideoIndex + 1,
                  ),
                  style: AppTypography.labelMedium.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),

          // ── Video page view ────────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _totalVideos,
              itemBuilder: (context, index) {
                final amalId = index < dailyContent.videoAmalIds.length
                    ? dailyContent.videoAmalIds[index]
                    : 'placeholder_amal_${index + 1}';
                return _VideoPlaceholderCard(
                  amalId: amalId,
                  videoIndex: index + 1,
                  totalVideos: _totalVideos,
                );
              },
            ),
          ),

          // ── Swipe hint ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            child: Text(
              l10n.soulStackSwipeUp,
              style: AppTypography.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Achievement screen ────────────────────────────────────────────────────

  Widget _buildAchievement() {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Celebration icon ────────────────────────────────────────
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.noorGold.withValues(alpha: 0.2),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.noorGold.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppColors.noorGold,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // ── MashaAllah ─────────────────────────────────────────────
            Text(
              l10n.soulStackMashaAllah,
              style: AppTypography.displaySmall.copyWith(
                color: AppColors.noorGold,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // ── Coins earned ───────────────────────────────────────────
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.stars_rounded,
                  color: AppColors.noorGold,
                  size: AppSpacing.iconLg,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  l10n.soulStackCoinsEarned(
                    NoorCoinValues.kSoulStackNoorCoins,
                  ),
                  style: AppTypography.noorCoinLabel.copyWith(
                    color: AppColors.noorGold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Garden access ──────────────────────────────────────────
            Text(
              l10n.soulStackGardenAccess,
              style: AppTypography.bodyLarge.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // ── Sadaqa message ─────────────────────────────────────────
            Text(
              l10n.soulStackSadaqaMessage,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // ── Watch YWTL button ──────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(AppRoutes.ywtl),
                icon: const Icon(Icons.play_circle_outline_rounded),
                label: Text(l10n.soulStackWatchYwtl),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryGreen,
                  side: BorderSide(
                    color: AppColors.primaryGreen.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + AppSpacing.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Done button ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm + AppSpacing.xs,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(
                  l10n.soulStackDone,
                  style: AppTypography.labelLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  static IconData _iconForStack(StackName name) {
    switch (name) {
      case StackName.rise:
        return Icons.wb_sunny_rounded;
      case StackName.shine:
        return Icons.wb_twilight_rounded;
      case StackName.glow:
        return Icons.nightlight_round;
    }
  }
}

// ── Video placeholder card ──────────────────────────────────────────────────

class _VideoPlaceholderCard extends StatelessWidget {
  const _VideoPlaceholderCard({
    required this.amalId,
    required this.videoIndex,
    required this.totalVideos,
  });

  final String amalId;
  final int videoIndex;
  final int totalVideos;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceVariantDark
              : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: cs.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Play icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGreen.withValues(alpha: 0.15),
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                size: AppSpacing.iconXl,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Amal title placeholder
            Text(
              'Dua $videoIndex',
              style: AppTypography.headlineSmall.copyWith(
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Amal ID
            Text(
              amalId,
              style: AppTypography.bodySmall.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Arabic placeholder
            Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              style: AppTypography.arabicBody.copyWith(
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
