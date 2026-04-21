import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/amal_button.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isEditingName = false;
  late TextEditingController _nameController;
  bool _isSavingName = false;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _nameController = TextEditingController(text: user?.displayName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // ── Save display name ─────────────────────────────────────────────────────
  Future<void> _saveDisplayName() async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty) return;

    setState(() => _isSavingName = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await user.updateDisplayName(newName);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'displayName': newName});

      if (mounted) {
        setState(() => _isEditingName = false);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorGeneric),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSavingName = false);
    }
  }

  // ── Log out ───────────────────────────────────────────────────────────────
  Future<void> _showLogOutDialog() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileLogOut),
        content: Text(l10n.profileLogOutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await ref.read(signInProvider.notifier).signOut();
      if (mounted) context.go(AppRoutes.welcome);
    }
  }

  // ── Delete account ────────────────────────────────────────────────────────
  Future<void> _showDeleteAccountDialog() async {
    final l10n = AppLocalizations.of(context);

    // Step 1: "Are you sure?"
    final step1 = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.profileDeleteAccount),
        content: Text(l10n.profileDeleteWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.profileCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: Text(l10n.continueButton),
          ),
        ],
      ),
    );
    if (step1 != true || !mounted) return;

    // Step 2: "Type DELETE to confirm"
    final deleteController = TextEditingController();
    final step2 = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx2, setDialogState) {
            return AlertDialog(
              title: Text(l10n.profileDeleteAccount),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.profileDeleteConfirmType),
                  const SizedBox(height: AppSpacing.md),
                  TextField(
                    controller: deleteController,
                    decoration: const InputDecoration(
                      hintText: 'DELETE',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (_) => setDialogState(() {}),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: Text(l10n.profileCancel),
                ),
                TextButton(
                  onPressed: deleteController.text.trim() == 'DELETE'
                      ? () => Navigator.pop(ctx, true)
                      : null,
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                  child: Text(l10n.profileDeleteAccount),
                ),
              ],
            );
          },
        );
      },
    );
    deleteController.dispose();

    if (step2 != true || !mounted) return;

    // Perform soft delete
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'isDeleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
        });
        await ref.read(signInProvider.notifier).signOut();
        if (mounted) context.go(AppRoutes.welcome);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorGeneric),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.profile),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── 1. Personal Section ───────────────────────────────────────
            _PersonalSection(
              user: user,
              isEditingName: _isEditingName,
              isSavingName: _isSavingName,
              nameController: _nameController,
              onEditName: () => setState(() => _isEditingName = true),
              onSaveName: _saveDisplayName,
              onCancelEditName: () {
                _nameController.text = user?.displayName ?? '';
                setState(() => _isEditingName = false);
              },
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── 2. Community Impact Section ───────────────────────────────
            _CommunityImpactSection(cs: cs),

            const SizedBox(height: AppSpacing.xl),

            // ── 3. Subscription Management ────────────────────────────────
            _SubscriptionSection(cs: cs),

            const SizedBox(height: AppSpacing.xl),

            // ── 4. Account Section ────────────────────────────────────────
            _buildAccountSection(l10n, cs),

            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(AppLocalizations l10n, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          leading: Icon(Icons.notifications_outlined, color: cs.primary),
          title: Text(l10n.notificationSettings),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(AppRoutes.settings),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.language, color: cs.primary),
          title: Text(l10n.selectLanguageTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(AppRoutes.settings),
        ),
        const Divider(height: 1),
        ListTile(
          leading: Icon(Icons.access_time, color: cs.primary),
          title: Text(l10n.prayerTimesTitle),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push(AppRoutes.settings),
        ),
        const SizedBox(height: AppSpacing.lg),
        AmalOutlinedButton(
          label: l10n.profileLogOut,
          onPressed: _showLogOutDialog,
          icon: const Icon(Icons.logout),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton.icon(
            onPressed: _showDeleteAccountDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
            icon: const Icon(Icons.delete_forever),
            label: Text(l10n.profileDeleteAccount,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.error,
                )),
          ),
        ),
      ],
    );
  }
}

// ── Personal Section ──────────────────────────────────────────────────────────
class _PersonalSection extends StatelessWidget {
  const _PersonalSection({
    required this.user,
    required this.isEditingName,
    required this.isSavingName,
    required this.nameController,
    required this.onEditName,
    required this.onSaveName,
    required this.onCancelEditName,
  });

