import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/amal_model.dart';
import '../../core/providers/amal_gallery_provider.dart';
import '../../core/providers/amal_tracker_provider.dart';
import '../../core/router/app_router.dart';

// ── Favourites Tab ─────────────────────────────────────────────────────────

class FavouritesTab extends ConsumerWidget {
  const FavouritesTab({super.key});

  String _categoryLabel(AmalCategory category, AppLocalizations l10n) {
    return switch (category) {
      AmalCategory.prayer => l10n.amalCategoryPrayer,
      AmalCategory.family => l10n.amalCategoryFamily,
      AmalCategory.community => l10n.amalCategoryCommunity,
      AmalCategory.self => l10n.amalCategorySelf,
      AmalCategory.knowledge => l10n.amalCategoryKnowledge,
      AmalCategory.charity => l10n.amalCategoryCharity,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;
    final favouritesAsync = ref.watch(favouriteAmalsProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          l10n.trackerFavourites,
          style: AppTypography.titleLarge.copyWith(color: cs.onSurface),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
      ),
      body: favouritesAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primaryGreen),
        ),
        error: (_, _) => Center(
          child: Text(
            l10n.errorGeneric,
            style: AppTypography.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ),
        data: (amals) {
          if (amals.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: AppSpacing.iconXl,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.trackerNoFavourites,
                    style: AppTypography.bodyMedium.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.sm),
            itemCount: amals.length,
            itemBuilder: (context, i) {
              final amal = amals[i];
              return GestureDetector(
                onTap: () => context.push(
                  AppRoutes.amalGalleryDetail,
                  extra: amal,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHighest,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Content ──────────────────────────────────────
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              amal.localizedTitle(locale),
                              style: AppTypography.titleMedium.copyWith(
                                color: cs.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Row(
                              children: [
                                // Category chip
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusFull,
                                    ),
                                  ),
                                  child: Text(
                                    _categoryLabel(amal.category, l10n),
                                    style:
                                        AppTypography.labelSmall.copyWith(
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                // Noor Coins badge
                                const Icon(
                                  Icons.stars_rounded,
                                  color: AppColors.noorGold,
                                  size: AppSpacing.iconSm,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  l10n.amalNoorCoinsReward(amal.noorCoins),
                                  style:
                                      AppTypography.labelSmall.copyWith(
                                    color: AppColors.noorGold,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // ── Favourite heart (remove) ─────────────────────
                      GestureDetector(
                        onTap: () {
                          ref
                              .read(amalGalleryServiceProvider)
                              .toggleFavourite(amal.id);
                          ref.invalidate(favouriteAmalsProvider);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: const Padding(
                          padding: EdgeInsets.all(AppSpacing.xs),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: AppColors.error,
                            size: AppSpacing.iconMd,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
