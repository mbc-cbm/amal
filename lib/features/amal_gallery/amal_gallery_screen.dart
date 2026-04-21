import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/models/amal_model.dart';
import '../../core/providers/amal_gallery_provider.dart';

// ── Category filter helper ──────────────────────────────────────────────────

const _kCategoryFilters = [
  null, // "All"
  AmalCategory.prayer,
  AmalCategory.family,
  AmalCategory.community,
  AmalCategory.self,
  AmalCategory.knowledge,
  AmalCategory.charity,
];

// ── Main screen ─────────────────────────────────────────────────────────────

class AmalGalleryScreen extends ConsumerStatefulWidget {
  const AmalGalleryScreen({super.key});

  @override
  ConsumerState<AmalGalleryScreen> createState() => _AmalGalleryScreenState();
}

class _AmalGalleryScreenState extends ConsumerState<AmalGalleryScreen> {
  AmalCategory? _selectedCategory;
  bool _searchActive = false;
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String _categoryLabel(AmalCategory? category, AppLocalizations l10n) {
    if (category == null) return l10n.amalCategoryAll;
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final locale = Localizations.localeOf(context).languageCode;

    final amalsAsync = ref.watch(
      amalsProvider((
        category: _selectedCategory,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        locale: locale,
      )),
    );

    final favouriteIdsAsync = ref.watch(favouriteAmalIdsProvider);
    final favouriteIds = favouriteIdsAsync.valueOrNull ?? <String>{};

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(
          l10n.amalGallery,
          style: AppTypography.titleLarge.copyWith(color: cs.onSurface),
        ),
        backgroundColor: cs.surface,
        surfaceTintColor: AppColors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _searchActive ? Icons.close_rounded : Icons.search_rounded,
              color: cs.onSurface,
            ),
            onPressed: () {
              setState(() {
                _searchActive = !_searchActive;
                if (!_searchActive) {
                  _searchCtrl.clear();
                  _searchQuery = '';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search field ──────────────────────────────────────────────
          if (_searchActive)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              child: TextField(
                controller: _searchCtrl,
                autofocus: true,
                style: AppTypography.bodyLarge.copyWith(color: cs.onSurface),
                decoration: InputDecoration(
                  hintText: l10n.amalSearchHint,
                  hintStyle: AppTypography.bodyLarge
                      .copyWith(color: cs.onSurfaceVariant),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: cs.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
            ),

          // ── Category filter chips ────────────────────────────────────
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              separatorBuilder: (_, _) =>
                  const SizedBox(width: AppSpacing.sm),
              itemCount: _kCategoryFilters.length,
              itemBuilder: (context, i) {
                final cat = _kCategoryFilters[i];
                final selected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppColors.primaryGreen
                          : cs.surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _categoryLabel(cat, l10n),
                      style: AppTypography.labelLarge.copyWith(
                        color: selected
                            ? AppColors.white
                            : cs.onSurfaceVariant,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // ── Amal list ────────────────────────────────────────────────
          Expanded(
            child: amalsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryGreen,
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Text(
                    l10n.errorGeneric,
                    style: AppTypography.bodyMedium
                        .copyWith(color: cs.onSurfaceVariant),
                    textAlign: TextAlign.center,
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
                          Icons.search_off_rounded,
                          size: AppSpacing.iconXl,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          l10n.amalNoResults,
                          style: AppTypography.bodyMedium
                              .copyWith(color: cs.onSurfaceVariant),
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
                  itemBuilder: (context, i) => _AmalCard(
                    amal: amals[i],
                    locale: locale,
                    isFavourite: favouriteIds.contains(amals[i].id),
                    onTap: () => context.push(
                      '/amal-gallery/detail',
                      extra: amals[i],
                    ),
                    onToggleFavourite: () {
                      ref
                          .read(amalGalleryServiceProvider)
                          .toggleFavourite(amals[i].id);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Amal Card ───────────────────────────────────────────────────────────────

class _AmalCard extends StatelessWidget {
  const _AmalCard({
    required this.amal,
    required this.locale,
    required this.isFavourite,
    required this.onTap,
    required this.onToggleFavourite,
  });

  final AmalModel amal;
  final String locale;
  final bool isFavourite;
  final VoidCallback onTap;
  final VoidCallback onToggleFavourite;

  Color _difficultyColor(AmalDifficulty difficulty) {
    return switch (difficulty) {
      AmalDifficulty.easy => AppColors.success,
      AmalDifficulty.medium => AppColors.warning,
      AmalDifficulty.high => AppColors.error,
    };
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Left: content indicator + difficulty ─────────────────
            Column(
              children: [
                Icon(
                  amal.contentType == AmalContentType.video
                      ? Icons.play_circle_outline_rounded
                      : Icons.article_rounded,
                  color: cs.onSurfaceVariant,
                  size: AppSpacing.iconLg,
                ),
                const SizedBox(height: AppSpacing.xs),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _difficultyColor(amal.difficulty),
                  ),
                ),
              ],
            ),

            const SizedBox(width: AppSpacing.md),

            // ── Center: title + category + reward ───────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    amal.localizedTitle(locale),
                    style: AppTypography.titleMedium
                        .copyWith(color: cs.onSurface),
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
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusFull),
                        ),
                        child: Text(
                          _categoryChipLabel(amal.category, l10n),
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      // Noor Coins badge
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars_rounded,
                            color: AppColors.noorGold,
                            size: AppSpacing.iconSm,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            l10n.amalNoorCoinsReward(amal.noorCoins),
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.noorGold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Right: favourite heart ──────────────────────────────
            GestureDetector(
              onTap: onToggleFavourite,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xs),
                child: Icon(
                  isFavourite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavourite ? AppColors.error : cs.onSurfaceVariant,
                  size: AppSpacing.iconMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryChipLabel(AmalCategory category, AppLocalizations l10n) {
    return switch (category) {
      AmalCategory.prayer => l10n.amalCategoryPrayer,
      AmalCategory.family => l10n.amalCategoryFamily,
      AmalCategory.community => l10n.amalCategoryCommunity,
      AmalCategory.self => l10n.amalCategorySelf,
      AmalCategory.knowledge => l10n.amalCategoryKnowledge,
      AmalCategory.charity => l10n.amalCategoryCharity,
    };
  }
}
