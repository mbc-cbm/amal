import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/noor_coin_values.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/amal_button.dart';

// ── Transaction model ────────────────────────────────────────────────────────

class WalletTransaction {
  const WalletTransaction({
    required this.type,
    required this.amount,
    required this.source,
    required this.createdAt,
  });

  final String type; // 'earn' or 'spend'
  final int amount;
  final String source;
  final DateTime createdAt;

  factory WalletTransaction.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WalletTransaction(
      type: data['type'] as String? ?? 'earn',
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      source: data['source'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ── Screen ───────────────────────────────────────────────────────────────────

class NoorWalletScreen extends ConsumerStatefulWidget {
  const NoorWalletScreen({super.key});

  @override
  ConsumerState<NoorWalletScreen> createState() => _NoorWalletScreenState();
}

class _NoorWalletScreenState extends ConsumerState<NoorWalletScreen> {
  final List<WalletTransaction> _transactions = [];
  DocumentSnapshot? _lastDoc;
  bool _hasMore = true;
  bool _loadingMore = false;
  bool _initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    if (_loadingMore || !_hasMore) return;
    setState(() => _loadingMore = true);

    try {
      final walletService = ref.read(walletServiceProvider);
      final snap = await walletService.fetchTransactionPage(
        startAfter: _lastDoc,
        pageSize: 20,
      );

      if (snap.docs.isNotEmpty) {
        _lastDoc = snap.docs.last;
        final newTxns = snap.docs
            .map((doc) => WalletTransaction.fromFirestore(doc))
            .toList();
        _transactions.addAll(newTxns);
      }

      if (snap.docs.length < 20) {
        _hasMore = false;
      }
    } catch (_) {
      // Silently handle — user sees whatever was loaded so far
    } finally {
      if (mounted) {
        setState(() {
          _loadingMore = false;
          _initialLoading = false;
        });
      }
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _timeAgo(DateTime dt, AppLocalizations l10n) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return l10n.timeJustNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.timeDaysAgo(diff.inDays);
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  String _sourceLabel(String source, String type, AppLocalizations l10n) {
    return switch (source) {
      'prayer' => l10n.walletSourcePrayer,
      'fast' || 'ramadan_fast' => l10n.walletSourceFast,
      'tasbeeh' => l10n.walletSourceTasbeeh,
      'soul_stack' => l10n.walletSourceSoulStack,
      'ywtl' => l10n.walletSourceYwtl,
      'amal' => l10n.walletSourceAmal,
      _ when type == 'spend' => l10n.walletSourceGarden,
      _ => source,
    };
  }

  IconData _sourceIcon(String source, String type) {
    return switch (source) {
      'prayer' => Icons.mosque_rounded,
      'fast' || 'ramadan_fast' => Icons.nightlight_round,
      'tasbeeh' => Icons.fiber_manual_record_outlined,
      'soul_stack' => Icons.auto_awesome_rounded,
      'ywtl' => Icons.play_circle_rounded,
      'amal' => Icons.volunteer_activism_rounded,
      _ when type == 'spend' => Icons.park_rounded,
      _ => Icons.star_rounded,
    };
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.noorWallet),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            _transactions.clear();
            _lastDoc = null;
            _hasMore = true;
            _initialLoading = true;
          });
          await _loadTransactions();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          children: [
            _BalanceHeader(isDark: isDark, cs: cs),
            const SizedBox(height: AppSpacing.xl),
            _buildTransactionHistory(l10n, cs, isDark),
            const SizedBox(height: AppSpacing.lg),
            _buildEarningGuide(l10n, cs, isDark),
            const SizedBox(height: AppSpacing.sm),
            _buildSpendingGuide(l10n, cs, isDark),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  // ── Transaction History section ──────────────────────────────────────────

  Widget _buildTransactionHistory(
    AppLocalizations l10n,
    ColorScheme cs,
    bool isDark,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.walletTransactionHistory,
          style: AppTypography.titleLarge.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: AppSpacing.md),
        if (_initialLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSpacing.xl),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_transactions.isEmpty)
          _EmptyTransactions(message: l10n.walletNoTransactions, cs: cs)
        else ...[
          ...List.generate(_transactions.length, (i) {
            final txn = _transactions[i];
            final isEarn = txn.type == 'earn';
            return _TransactionTile(
              icon: _sourceIcon(txn.source, txn.type),
              label: _sourceLabel(txn.source, txn.type, l10n),
              amount: txn.amount,
              isEarn: isEarn,
              timeAgo: _timeAgo(txn.createdAt, l10n),
              isDark: isDark,
            );
          }),
          if (_hasMore)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Center(
                child: _loadingMore
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : AmalOutlinedButton(
                        label: l10n.walletLoadMore,
                        onPressed: _loadTransactions,
                      ),
              ),
            ),
        ],
      ],
    );
  }

  // ── Earning guide ────────────────────────────────────────────────────────

  Widget _buildEarningGuide(
    AppLocalizations l10n,
    ColorScheme cs,
    bool isDark,
  ) {
    final cardColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(Icons.trending_up_rounded, color: AppColors.noorGold),
        title: Text(
          l10n.walletHowToEarn,
          style: AppTypography.titleMedium.copyWith(color: cs.onSurface),
        ),
        childrenPadding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        children: [
          _EarnRow(
            icon: Icons.mosque_rounded,
            label: l10n.walletSourcePrayer,
            amount: '+${NoorCoinValues.kPrayerNoorCoins} x5 = ${NoorCoinValues.kPrayerNoorCoins * 5}',
          ),
          _EarnRow(
            icon: Icons.nightlight_round,
            label: l10n.walletSourceFast,
            amount: '+${NoorCoinValues.kFastNoorCoins}',
          ),
          _EarnRow(
            icon: Icons.fiber_manual_record_outlined,
            label: l10n.walletSourceTasbeeh,
            amount: '+${NoorCoinValues.kTasbeehNoorCoins}',
          ),
          _EarnRow(
            icon: Icons.auto_awesome_rounded,
            label: l10n.walletSourceSoulStack,
            amount: '+${NoorCoinValues.kSoulStackNoorCoins}',
          ),
          _EarnRow(
            icon: Icons.play_circle_rounded,
            label: l10n.walletSourceYwtl,
            amount: '+${NoorCoinValues.kYwtlNoorCoins}',
          ),
          _EarnRow(
            icon: Icons.volunteer_activism_rounded,
            label: l10n.walletSourceAmal,
            amount: '+Variable',
          ),
        ],
      ),
    );
  }

  // ── Spending guide ───────────────────────────────────────────────────────

  Widget _buildSpendingGuide(
    AppLocalizations l10n,
    ColorScheme cs,
    bool isDark,
  ) {
    final cardColor = isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight;

    return Card(
      color: cardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: Icon(Icons.shopping_bag_rounded, color: AppColors.primaryGold),
        title: Text(
          l10n.walletHowToSpend,
          style: AppTypography.titleMedium.copyWith(color: cs.onSurface),
        ),
        childrenPadding: const EdgeInsets.only(
          left: AppSpacing.md,
          right: AppSpacing.md,
          bottom: AppSpacing.md,
        ),
        children: [
          _SpendRow(
            icon: Icons.park_rounded,
            label: l10n.walletSpendGarden,
          ),
          _SpendRow(
            icon: Icons.refresh_rounded,
            label: l10n.walletSpendRestore,
          ),
          const SizedBox(height: AppSpacing.md),
          AmalGoldButton(
            label: l10n.walletOpenGarden,
            onPressed: () => context.push(AppRoutes.jannahGarden),
          ),
        ],
      ),
    );
  }
}

