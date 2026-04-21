import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a garden asset from the `assetTemplates` collection.
/// Read-only from the client. Purchases handled by Cloud Functions.
class AssetModel {
  const AssetModel({
    required this.id,
    required this.nameEn,
    required this.nameBn,
    required this.nameAr,
    required this.nameUr,
    required this.tier,
    required this.ncPrice,
    required this.category,
    required this.referenceEn,
    required this.referenceTextAr,
    required this.isLevelGated,
    required this.requiredLevel,
    required this.isAvailableInShop,
    required this.preLovedCount,
    required this.imageUrl,
    required this.isScholarReviewed,
    required this.isAvailable,
  });

  final String id;
  final String nameEn;
  final String nameBn;
  final String nameAr;
  final String nameUr;

  /// 'common' | 'standard' | 'premium' | 'sacred' | 'water_ocean'
  final String tier;

  /// Cost in Noor Coins only — no USD pricing on assets.
  final int ncPrice;

  /// e.g. 'tree', 'flower', 'fountain', 'building', 'decoration'
  final String category;

  /// Source reference, e.g. "Quran 53:14"
  final String referenceEn;

  /// Arabic calligraphy shown on first placement.
  final String referenceTextAr;

  /// Whether this asset requires a minimum garden level.
  final bool isLevelGated;

  /// Required garden level (1-4). Only relevant if [isLevelGated] is true.
  final int requiredLevel;

  /// false = discovered-only asset (from question marks), not in shop.
  final bool isAvailableInShop;

  /// Always 0 in v1; v2 architecture field for pre-loved marketplace.
  final int preLovedCount;

  /// Empty string in v1 — CustomPainter used for rendering.
  final String imageUrl;

  /// CRITICAL: only assets with isScholarReviewed == true are shown in UI.
  final bool isScholarReviewed;

  final bool isAvailable;

  factory AssetModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AssetModel(
      id: doc.id,
      nameEn: data['nameEn'] as String? ?? '',
      nameBn: data['nameBn'] as String? ?? '',
      nameAr: data['nameAr'] as String? ?? '',
      nameUr: data['nameUr'] as String? ?? '',
      tier: data['tier'] as String? ?? 'common',
      ncPrice: (data['ncPrice'] as num?)?.toInt() ?? 0,
      category: data['category'] as String? ?? '',
      referenceEn: data['referenceEn'] as String? ?? '',
      referenceTextAr: data['referenceTextAr'] as String? ?? '',
      isLevelGated: data['isLevelGated'] as bool? ?? false,
      requiredLevel: (data['requiredLevel'] as num?)?.toInt() ?? 1,
      isAvailableInShop: data['isAvailableInShop'] as bool? ?? true,
      preLovedCount: (data['preLovedCount'] as num?)?.toInt() ?? 0,
      imageUrl: data['imageUrl'] as String? ?? '',
      isScholarReviewed: data['isScholarReviewed'] as bool? ?? false,
      isAvailable: data['isAvailable'] as bool? ?? true,
    );
  }

  String localizedName(String locale) => switch (locale) {
        'bn' => nameBn.isNotEmpty ? nameBn : nameEn,
        'ur' => nameUr.isNotEmpty ? nameUr : nameEn,
        'ar' => nameAr.isNotEmpty ? nameAr : nameEn,
        _ => nameEn,
      };
}

// ── Asset Tier ──────────────────────────────────────────────────────────────

enum AssetTier { common, standard, premium, sacred, waterOcean }

extension AssetTierX on String {
  AssetTier get toAssetTier => switch (this) {
        'standard' => AssetTier.standard,
        'premium' => AssetTier.premium,
        'sacred' => AssetTier.sacred,
        'water_ocean' => AssetTier.waterOcean,
        _ => AssetTier.common,
      };

  String get tierDisplayLabel => switch (this) {
        'standard' => 'Standard',
        'premium' => 'Premium',
        'sacred' => 'Sacred',
        'water_ocean' => 'Water & Ocean',
        _ => 'Common',
      };

  Color get tierColor => switch (this) {
        'sacred' => const Color(0xFFC9942A), // gold
        'premium' => const Color(0xFF7B1FA2), // purple
        'standard' => const Color(0xFF1565C0), // blue
        'water_ocean' => const Color(0xFF00838F), // teal
        _ => const Color(0xFF388E3C), // green
      };
}