  final User? user;
  final bool isEditingName;
  final bool isSavingName;
  final TextEditingController nameController;
  final VoidCallback onEditName;
  final VoidCallback onSaveName;
  final VoidCallback onCancelEditName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final uid = user?.uid;

    return Column(
      children: [
        // ── Profile photo ─────────────────────────────────────────────
        GestureDetector(
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.comingSoon)),
            );
          },
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 48,
                backgroundColor: cs.surfaceContainerHighest,
                backgroundImage: user?.photoURL != null
                    ? NetworkImage(user!.photoURL!)
                    : null,
                child: user?.photoURL == null
                    ? Icon(Icons.person, size: 48, color: cs.onSurfaceVariant)
                    : null,
              ),
              Container(
                decoration: BoxDecoration(
                  color: cs.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(Icons.camera_alt,
                    size: AppSpacing.iconSm, color: cs.onPrimary),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // ── Display name ──────────────────────────────────────────────
        if (isEditingName)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: nameController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: l10n.nameLabel,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              if (isSavingName)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else ...[
                IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: onSaveName,
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onCancelEditName,
                ),
              ],
            ],
          )
        else
          GestureDetector(
            onTap: onEditName,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  user?.displayName ?? l10n.nameLabel,
                  style: AppTypography.headlineSmall.copyWith(
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.edit, size: AppSpacing.iconSm,
                    color: cs.onSurfaceVariant),
              ],
            ),
          ),

        const SizedBox(height: AppSpacing.sm),

        // ── Member since ──────────────────────────────────────────────
        if (uid != null)
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              final data = snapshot.data?.data() as Map<String, dynamic>?;
              final createdAt = data?['createdAt'] as Timestamp?;
              final isPremium = data?['isPremium'] == true;
              final premiumExpiry = data?['premiumExpiresAt'] as Timestamp?;
              final referralCode = data?['referralCode'] as String?;
              final totalEarned = data?['totalNoorCoinsEarned'] as num? ?? 0;

              return Column(
                children: [
                  if (createdAt != null)
                    Text(
                      '${l10n.profileMemberSince} ${DateFormat.yMMMd().format(createdAt.toDate())}',
                      style: AppTypography.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),

                  const SizedBox(height: AppSpacing.sm),

                  // ── Subscription badge ──────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: isPremium
                          ? AppColors.primaryGold.withValues(alpha: 0.15)
                          : cs.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isPremium)
                          const Icon(Icons.workspace_premium,
                              size: 16, color: AppColors.primaryGold),
                        if (isPremium) const SizedBox(width: AppSpacing.xs),
                        Text(
                          isPremium
                              ? l10n.profilePremium
                              : l10n.profileFree,
                          style: AppTypography.labelMedium.copyWith(
                            color: isPremium
                                ? AppColors.primaryGold
                                : cs.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (isPremium && premiumExpiry != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Expires: ${DateFormat.yMMMd().format(premiumExpiry.toDate())}',
                      style: AppTypography.bodySmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),

                  // ── Referral code ───────────────────────────────────
                  if (referralCode != null && referralCode.isNotEmpty) ...[
                    Text(
                      l10n.profileReferralCode,
                      style: AppTypography.labelSmall.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(
                            referralCode,
                            style: AppTypography.titleMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          icon: const Icon(Icons.copy, size: 20),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: referralCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(l10n.copiedToClipboard)),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, size: 20),
                          onPressed: () {
                            Share.share(
                              'Join Amal and use my referral code: $referralCode\nhttps://amal.app/refer/$referralCode',
                            );
                          },
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: AppSpacing.md),

                  // ── Total Noor Coins earned ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.noorGold, AppColors.primaryGold],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars_rounded,
                            color: AppColors.white, size: 28),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '${l10n.profileTotalEarned}: ${NumberFormat.decimalPattern().format(totalEarned)}',
                          style: AppTypography.titleMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
      ],
    );
  }
}

