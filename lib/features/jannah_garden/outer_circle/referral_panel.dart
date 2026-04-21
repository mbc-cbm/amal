import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/garden_provider.dart';

const _bgDark = Color(0xFF0D3B1A);
const _cardBg = Color(0xFF143D1E);
const _textWarm = Color(0xFFFFF8DC);
const _textDim = Color(0xFFB8C5A8);
const _goldGradient = [Color(0xFFC9942A), Color(0xFFE8C547)];

// ═══════════════════════════════════════════════════════════════════════════
// FLOATING NETWORK BUTTON
// ═══════════════════════════════════════════════════════════════════════════

/// Floating gold pill button that opens the referral panel.
class NetworkFloatingButton extends StatelessWidget {
  const NetworkFloatingButton({super.key, required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: _goldGradient),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          boxShadow: [
            BoxShadow(
              color: AppColors.noorGold.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.account_tree_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.sm),
            Text(l10n.myNetwork,
                style: AppTypography.labelLarge
                    .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// SHOW REFERRAL PANEL
// ═══════════════════════════════════════════════════════════════════════════

void showReferralPanel(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (ctx, scrollController) => _ReferralPanel(
        scrollController: scrollController,
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// REFERRAL PANEL CONTENT
// ═══════════════════════════════════════════════════════════════════════════

class _ReferralPanel extends ConsumerStatefulWidget {
  const _ReferralPanel({required this.scrollController});
  final ScrollController scrollController;

  @override
  ConsumerState<_ReferralPanel> createState() => _ReferralPanelState();
}

class _ReferralPanelState extends ConsumerState<_ReferralPanel> {
  bool _showHowItWorks = false;
  bool _showCopied = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final referralAsync = ref.watch(referralCodeProvider);
    final statsAsync = ref.watch(outerGardenStatsProvider);

    final referralCode = referralAsync.valueOrNull ?? '';
    final stats = statsAsync.valueOrNull ?? {};
    final referralLink = 'amal-app.com/join/$referralCode';
    final locale = Localizations.localeOf(context).languageCode;
    final isRtl = locale == 'ar' || locale == 'ur';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        decoration: const BoxDecoration(
          color: _bgDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── SECTION 1: Referral Link ─────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(
                color: AppColors.noorGold.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                // Link display
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: _bgDark,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Text(
                    referralLink,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.noorGold,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Action buttons
                Row(
                  children: [
                    // Copy Link
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.content_copy_rounded,
                        label: _showCopied ? l10n.linkCopied : l10n.copyLink,
                        isHighlighted: _showCopied,
                        onTap: () async {
                          await Clipboard.setData(
                              ClipboardData(text: referralLink));
                          setState(() => _showCopied = true);
                          Future.delayed(const Duration(milliseconds: 1500),
                              () {
                            if (mounted) setState(() => _showCopied = false);
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    // Share
                    Expanded(
                      child: _ActionButton(
                        icon: Icons.share_rounded,
                        label: l10n.shareInvite,
                        onTap: () {
                          Share.share(
                            '${l10n.shareInviteMessage} $referralLink',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── SECTION 2: Your Network Stats ────────────────────────────
          _StatTile(
            emoji: '\uD83C\uDF31', // 🌱
            label: l10n.directInvites,
            value: (stats['directInviteCount'] as num?)?.toInt() ?? 0,
            desc: l10n.directInvitesDesc,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatTile(
            emoji: '\uD83C\uDF3F', // 🌿
            label: l10n.theirInvites,
            value: (stats['depthTwoCount'] as num?)?.toInt() ?? 0,
            desc: l10n.theirInvitesDesc,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatTile(
            emoji: '\uD83C\uDF33', // 🌳
            label: l10n.totalNetwork,
            value: (stats['totalNetworkCount'] as num?)?.toInt() ?? 0,
            desc: l10n.totalNetworkDesc,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatTile(
            emoji: '\u2726', // ✦
            label: l10n.totalNetworkAmals,
            value: (stats['totalNetworkAmalsCount'] as num?)?.toInt() ?? 0,
            desc: l10n.totalNetworkAmalsDesc,
          ),
          const SizedBox(height: AppSpacing.sm),
          _StatTile(
            emoji: '\uD83C\uDF27', // 🌧
            label: l10n.rainfallToday,
            value: (stats['rainfallEventsToday'] as num?)?.toInt() ?? 0,
            desc: l10n.rainfallTodayDesc,
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── SECTION 3: How It Works (collapsible) ────────────────────
          GestureDetector(
            onTap: () => setState(() => _showHowItWorks = !_showHowItWorks),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: _cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline_rounded,
                          color: _textDim, size: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Text(l10n.howItWorks,
                          style: AppTypography.labelMedium
                              .copyWith(color: _textDim)),
                      const Spacer(),
                      Icon(
                        _showHowItWorks
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: _textDim,
                        size: 20,
                      ),
                    ],
                  ),
                  if (_showHowItWorks) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.howItWorksBody,
                      style: AppTypography.bodySmall.copyWith(
                        color: _textWarm.withValues(alpha: 0.7),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// ACTION BUTTON (Copy / Share)
// ═══════════════════════════════════════════════════════════════════════════

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlighted = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isHighlighted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          gradient: isHighlighted
              ? const LinearGradient(colors: _goldGradient)
              : null,
          color: isHighlighted ? null : _bgDark,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: isHighlighted
              ? null
              : Border.all(color: Colors.white.withValues(alpha: 0.15)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isHighlighted ? Colors.white : _textDim),
            const SizedBox(width: AppSpacing.xs),
            Text(label,
                style: AppTypography.labelMedium.copyWith(
                  color: isHighlighted ? Colors.white : _textDim,
                  fontWeight: FontWeight.w600,
                )),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// STAT TILE — animated counter
// ═══════════════════════════════════════════════════════════════════════════

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.emoji,
    required this.label,
    required this.value,
    required this.desc,
  });

  final String emoji;
  final String label;
  final int value;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTypography.labelMedium
                        .copyWith(color: _textWarm)),
                const SizedBox(height: 2),
                Text(desc,
                    style: AppTypography.bodySmall.copyWith(
                      color: _textDim,
                      fontSize: 11,
                    )),
              ],
            ),
          ),
          // Animated count-up
          TweenAnimationBuilder<int>(
            tween: IntTween(begin: 0, end: value),
            duration: const Duration(milliseconds: 800),
            builder: (context, val, _) => Text(
              '$val',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.noorGold,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
