import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/models/asset_model.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/garden_provider.dart';
import '../../../core/services/iap_service.dart';
import '../painters/asset_painters.dart';

// ── Constants ─────────────────────────────────────────────────────────────

const _bgDark = Color(0xFF0D3B1A);
const _textWarm = Color(0xFFFFF8DC);
const _textDim = Color(0xFFB8C5A8);
const _goldGradient = [Color(0xFFC9942A), Color(0xFFE8C547)];
const _cardBg = Color(0xFF143D1E);
const _cardBorder = Color(0xFF1E5C2E);

// ── Filter categories ────────────────────────────────────────────────────

enum _ShopFilter {
  all, trees, water, fruits, creatures, structures, sacred, underwater, sky,
}

// ═══════════════════════════════════════════════════════════════════════════
// JANNAH SHOP SCREEN
// ═══════════════════════════════════════════════════════════════════════════

class JannahShopScreen extends ConsumerStatefulWidget {
  const JannahShopScreen({super.key, this.gridX, this.gridY});

  final int? gridX;
  final int? gridY;

  @override
  ConsumerState<JannahShopScreen> createState() => _JannahShopScreenState();
}

class _JannahShopScreenState extends ConsumerState<JannahShopScreen> {
  _ShopFilter _filter = _ShopFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final isRtl = locale == 'ar' || locale == 'ur';

    final balance = ref.watch(noorBalanceProvider).valueOrNull ?? 0;
    final ownedAsync = ref.watch(ownedAssetIdsProvider);
    final owned = ownedAsync.valueOrNull ?? {};
    final userLevel = ref.watch(gardenLevelProvider);

    // Fetch all store assets
    final assetsAsync = ref.watch(storeAssetsProvider(null));
    final allAssets = assetsAsync.valueOrNull ?? [];

