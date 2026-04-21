import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/noor_coin_values.dart';
import '../../core/l10n/app_localizations.dart';

// ── Dhikr model ────────────────────────────────────────────────────────────

class _Dhikr {
  const _Dhikr({
    required this.id,
    required this.arabic,
    required this.defaultTarget,
    required this.labelKey,
  });

  final String id;
  final String arabic;
  final int defaultTarget;
  final String labelKey;
}

const _kDhikrs = [
  _Dhikr(
    id: 'subhanallah',
    arabic: '\u0633\u0628\u062D\u0627\u0646 \u0627\u0644\u0644\u0647',
    defaultTarget: 33,
    labelKey: 'subhanallah',
  ),
  _Dhikr(
    id: 'alhamdulillah',
    arabic: '\u0627\u0644\u062D\u0645\u062F \u0644\u0644\u0647',
    defaultTarget: 33,
    labelKey: 'alhamdulillah',
  ),
  _Dhikr(
    id: 'allahuakbar',
    arabic: '\u0627\u0644\u0644\u0647 \u0623\u0643\u0628\u0631',
    defaultTarget: 34,
    labelKey: 'allahuakbar',
  ),
  _Dhikr(
    id: 'astaghfirullah',
    arabic:
        '\u0623\u0633\u062A\u063A\u0641\u0631 \u0627\u0644\u0644\u0647',
    defaultTarget: 100,
    labelKey: 'astaghfirullah',
  ),
];

// ── Session log model ──────────────────────────────────────────────────────

class _TasbeehSession {
  const _TasbeehSession({
    required this.dhikrId,
    required this.count,
    required this.target,
    required this.completedAt,
  });

  final String dhikrId;
  final int count;
  final int target;
  final DateTime completedAt;