// ── Community Impact Section ──────────────────────────────────────────────────
class _CommunityImpactSection extends StatelessWidget {
  const _CommunityImpactSection({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('amalStats')
          .doc('communityImpact')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
        final totalSadaqa = data['totalSadaqa'] as num? ?? 0;
        final bmmPatients = data['bmmPatients'] as num? ?? 0;
        final mleStudents = data['mleStudents'] as num? ?? 0;
        final raniAssisted = data['raniAssisted'] as num? ?? 0;
        final mayaSupported = data['mayaSupported'] as num? ?? 0;
        final cmeMentored = data['cmeMentored'] as num? ?? 0;
        final lastUpdated = data['lastUpdated'] as Timestamp?;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.profileCommunityImpact,
              style: AppTypography.titleLarge.copyWith(color: cs.onSurface),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── Headline ────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2)),
              ),
              child: Text(
                'Together, the Amal community has generated \$${NumberFormat.decimalPattern().format(totalSadaqa)} in sadaqa',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // ── Impact cards ────────────────────────────────────────
            _ImpactCard(
              icon: Icons.local_hospital_rounded,
              color: AppColors.error,
              text:
                  '${NumberFormat.decimalPattern().format(bmmPatients)} patients received medical care',
              label: 'BMM',
            ),
            _ImpactCard(
              icon: Icons.school_rounded,
              color: AppColors.info,
              text:
                  '${NumberFormat.decimalPattern().format(mleStudents)} students supported',
              label: 'MLE',
            ),
            _ImpactCard(
              icon: Icons.volunteer_activism_rounded,
              color: AppColors.primaryGreen,
              text:
                  '${NumberFormat.decimalPattern().format(raniAssisted)} people assisted',
              label: 'RANI',
            ),
            _ImpactCard(
              icon: Icons.family_restroom_rounded,
              color: AppColors.primaryGold,
              text:
                  '${NumberFormat.decimalPattern().format(mayaSupported)} young adults and mothers supported',
              label: 'MAYA',
            ),
            _ImpactCard(
              icon: Icons.business_center_rounded,
              color: cs.tertiary,
              text:
                  '${NumberFormat.decimalPattern().format(cmeMentored)} people mentored',
              label: 'CME',
            ),

            const SizedBox(height: AppSpacing.sm),

            // ── Footer (FTC compliance) ─────────────────────────────
            if (lastUpdated != null)
              Text(
                '${l10n.profileDataUpdated} ${DateFormat.yMMMd().format(lastUpdated.toDate())}',
                style: AppTypography.bodySmall.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ImpactCard extends StatelessWidget {
  const _ImpactCard({
    required this.icon,
    required this.color,
    required this.text,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, color: color, size: AppSpacing.iconMd),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.labelSmall.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    text,
                    style: AppTypography.bodyMedium.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Subscription Section ──────────────────────────────────────────────────────
class _SubscriptionSection extends StatelessWidget {
  const _SubscriptionSection({required this.cs});

  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const SizedBox.shrink();

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final isPremium = data?['isPremium'] == true;

        if (isPremium) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AmalOutlinedButton(
                label: l10n.profileManageSubscription,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.comingSoon)),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.sm),
              AmalTextButton(
                label: l10n.profileRestorePurchases,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.comingSoon)),
                  );
                },
                subtle: true,
              ),
            ],
          );
        }

        // ── Free user: show subscription card ───────────────────────
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.3)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGold.withValues(alpha: 0.05),
                AppColors.primaryGold.withValues(alpha: 0.12),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.workspace_premium,
                      color: AppColors.primaryGold, size: 28),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    l10n.profilePremium,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primaryGold,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Benefits
              _BenefitRow(text: 'Unlimited Jannah Garden access'),
              _BenefitRow(text: 'Ad-free Soul Stack experience'),
              _BenefitRow(text: 'Exclusive garden assets'),
              _BenefitRow(text: 'Cloud backup for your garden'),

              const SizedBox(height: AppSpacing.md),

              // Monthly
              _PriceTile(
                title: l10n.profileMonthly,
                price: '\$9.99',
                subtitle: null,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.comingSoon)),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              // Annual
              _PriceTile(
                title: l10n.profileAnnual,
                price: '\$99',
                subtitle: l10n.profileSaveDiscount,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.comingSoon)),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.md),

              AmalGoldButton(
                label: l10n.profileSubscribe,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.comingSoon)),
                  );
                },
              ),

              const SizedBox(height: AppSpacing.sm),

              Center(
                child: AmalTextButton(
                  label: l10n.profileRestorePurchases,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.comingSoon)),
                    );
                  },
                  subtle: true,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.check_circle,
              color: AppColors.primaryGreen, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceTile extends StatelessWidget {
  const _PriceTile({
    required this.title,
    required this.price,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String price;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleSmall),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
            Text(
              price,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