    // Filter
    final filtered = _applyFilter(allAssets, userLevel);

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: _bgDark,
        body: CustomScrollView(
          slivers: [
            // ── App Bar ──────────────────────────────────────────────
            SliverAppBar(
              pinned: true,
              backgroundColor: _bgDark.withValues(alpha: 0.92),
              foregroundColor: _textWarm,
              title: Text(l10n.shopGalleryTitle,
                  style: AppTypography.titleLarge
                      .copyWith(color: _textWarm, fontWeight: FontWeight.w700)),
              actions: [
                // Noor Coin balance
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stars_rounded,
                          color: AppColors.noorGold, size: 20),
                      const SizedBox(width: 4),
                      Text('$balance',
                          style: AppTypography.titleSmall.copyWith(
                            color: AppColors.noorGold,
                            fontWeight: FontWeight.w700,
                          )),
                    ],
                  ),
                ),
              ],
            ),

            // ── Featured Asset ───────────────────────────────────────
            SliverToBoxAdapter(
              child: _FeaturedCard(
                assets: allAssets,
                locale: locale,
                balance: balance,
                owned: owned,
                l10n: l10n,
              ),
            ),

            // ── Filter Tabs ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: _FilterTabs(
                selected: _filter,
                userLevel: userLevel,
                l10n: l10n,
                onChanged: (f) => setState(() => _filter = f),
              ),
            ),

            // ── Asset Grid ───────────────────────────────────────────
            if (assetsAsync.isLoading)
              const SliverFillRemaining(
                child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.noorGold)),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 0.58,
                  children: filtered.map((asset) {
                    final isOwned = owned.contains(asset.id);
                    final canAfford = balance >= asset.ncPrice;
                    return _AssetCard(
                      asset: asset,
                      locale: locale,
                      isOwned: isOwned,
                      canAfford: canAfford,
                      l10n: l10n,
                      onTap: () => _onAssetTap(asset, isOwned, canAfford),
                    );
                  }).toList(),
                ),
              ),

            // ── Hayat Section ────────────────────────────────────────
            SliverToBoxAdapter(child: _HayatSection(l10n: l10n)),

            // ── NC IAP Section ───────────────────────────────────────
            SliverToBoxAdapter(child: _NcIapSection(l10n: l10n)),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: AppSpacing.xxxl),
            ),
          ],
        ),
      ),
    );
  }

  List<AssetModel> _applyFilter(List<AssetModel> assets, int userLevel) {
    // Hide water_ocean if user < level 4
    var list = assets.where((a) {
      if (a.tier == 'water_ocean' && userLevel < 4) return false;
      return true;
    }).toList();

    if (_filter == _ShopFilter.all) return list;

    final categoryMatch = switch (_filter) {
      _ShopFilter.trees => 'trees',
      _ShopFilter.water => 'water',
      _ShopFilter.fruits => 'fruits',
      _ShopFilter.creatures => 'creatures',
      _ShopFilter.structures => 'structures',
      _ShopFilter.sacred => 'sacred',
      _ShopFilter.underwater => 'water_ocean',
      _ShopFilter.sky => 'sky',
      _ShopFilter.all => '',
    };

    // Sacred filter matches tier, others match category
    if (_filter == _ShopFilter.sacred) {
      return list.where((a) => a.tier == 'sacred').toList();
    }
    if (_filter == _ShopFilter.underwater) {
      return list.where((a) => a.tier == 'water_ocean').toList();
    }

    return list.where((a) => a.category == categoryMatch).toList();
  }

  void _onAssetTap(AssetModel asset, bool isOwned, bool canAfford) {
    if (isOwned) return;

    final l10n = AppLocalizations.of(context);
    final balance = ref.read(noorBalanceProvider).valueOrNull ?? 0;

    // Check balance
    if (balance < asset.ncPrice) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.earnMorePrompt),
          backgroundColor: AppColors.warning,
          action: SnackBarAction(
            label: l10n.shopNcTitle,
            textColor: Colors.white,
            onPressed: () {}, // scroll to NC section
          ),
        ),
      );
      return;
    }

    // Show confirmation dialog
    _showPlantConfirmation(asset);
  }

  void _showPlantConfirmation(AssetModel asset) {
    final l10n = AppLocalizations.of(context);

    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF143D1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Asset preview
            SizedBox(
              width: 100,
              height: 100,
              child: CustomPaint(
                painter: JannahAssetPainterRegistry.getPainter(
                  asset.id,
                  healthState: 1,
                  animationValue: 0.5,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // All 4 language names
            Text(asset.nameEn,
                style: AppTypography.titleMedium.copyWith(
                    color: const Color(0xFFFFF8DC),
                    fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            if (asset.nameAr.isNotEmpty)
              Text(asset.nameAr,
                  style: AppTypography.bodySmall
                      .copyWith(color: const Color(0xFFB8C5A8)),
                  textDirection: TextDirection.rtl),
            if (asset.nameBn.isNotEmpty)
              Text(asset.nameBn,
                  style: AppTypography.bodySmall
                      .copyWith(color: const Color(0xFFB8C5A8), fontSize: 11)),
            if (asset.nameUr.isNotEmpty)
              Text(asset.nameUr,
                  style: AppTypography.bodySmall
                      .copyWith(color: const Color(0xFFB8C5A8), fontSize: 11),
                  textDirection: TextDirection.rtl),
            const SizedBox(height: AppSpacing.md),

            // Confirmation text
            Text(
              l10n.plantConfirmTitle(asset.nameEn, asset.ncPrice),
              style: AppTypography.bodyMedium.copyWith(
                color: const Color(0xFFFFF8DC),
              ),
              textAlign: TextAlign.center,
            ),

            // Quranic reference if applicable
            if (asset.referenceEn.isNotEmpty &&
                asset.referenceEn != 'Original')
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Text(
                  asset.referenceEn,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.noorGold.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.lg),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.noorGold,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
                child: Text(l10n.plantIt),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(false),
              child: Text(l10n.notNow,
                  style: AppTypography.bodySmall
                      .copyWith(color: const Color(0xFFB8C5A8))),
            ),
          ],
        ),
      ),
    ).then((confirmed) async {
      if (confirmed != true) return;
      await _executePurchase(asset);
    });
  }

  Future<void> _executePurchase(AssetModel asset) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFunctions.instance
          .httpsCallable('purchaseAssetWithNc')
          .call({'uid': uid, 'assetId': asset.id});

      // Set pending placement
      ref.read(pendingPlacementProvider.notifier).state = asset.id;
      ref.invalidate(ownedAssetIdsProvider);

      if (mounted) {
        // Navigate back to garden — user will tap a slot
        context.pop();
      }
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
}