// ── Balance Header (stream-powered) ──────────────────────────────────────────

class _BalanceHeader extends ConsumerWidget {
  const _BalanceHeader({required this.isDark, required this.cs});

  final bool isDark;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletService = ref.watch(walletServiceProvider);
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<int>(
      stream: walletService.watchNoorCoinBalance(),
      builder: (context, balanceSnap) {
        final balance = balanceSnap.data ?? 0;

        return _TotalEarnedWrapper(
          balance: balance,
          isDark: isDark,
          cs: cs,
          l10n: l10n,
        );
      },
    );
  }
}

class _TotalEarnedWrapper extends ConsumerWidget {
  const _TotalEarnedWrapper({
    required this.balance,
    required this.isDark,
    required this.cs,
    required this.l10n,
  });

  final int balance;
  final bool isDark;
  final ColorScheme cs;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, userSnap) {
        final totalEarned = (userSnap.data?.data() as Map<String, dynamic>?)?['totalNoorCoinsEarned'] as num?;
        final totalEarnedInt = totalEarned?.toInt() ?? 0;

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xl,
            horizontal: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.surfaceVariantDark,
                      AppColors.surfaceDark,
                    ]
                  : [
                      AppColors.noorGoldLight.withValues(alpha: 0.3),
                      AppColors.creamWhite,
                    ],
            ),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: AppColors.noorGold.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.star_rounded,
                size: 48,
                color: AppColors.noorGold,
              ),
              const SizedBox(height: AppSpacing.sm),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: balance),
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                builder: (context, value, _) {
                  return Text(
                    _formatNumber(value),
                    style: AppTypography.displayMedium.copyWith(
                      color: AppColors.noorGold,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.walletBalance,
                style: AppTypography.titleMedium.copyWith(
                  color: cs.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  l10n.walletTotalEarned(totalEarnedInt),
                  style: AppTypography.bodySmall.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int n) {
    if (n < 1000) return n.toString();
    final reversed = n.toString().split('').reversed.toList();
    final parts = <String>[];
    for (var i = 0; i < reversed.length; i++) {
      if (i > 0 && i % 3 == 0) parts.add(',');
      parts.add(reversed[i]);
    }
    return parts.reversed.join();
  }
}

// ── Empty transactions placeholder ───────────────────────────────────────────

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({required this.message, required this.cs});

  final String message;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_rounded,
              size: AppSpacing.iconXl,
              color: cs.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: cs.onSurface.withValues(alpha: 0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Transaction tile ─────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.icon,
    required this.label,
    required this.amount,
    required this.isEarn,
    required this.timeAgo,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final int amount;
  final bool isEarn;
  final String timeAgo;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariantLight,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: (isEarn ? AppColors.success : AppColors.error)
                    .withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isEarn ? AppColors.success : AppColors.error,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeAgo,
                    style: AppTypography.bodySmall.copyWith(
                      color: cs.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              isEarn ? '+$amount' : '\u2212$amount',
              style: AppTypography.noorCoinLabel.copyWith(
                color: isEarn ? AppColors.success : AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Earn row ─────────────────────────────────────────────────────────────────

class _EarnRow extends StatelessWidget {
  const _EarnRow({
    required this.icon,
    required this.label,
    required this.amount,
  });

  final IconData icon;
  final String label;
  final String amount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.noorGold),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: cs.onSurface),
            ),
          ),
          Text(
            amount,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.noorGold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Spend row ────────────────────────────────────────────────────────────────

class _SpendRow extends StatelessWidget {
  const _SpendRow({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGold),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}