  factory _TasbeehSession.fromFirestore(Map<String, dynamic> data) {
    return _TasbeehSession(
      dhikrId: data['dhikrName'] as String? ?? '',
      count: data['count'] as int? ?? 0,
      target: data['target'] as int? ?? 0,
      completedAt: (data['completedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }
}

// ── Main screen ────────────────────────────────────────────────────────────

class TasbeehScreen extends ConsumerStatefulWidget {
  const TasbeehScreen({super.key});

  @override
  ConsumerState<TasbeehScreen> createState() => _TasbeehScreenState();
}

class _TasbeehScreenState extends ConsumerState<TasbeehScreen>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  int _count = 0;
  late int _target;
  bool _completed = false;
  bool _showCelebration = false;
  bool _awarding = false;

  late final AnimationController _tapAnimCtrl;
  late final Animation<double> _tapScale;

  late final AnimationController _rippleAnimCtrl;
  late final Animation<double> _rippleScale;
  late final Animation<double> _rippleOpacity;

  late final AnimationController _celebrationCtrl;
  late final Animation<double> _celebrationScale;
  late final Animation<double> _celebrationOpacity;

  final TextEditingController _targetCtrl = TextEditingController();

  List<_TasbeehSession> _recentSessions = [];
  bool _loadingHistory = true;

  _Dhikr get _currentDhikr => _kDhikrs[_selectedIndex];

  @override
  void initState() {
    super.initState();
    _target = _kDhikrs[_selectedIndex].defaultTarget;
    _targetCtrl.text = _target.toString();

    // Tap bounce animation
    _tapAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _tapScale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _tapAnimCtrl, curve: Curves.easeInOut),
    );

    // Ripple animation
    _rippleAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _rippleScale = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _rippleAnimCtrl, curve: Curves.easeOut),
    );
    _rippleOpacity = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(parent: _rippleAnimCtrl, curve: Curves.easeOut),
    );

    // Celebration animation
    _celebrationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _celebrationScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _celebrationCtrl, curve: Curves.elasticOut),
    );
    _celebrationOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _celebrationCtrl,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _loadHistory();
  }

  @override
  void dispose() {
    _tapAnimCtrl.dispose();
    _rippleAnimCtrl.dispose();
    _celebrationCtrl.dispose();
    _targetCtrl.dispose();
    super.dispose();
  }

  // ── Firebase operations ──────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loadingHistory = false);
      return;
    }
    try {
      final sevenDaysAgo =
          DateTime.now().subtract(const Duration(days: 7));
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasbeehLog')
          .where('completedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .orderBy('completedAt', descending: true)
          .limit(50)
          .get();
      if (mounted) {
        setState(() {
          _recentSessions = snap.docs
              .map((d) => _TasbeehSession.fromFirestore(d.data()))
              .toList();
          _loadingHistory = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  Future<void> _onSessionComplete() async {
    setState(() {
      _completed = true;
      _showCelebration = true;
      _awarding = true;
    });
    _celebrationCtrl.forward(from: 0.0);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Award Noor Coins
      await FirebaseFunctions.instance
          .httpsCallable('updateNoorWallet')
          .call(<String, dynamic>{
        'uid': user.uid,
        'amount': NoorCoinValues.kTasbeehNoorCoins,
        'source': 'tasbeeh',
        'dhikrName': _currentDhikr.id,
        'count': _count,
      });

      // Log session
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('tasbeehLog')
          .add({
        'dhikrName': _currentDhikr.id,
        'count': _count,
        'target': _target,
        'completedAt': FieldValue.serverTimestamp(),
      });

      await _loadHistory();
    } catch (_) {
      // Silently handle — coins may still be awarded server-side
    } finally {
      if (mounted) setState(() => _awarding = false);
    }
  }

  // ── Tap handler ──────────────────────────────────────────────────────────

  void _onTap() {
    if (_completed) return;

    HapticFeedback.lightImpact();

    _tapAnimCtrl.forward().then((_) => _tapAnimCtrl.reverse());
    _rippleAnimCtrl.forward(from: 0.0);

    setState(() {
      _count++;
      if (_count >= _target) {
        _onSessionComplete();
      }
    });
  }

  void _reset() {
    setState(() {
      _count = 0;
      _completed = false;
      _showCelebration = false;
      _awarding = false;
    });
    _celebrationCtrl.reset();
  }

  void _selectDhikr(int index) {
    if (index == _selectedIndex) return;
    setState(() {
      _selectedIndex = index;
      _count = 0;
      _completed = false;
      _showCelebration = false;
      _target = _kDhikrs[index].defaultTarget;
      _targetCtrl.text = _target.toString();
    });
    _celebrationCtrl.reset();
  }

  void _updateTarget(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0) {
      setState(() {
        _target = parsed;
        if (_count >= _target && !_completed) {
          _onSessionComplete();
        }
      });
    }
  }

  // ── Localized dhikr label ────────────────────────────────────────────────

  String _dhikrLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'subhanallah':
        return l10n.tasbeehSubhanallah;
      case 'alhamdulillah':
        return l10n.tasbeehAlhamdulillah;
      case 'allahuakbar':
        return l10n.tasbeehAllahuAkbar;
      case 'astaghfirullah':
        return l10n.tasbeehAstaghfirullah;
      default:
        return key;
    }
  }

  // ── History stats ────────────────────────────────────────────────────────

  Map<String, int> get _totalCountPerDhikr {
    final totals = <String, int>{};
    for (final s in _recentSessions) {
      totals[s.dhikrId] = (totals[s.dhikrId] ?? 0) + s.count;
    }
    return totals;
  }

  int get _longestSessionCount {
    if (_recentSessions.isEmpty) return 0;
    return _recentSessions
        .map((s) => s.count)
        .reduce((a, b) => a > b ? a : b);
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final progress = _target > 0 ? (_count / _target).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          l10n.tasbeeh,
          style: AppTypography.titleLarge.copyWith(color: cs.onSurface),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // ── Dhikr selector chips ─────────────────────────────────
              SliverToBoxAdapter(
                child: _buildDhikrSelector(l10n, cs),
              ),

              // ── Arabic text ──────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.lg),
                  child: Center(
                    child: Text(
                      _currentDhikr.arabic,
                      style: AppTypography.arabicBody.copyWith(
                        color: cs.onSurface,
                        fontSize: 32,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
              ),

              // ── Transliterated name ──────────────────────────────────
              SliverToBoxAdapter(
                child: Center(
                  child: Text(
                    _dhikrLabel(_currentDhikr.labelKey, l10n),
                    style: AppTypography.bodyMedium
                        .copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ),

              // ── Counter button ───────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xl),
                  child: Center(
                    child: _buildCounterButton(cs, progress),
                  ),
                ),
              ),

              // ── Target + Reset controls ──────────────────────────────
              SliverToBoxAdapter(
                child: _buildControls(l10n, cs),
              ),

              // ── Session history ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.sm),
                  child: Text(
                    l10n.tasbeehSessionHistory,
                    style: AppTypography.titleMedium
                        .copyWith(color: cs.onSurface),
                  ),
                ),
              ),

              // ── Stats row ────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _buildStatsRow(l10n, cs),
              ),

              // ── Recent sessions list ─────────────────────────────────
              if (_loadingHistory)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                )
              else if (_recentSessions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Center(
                      child: Text(
                        '—',
                        style: AppTypography.bodyMedium
                            .copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg),
                  sliver: SliverList.separated(
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemCount: _recentSessions.length,
                    itemBuilder: (context, i) =>
                        _buildSessionTile(_recentSessions[i], l10n, cs),
                  ),
                ),

              const SliverToBoxAdapter(
                child: SizedBox(height: AppSpacing.xxxl),
              ),
            ],
          ),

          // ── Celebration overlay ─────────────────────────────────────
          if (_showCelebration) _buildCelebrationOverlay(l10n, cs),
        ],
      ),
    );
  }

  // ── Dhikr selector ────────────────────────────────────────────────────────

  Widget _buildDhikrSelector(AppLocalizations l10n, ColorScheme cs) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        separatorBuilder: (_, _) =>
            const SizedBox(width: AppSpacing.sm),
        itemCount: _kDhikrs.length,
        itemBuilder: (context, i) {
          final dhikr = _kDhikrs[i];
          final selected = i == _selectedIndex;
          return GestureDetector(
            onTap: () => _selectDhikr(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primaryGreen
                    : cs.surfaceContainerHighest,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
              ),
              alignment: Alignment.center,
              child: Text(
                _dhikrLabel(dhikr.labelKey, l10n),
                style: AppTypography.labelLarge.copyWith(
                  color: selected ? AppColors.white : cs.onSurfaceVariant,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Counter button ────────────────────────────────────────────────────────

  Widget _buildCounterButton(ColorScheme cs, double progress) {
    const double size = 200;

    return GestureDetector(
      onTap: _onTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([_tapAnimCtrl, _rippleAnimCtrl]),
        builder: (context, child) {
          return SizedBox(
            width: size + 60,
            height: size + 60,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple circle
                if (_rippleAnimCtrl.isAnimating)
                  Transform.scale(
                    scale: _rippleScale.value,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primaryGreen
                            .withValues(alpha: _rippleOpacity.value),
                      ),
                    ),
                  ),

                // Progress ring
                SizedBox(
                  width: size + 16,
                  height: size + 16,
                  child: CustomPaint(
                    painter: _ProgressRingPainter(
                      progress: progress,
                      trackColor: cs.surfaceContainerHighest,
                      progressColor: _completed
                          ? AppColors.noorGold
                          : AppColors.primaryGreen,
                      strokeWidth: 6,
                    ),
                  ),
                ),

                // Main tap circle
                Transform.scale(
                  scale: _tapScale.value,
                  child: Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _completed
                          ? AppColors.primaryGreen.withValues(alpha: 0.15)
                          : AppColors.primaryGreen.withValues(alpha: 0.1),
                      border: Border.all(
                        color: _completed
                            ? AppColors.noorGold
                            : AppColors.primaryGreen,
                        width: 3,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$_count',
                          style: AppTypography.displayLarge.copyWith(
                            color: _completed
                                ? AppColors.noorGold
                                : AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                            fontSize: 52,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          '$_count / $_target',
                          style: AppTypography.bodySmall.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Controls bar ──────────────────────────────────────────────────────────

  Widget _buildControls(AppLocalizations l10n, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          // Reset button
          OutlinedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.tasbeehReset),
            style: OutlinedButton.styleFrom(
              foregroundColor: cs.onSurfaceVariant,
              side: BorderSide(color: cs.outline),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            ),
          ),
          const Spacer(),
          // Target field
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.tasbeehTarget,
                style: AppTypography.bodyMedium
                    .copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: AppSpacing.sm),
              SizedBox(
                width: 72,
                height: 40,
                child: TextField(
                  controller: _targetCtrl,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: AppTypography.titleSmall
                      .copyWith(color: cs.onSurface),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      borderSide: BorderSide(color: cs.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusSm),
                      borderSide: const BorderSide(
                          color: AppColors.primaryGreen, width: 2),
                    ),
                  ),
                  onSubmitted: _updateTarget,
                  onChanged: _updateTarget,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow(AppLocalizations l10n, ColorScheme cs) {
    final totals = _totalCountPerDhikr;
    final totalAll =
        totals.values.fold<int>(0, (acc, v) => acc + v);
    final longest = _longestSessionCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: l10n.tasbeehTotalCount,
              value: totalAll.toString(),
              cs: cs,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _StatCard(
              label: l10n.tasbeehLongestSession,
              value: longest.toString(),
              cs: cs,
            ),
          ),
        ],
      ),
    );
  }

  // ── Session tile ──────────────────────────────────────────────────────────

  Widget _buildSessionTile(
      _TasbeehSession session, AppLocalizations l10n, ColorScheme cs) {
    final label = _dhikrLabel(session.dhikrId, l10n);
    final dateStr = _formatDate(session.completedAt, l10n);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withValues(alpha: 0.1),
              borderRadius:
                  BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: const Center(
              child: Icon(Icons.check_rounded,
                  color: AppColors.primaryGreen, size: 20),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.titleSmall
                      .copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  '${session.count} / ${session.target}',
                  style: AppTypography.bodySmall
                      .copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            dateStr,
            style: AppTypography.labelSmall
                .copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    return l10n.timeDaysAgo(diff.inDays);
  }

  // ── Celebration overlay ───────────────────────────────────────────────────

  Widget _buildCelebrationOverlay(AppLocalizations l10n, ColorScheme cs) {
    return AnimatedBuilder(
      animation: _celebrationCtrl,
      builder: (context, _) {
        return Positioned.fill(
          child: IgnorePointer(
            ignoring: !_showCelebration,
            child: GestureDetector(
              onTap: () => setState(() => _showCelebration = false),
              child: Container(
                color: AppColors.black.withValues(
                    alpha: 0.5 * _celebrationOpacity.value),
                child: Center(
                  child: Transform.scale(
                    scale: _celebrationScale.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: cs.surface,
                        borderRadius: BorderRadius.circular(
                            AppSpacing.radiusXl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.noorGold.withValues(alpha: 0.3),
                            blurRadius: 24,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryGreen,
                            ),
                            child: const Icon(
                              Icons.check_rounded,
                              color: AppColors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l10n.tasbeehSessionComplete,
                            style: AppTypography.headlineSmall.copyWith(
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _currentDhikr.arabic,
                            style: AppTypography.arabicBody.copyWith(
                              color: cs.onSurface,
                              fontSize: 24,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            '$_count / $_target',
                            style: AppTypography.bodyMedium
                                .copyWith(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.stars_rounded,
                                color: AppColors.noorGold,
                                size: 28,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                _awarding
                                    ? '...'
                                    : l10n.tasbeehCoinsAwarded(
                                        NoorCoinValues.kTasbeehNoorCoins),
                                style:
                                    AppTypography.noorCoinLabel.copyWith(
                                  color: AppColors.noorGold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: () {
                                setState(
                                    () => _showCelebration = false);
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor:
                                    AppColors.primaryGreen,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppSpacing.md),
                              ),
                              child: Text(
                                l10n.continueButton,
                                style: AppTypography.labelLarge
                                    .copyWith(color: AppColors.white),
                              ),
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

// ── Progress ring painter ──────────────────────────────────────────────────

class _ProgressRingPainter extends CustomPainter {
  _ProgressRingPainter({
    required this.progress,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      const startAngle = -math.pi / 2;
      final sweepAngle = 2 * math.pi * progress;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressRingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.progressColor != progressColor;
}

// ── Stat card widget ───────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.cs,
  });

  final String label;
  final String value;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTypography.headlineMedium
                .copyWith(color: AppColors.primaryGreen),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            label,
            style: AppTypography.labelSmall
                .copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
