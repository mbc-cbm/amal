import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/garden_provider.dart';
import '../../../core/services/iap_service.dart';
import '../../../core/storage/garden_asset_hive.dart';
import '../../../core/storage/hive_boxes.dart';

// ═══════════════════════════════════════════════════════════════════════════
// SHOW HELPER
// ═══════════════════════════════════════════════════════════════════════════

/// Shows the Hayat purchase bottom sheet.
/// [preSelectedDrop] — if true, starts with Drop mode.
/// [preSelectedAssetSlotKey] — if set, pre-selects a specific withered asset.
void showHayatPurchaseSheet(
  BuildContext context, {
  bool preSelectedDrop = false,
  String? preSelectedAssetSlotKey,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HayatPurchaseSheet(
      preSelectedDrop: preSelectedDrop,
      preSelectedAssetSlotKey: preSelectedAssetSlotKey,
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
// HAYAT PURCHASE SHEET
// ═══════════════════════════════════════════════════════════════════════════

enum _HayatMode { choose, selectAsset }

class _HayatPurchaseSheet extends ConsumerStatefulWidget {
  const _HayatPurchaseSheet({
    this.preSelectedDrop = false,
    this.preSelectedAssetSlotKey,
  });

  final bool preSelectedDrop;
  final String? preSelectedAssetSlotKey;

  @override
  ConsumerState<_HayatPurchaseSheet> createState() =>
      _HayatPurchaseSheetState();
}

class _HayatPurchaseSheetState extends ConsumerState<_HayatPurchaseSheet> {
  _HayatMode _mode = _HayatMode.choose;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    if (widget.preSelectedDrop && widget.preSelectedAssetSlotKey != null) {
      // Go directly to drop flow for pre-selected asset
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _executeDrop(widget.preSelectedAssetSlotKey!);
      });
    }
  }

  // ── Drop flow ───────────────────────────────────────────────────────────

  Future<void> _executeDrop(String slotKey) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _processing = true);

    try {
      await FirebaseFunctions.instance
          .httpsCallable('hayatDrop')
          .call({'uid': uid, 'targetAssetId': slotKey, 'paymentType': 'nc'});

      // Update local Hive state
      final box = Hive.box<GardenAssetHive>(HiveBoxes.gardenGrid);
      final asset = box.get(slotKey);
      if (asset != null) {
        asset.currentHealthState = 1;
        await box.put(slotKey, asset);
      }

      if (mounted) {
        Navigator.of(context).pop(true); // true = success, trigger animation
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _executeDropIap(String slotKey) async {
    final iap = ref.read(iapServiceProvider);
    iap.onPurchaseSuccess = (productId) async {
      if (productId == IapProductIds.hayatDrop) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;
        try {
          await FirebaseFunctions.instance
              .httpsCallable('hayatDrop')
              .call({'uid': uid, 'targetAssetId': slotKey, 'paymentType': 'iap'});

          final box = Hive.box<GardenAssetHive>(HiveBoxes.gardenGrid);
          final asset = box.get(slotKey);
          if (asset != null) {
            asset.currentHealthState = 1;
            await box.put(slotKey, asset);
          }
        } catch (_) {}
        iap.onPurchaseSuccess = null;
      }
    };
    await iap.buyProduct(IapProductIds.hayatDrop);
  }

  // ── Bloom flow ──────────────────────────────────────────────────────────

  Future<void> _executeBloomNc() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _processing = true);

    try {
      await FirebaseFunctions.instance
          .httpsCallable('hayatBloom')
          .call({'uid': uid, 'paymentType': 'nc'});

      // Update all Hive assets
      final box = Hive.box<GardenAssetHive>(HiveBoxes.gardenGrid);
      for (final key in box.keys) {
        final asset = box.get(key);
        if (asset != null && asset.currentHealthState > 1) {
          asset.currentHealthState = 1;
          await box.put(key, asset);
        }
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorGeneric),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _executeBloomIap() async {
    final iap = ref.read(iapServiceProvider);
    iap.onPurchaseSuccess = (productId) async {
      if (productId == IapProductIds.hayatBloom) {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;
        try {
          await FirebaseFunctions.instance
              .httpsCallable('hayatBloom')
              .call({'uid': uid, 'paymentType': 'iap'});

          final box = Hive.box<GardenAssetHive>(HiveBoxes.gardenGrid);
          for (final key in box.keys) {
            final asset = box.get(key);
            if (asset != null && asset.currentHealthState > 1) {
              asset.currentHealthState = 1;
              await box.put(key, asset);
            }
          }
        } catch (_) {}
        iap.onPurchaseSuccess = null;
      }
    };
    await iap.buyProduct(IapProductIds.hayatBloom);
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final balance = ref.watch(noorBalanceProvider).valueOrNull ?? 0;
    final locale = Localizations.localeOf(context).languageCode;
    final isRtl = locale == 'ar' || locale == 'ur';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A4D2E), Color(0xFF0D3B1A)],
        ),
      ),
      child: _processing
          ? const SizedBox(
              height: 200,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.noorGold),
              ),
            )
          : _mode == _HayatMode.choose
              ? _buildChooseMode(l10n, balance)
              : _buildAssetSelectionMode(l10n),
    ),
    );
  }

  // ── Choose Mode (Drop vs Bloom) ─────────────────────────────────────────

  Widget _buildChooseMode(AppLocalizations l10n, int balance) {
    final iap = ref.read(iapServiceProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Golden radial glow behind header
            Stack(
              alignment: Alignment.center,
              children: [
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
                ),
                Column(
                  children: [
                    // حياة in large gold Arabic
                    const Text(
                      'حياة',
                      style: TextStyle(
                        fontSize: 48,
                        color: AppColors.noorGold,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        decoration: TextDecoration.none,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      l10n.hayatLife,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.gardenCelestial,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Tagline
            Text(
              l10n.hayatTagline,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.gardenCelestial.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Two cards side by side
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hayat Drop card
                Expanded(
                  child: _HayatOptionCard(
                    icon: Icons.water_drop_rounded,
                    title: l10n.hayatDropTitle,
                    effect: l10n.hayatDropEffect,
                    ncPrice: 2500,
                    usdPrice: iap.priceForProduct(
                        IapProductIds.hayatDrop, fallback: '\$0.50'),
                    buttonLabel: l10n.hayatRestoreOne,
                    orLabel: l10n.hayatOr,
                    onNcTap: () {
                      setState(() => _mode = _HayatMode.selectAsset);
                    },
                    onIapTap: () {
                      setState(() => _mode = _HayatMode.selectAsset);
                    },
                    isProminent: false,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Hayat Bloom card (more prominent)
                Expanded(
                  child: _HayatOptionCard(
                    icon: Icons.local_florist_rounded,
                    title: l10n.hayatBloomTitle,
                    effect: l10n.hayatBloomEffect,
                    ncPrice: 8000,
                    usdPrice: iap.priceForProduct(
                        IapProductIds.hayatBloom, fallback: '\$1.50'),
                    buttonLabel: l10n.hayatRestoreAll,
                    orLabel: l10n.hayatOr,
                    onNcTap: _executeBloomNc,
                    onIapTap: _executeBloomIap,
                    isProminent: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Balance display
            Text(
              l10n.hayatYourBalance(balance),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.noorGold.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Asset Selection Mode (for Drop) ─────────────────────────────────────

  Widget _buildAssetSelectionMode(AppLocalizations l10n) {
    final svc = ref.read(gardenServiceProvider);
    final allAssets = svc.loadAllAssetsFromHive();
    final withered = allAssets.entries
        .where((e) => e.value.currentHealthState > 1)
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Back button + title
            Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _mode = _HayatMode.choose),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.gardenCelestial, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Text(
                  l10n.hayatSelectAsset,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.gardenCelestial,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            if (withered.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_rounded,
                        size: 48, color: AppColors.success.withValues(alpha: 0.7)),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'All assets are healthy!',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.gardenCelestial,
                      ),
                    ),
                  ],
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: withered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final entry = withered[index];
                    final asset = entry.value;
                    return _WitheredAssetTile(
                      slotKey: entry.key,
                      asset: asset,
                      onNcTap: () => _executeDrop(entry.key),
                      onIapTap: () => _executeDropIap(entry.key),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// HAYAT OPTION CARD (Drop or Bloom)
// ═══════════════════════════════════════════════════════════════════════════

class _HayatOptionCard extends StatelessWidget {
  const _HayatOptionCard({
    required this.icon,
    required this.title,
    required this.effect,
    required this.ncPrice,
    required this.usdPrice,
    required this.buttonLabel,
    required this.orLabel,
    required this.onNcTap,
    required this.onIapTap,
    required this.isProminent,
  });

  final IconData icon;
  final String title;
  final String effect;
  final int ncPrice;
  final String usdPrice;
  final String buttonLabel;
  final String orLabel;
  final VoidCallback onNcTap;
  final VoidCallback onIapTap;
  final bool isProminent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF143D1E),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: isProminent
              ? AppColors.noorGold.withValues(alpha: 0.4)
              : const Color(0xFF1E5C2E),
          width: isProminent ? 1.5 : 1,
        ),
        boxShadow: isProminent
            ? [
                BoxShadow(
                  color: AppColors.noorGold.withValues(alpha: 0.1),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          // Icon
          Icon(icon,
              size: 32,
              color: isProminent ? AppColors.noorGold : AppColors.gardenAquamarine),
          const SizedBox(height: AppSpacing.sm),

          // Title
          Text(title,
              style: AppTypography.titleSmall.copyWith(
                color: AppColors.gardenCelestial,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.xs),

          // Effect
          Text(effect,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.gardenCelestial.withValues(alpha: 0.6),
                fontSize: 11,
              ),
              textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),

          // NC price button
          GestureDetector(
            onTap: onNcTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: isProminent
                    ? const LinearGradient(
                        colors: [Color(0xFFC9942A), Color(0xFFE8C547)])
                    : null,
                color: isProminent ? null : AppColors.gardenEmerald,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars_rounded,
                      size: 14, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('$ncPrice',
                      style: AppTypography.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // "or"
          Text(orLabel,
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.gardenCelestial.withValues(alpha: 0.4),
              )),
          const SizedBox(height: AppSpacing.xs),

          // USD price button
          GestureDetector(
            onTap: onIapTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
              ),
              child: Text(usdPrice,
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.gardenCelestial,
                  ),
                  textAlign: TextAlign.center),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WITHERED ASSET TILE (for Drop asset selection)
// ═══════════════════════════════════════════════════════════════════════════

class _WitheredAssetTile extends StatelessWidget {
  const _WitheredAssetTile({
    required this.slotKey,
    required this.asset,
    required this.onNcTap,
    required this.onIapTap,
  });

  final String slotKey;
  final GardenAssetHive asset;
  final VoidCallback onNcTap;
  final VoidCallback onIapTap;

  @override
  Widget build(BuildContext context) {
    final healthLabel = switch (asset.currentHealthState) {
      2 => 'Slightly faded',
      3 => 'Fading',
      4 => 'Wilting',
      _ => 'Withered',
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF143D1E),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: const Color(0xFF1E5C2E)),
      ),
      child: Row(
        children: [
          // Asset preview
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gardenEmerald.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(Icons.eco_rounded,
                size: 24,
                color: AppColors.gardenLeafLight.withValues(alpha: 0.5)),
          ),
          const SizedBox(width: AppSpacing.md),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  asset.assetTemplateId.replaceAll('_', ' '),
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.gardenCelestial,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$healthLabel · Slot $slotKey',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.gardenCelestial.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),

          // NC button
          GestureDetector(
            onTap: onNcTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFFC9942A), Color(0xFFE8C547)]),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.stars_rounded,
                      size: 12, color: Colors.white),
                  const SizedBox(width: 2),
                  Text('2,500',
                      style: AppTypography.labelSmall.copyWith(
                          color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),

          // IAP button
          GestureDetector(
            onTap: onIapTap,
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Text('\$0.50',
                  style: AppTypography.labelSmall.copyWith(
                      color: AppColors.gardenCelestial)),
            ),
          ),
        ],
      ),
    );
  }
}