// ═══════════════════════════════════════════════════════════════════════════
// FEATURED CARD
// ═══════════════════════════════════════════════════════════════════════════

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.assets,
    required this.locale,
    required this.balance,
    required this.owned,
    required this.l10n,
  });

  final List<AssetModel> assets;
  final String locale;
  final int balance;
  final Set<String> owned;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    // Default to most expensive Sacred tier asset
    final featured = assets.isEmpty
        ? null
        : (assets.where((a) => a.tier == 'sacred').toList()
              ..sort((a, b) => b.ncPrice.compareTo(a.ncPrice)))
            .firstOrNull;

    if (featured == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A4D2E), Color(0xFF0D3B1A)],
        ),
        border: Border.all(
          color: AppColors.noorGold.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Stack(
        children: [
          // Golden glow from top
          Positioned(
            top: -30,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    AppColors.noorGold.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                // Asset preview placeholder
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: featured.tier.tierColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(
                      color: featured.tier.tierColor.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.spa_rounded,
                      size: 48,
                      color: featured.tier.tierColor,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Featured badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: _goldGradient),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(l10n.shopFeatured,
                            style: AppTypography.labelSmall.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Name in EN
                      Text(featured.nameEn,
                          style: AppTypography.titleMedium.copyWith(
                              color: _textWarm, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 2),
                      // Arabic name RTL
                      Text(featured.nameAr,
                          style: AppTypography.bodySmall.copyWith(
                              color: _textDim, fontSize: 12),
                          textDirection: TextDirection.rtl),
                      const SizedBox(height: AppSpacing.sm),
                      // Price
                      Row(
                        children: [
                          const Icon(Icons.stars_rounded,
                              color: AppColors.noorGold, size: 16),
                          const SizedBox(width: 4),
                          Text('${featured.ncPrice}',
                              style: AppTypography.titleSmall.copyWith(
                                  color: AppColors.noorGold,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILTER TABS
// ═══════════════════════════════════════════════════════════════════════════

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
    required this.selected,
    required this.userLevel,
    required this.l10n,
    required this.onChanged,
  });

  final _ShopFilter selected;
  final int userLevel;
  final AppLocalizations l10n;
  final ValueChanged<_ShopFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final tabs = <_ShopFilter>[
      _ShopFilter.all,
      _ShopFilter.trees,
      _ShopFilter.water,
      _ShopFilter.fruits,
      _ShopFilter.creatures,
      _ShopFilter.structures,
      _ShopFilter.sacred,
      if (userLevel >= 4) _ShopFilter.underwater,
      _ShopFilter.sky,
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final tab = tabs[i];
          final isSelected = tab == selected;
          return GestureDetector(
            onTap: () => onChanged(tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: _goldGradient)
                    : null,
                color: isSelected ? null : _cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                border: isSelected
                    ? null
                    : Border.all(color: _cardBorder),
              ),
              child: Text(
                _tabLabel(tab, l10n),
                style: AppTypography.labelMedium.copyWith(
                  color: isSelected ? Colors.white : _textDim,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _tabLabel(_ShopFilter f, AppLocalizations l10n) => switch (f) {
        _ShopFilter.all => l10n.shopAll,
        _ShopFilter.trees => l10n.shopTrees,
        _ShopFilter.water => l10n.shopWater,
        _ShopFilter.fruits => l10n.shopFruits,
        _ShopFilter.creatures => l10n.shopCreatures,
        _ShopFilter.structures => l10n.shopStructures,
        _ShopFilter.sacred => l10n.shopSacred,
        _ShopFilter.underwater => l10n.shopUnderwater,
        _ShopFilter.sky => l10n.shopSky,
      };
}

// ═══════════════════════════════════════════════════════════════════════════
// ASSET CARD
// ═══════════════════════════════════════════════════════════════════════════

class _AssetCard extends StatelessWidget {
  const _AssetCard({
    required this.asset,
    required this.locale,
    required this.isOwned,
    required this.canAfford,
    required this.l10n,
    required this.onTap,
  });

  final AssetModel asset;
  final String locale;
  final bool isOwned;
  final bool canAfford;
  final AppLocalizations l10n;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tierColor = asset.tier.tierColor;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Asset artwork area (top 50%) ──────────────────────────
            Expanded(
              flex: 5,
              child: Container(
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.12),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppSpacing.radiusLg)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(Icons.spa_rounded,
                          size: 52, color: tierColor.withValues(alpha: 0.7)),
                    ),
                    // Tier badge
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: tierColor.withValues(alpha: 0.85),
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                        child: Text(
                          asset.tier.tierDisplayLabel,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    // Owned badge
                    if (isOwned)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(l10n.shopInGarden,
                              style: AppTypography.labelSmall.copyWith(
                                  color: Colors.white, fontSize: 9)),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // ── Info area (bottom 50%) ────────────────────────────────
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // EN name
                    Text(asset.nameEn,
                        style: AppTypography.titleSmall.copyWith(
                            color: _textWarm,
                            fontWeight: FontWeight.w700,
                            fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 1),
                    // Arabic name (RTL)
                    Text(asset.nameAr,
                        style: AppTypography.bodySmall
                            .copyWith(color: _textDim, fontSize: 11),
                        textDirection: TextDirection.rtl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    // Bengali name
                    if (asset.nameBn.isNotEmpty)
                      Text(asset.nameBn,
                          style: AppTypography.bodySmall
                              .copyWith(color: _textDim, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),

                    const Spacer(),

                    // Price row
                    Row(
                      children: [
                        const Icon(Icons.stars_rounded,
                            color: AppColors.noorGold, size: 14),
                        const SizedBox(width: 3),
                        Text('${asset.ncPrice}',
                            style: AppTypography.titleSmall.copyWith(
                                color: AppColors.noorGold,
                                fontWeight: FontWeight.w800,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Action button
                    SizedBox(
                      width: double.infinity,
                      height: 30,
                      child: isOwned
                          ? Container(
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm),
                              ),
                              alignment: Alignment.center,
                              child: Text(l10n.shopInGarden,
                                  style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.success,
                                      fontWeight: FontWeight.w600)),
                            )
                          : Container(
                              decoration: BoxDecoration(
                                gradient: canAfford
                                    ? const LinearGradient(
                                        colors: _goldGradient)
                                    : null,
                                color: canAfford
                                    ? null
                                    : AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusSm),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                canAfford
                                    ? l10n.shopAddToGarden
                                    : l10n.shopEarnMoreNc,
                                style: AppTypography.labelSmall.copyWith(
                                  color: canAfford
                                      ? Colors.white
                                      : AppColors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
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
// HAYAT SECTION
// ═══════════════════════════════════════════════════════════════════════════

class _HayatSection extends ConsumerWidget {
  const _HayatSection({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iap = ref.read(iapServiceProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.xl, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gold separator
          Container(
            height: 2,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: _goldGradient),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(l10n.shopHayatTitle,
              style: AppTypography.titleLarge.copyWith(
                  color: _textWarm, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),

          Row(
            children: [
              Expanded(
                child: _HayatCard(
                  icon: Icons.water_drop_rounded,
                  name: l10n.shopHayatDrop,
                  ncPrice: 2500,
                  usdPrice: iap.priceForProduct(IapProductIds.hayatDrop, fallback: '\$0.50'),
                  onTap: () => iap.buyProduct(IapProductIds.hayatDrop),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _HayatCard(
                  icon: Icons.local_florist_rounded,
                  name: l10n.shopHayatBloom,
                  ncPrice: 8000,
                  usdPrice: iap.priceForProduct(IapProductIds.hayatBloom, fallback: '\$1.50'),
                  onTap: () => iap.buyProduct(IapProductIds.hayatBloom),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HayatCard extends StatelessWidget {
  const _HayatCard({
    required this.icon,
    required this.name,
    required this.ncPrice,
    required this.usdPrice,
    required this.onTap,
  });

  final IconData icon;
  final String name;
  final int ncPrice;
  final String usdPrice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.noorGold.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 36, color: AppColors.noorGold),
            const SizedBox(height: AppSpacing.sm),
            Text(name,
                style: AppTypography.titleSmall
                    .copyWith(color: _textWarm, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded,
                    color: AppColors.noorGold, size: 14),
                const SizedBox(width: 3),
                Text('$ncPrice',
                    style: AppTypography.labelLarge
                        .copyWith(color: AppColors.noorGold)),
              ],
            ),
            Text(usdPrice,
                style: AppTypography.labelSmall.copyWith(color: _textDim)),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NC IAP SECTION
// ═══════════════════════════════════════════════════════════════════════════

class _NcIapSection extends ConsumerWidget {
  const _NcIapSection({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iap = ref.read(iapServiceProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.lg, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: _cardBorder,
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(l10n.shopNcTitle,
              style: AppTypography.titleLarge.copyWith(
                  color: _textWarm, fontWeight: FontWeight.w700)),
          const SizedBox(height: AppSpacing.md),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 1.4,
            children: [
              _NcPackCard(name: l10n.shopStarterNoor, nc: 1000,
                  usd: iap.priceForProduct(IapProductIds.ncStarter, fallback: '\$0.35'),
                  onTap: () => iap.buyProduct(IapProductIds.ncStarter)),
              _NcPackCard(name: l10n.shopHandfulNoor, nc: 5000,
                  usd: iap.priceForProduct(IapProductIds.ncHandful, fallback: '\$1.25'),
                  onTap: () => iap.buyProduct(IapProductIds.ncHandful)),
              _NcPackCard(name: l10n.shopGardensWorth, nc: 10000,
                  usd: iap.priceForProduct(IapProductIds.ncGarden, fallback: '\$2.49'),
                  onTap: () => iap.buyProduct(IapProductIds.ncGarden)),
              _NcPackCard(name: l10n.shopBlessedHarvest, nc: 25000,
                  usd: iap.priceForProduct(IapProductIds.ncHarvest, fallback: '\$4.99'),
                  onTap: () => iap.buyProduct(IapProductIds.ncHarvest)),
            ],
          ),
        ],
      ),
    );
  }
}

class _NcPackCard extends StatelessWidget {
  const _NcPackCard({
    required this.name,
    required this.nc,
    required this.usd,
    this.onTap,
  });

  final String name;
  final int nc;
  final String usd;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: _cardBorder),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.stars_rounded,
                    color: AppColors.noorGold, size: 18),
                const SizedBox(width: 4),
                Text('$nc',
                    style: AppTypography.titleMedium.copyWith(
                        color: AppColors.noorGold,
                        fontWeight: FontWeight.w800)),
              ],
            ),
            const SizedBox(height: 2),
            Text(name,
                style: AppTypography.labelSmall
                    .copyWith(color: _textWarm, fontSize: 11),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: _goldGradient),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(usd,
                  style: AppTypography.labelSmall.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
