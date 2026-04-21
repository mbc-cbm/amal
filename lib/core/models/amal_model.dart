import 'package:cloud_firestore/cloud_firestore.dart';

// ── Enums ──────────────────────────────────────────────────────────────────

/// Categories of good deeds in the amals collection.
enum AmalCategory {
  prayer,
  family,
  community,
  self,
  knowledge,
  charity;

  String get key => name;

  static AmalCategory fromKey(String key) =>
      AmalCategory.values.firstWhere((e) => e.key == key,
          orElse: () => AmalCategory.self);
}

/// Whether the amal content is static text or includes a video.
enum AmalContentType {
  static,
  video;

  String get key => name;

  static AmalContentType fromKey(String key) =>
      AmalContentType.values.firstWhere((e) => e.key == key,
          orElse: () => AmalContentType.static);
}

/// How often the amal can/should be completed.
enum AmalCompletionType {
  oneTime,
  daily,
  weekly,
  ongoing;

  String get key => switch (this) {
        AmalCompletionType.oneTime => 'one_time',
        AmalCompletionType.daily => 'daily',
        AmalCompletionType.weekly => 'weekly',
        AmalCompletionType.ongoing => 'ongoing',
      };

  static AmalCompletionType fromKey(String key) => switch (key) {
        'one_time' => AmalCompletionType.oneTime,
        'daily' => AmalCompletionType.daily,
        'weekly' => AmalCompletionType.weekly,
        'ongoing' => AmalCompletionType.ongoing,
        _ => AmalCompletionType.oneTime,
      };
}

/// Difficulty level for an amal.
enum AmalDifficulty {
  easy,
  medium,
  high;

  String get key => name;

  static AmalDifficulty fromKey(String key) =>
      AmalDifficulty.values.firstWhere((e) => e.key == key,
          orElse: () => AmalDifficulty.easy);
}

// ── Model ──────────────────────────────────────────────────────────────────

/// Represents a good deed (amal) entry in the amals collection.
/// The amals collection is read-only from the client.
class AmalModel {
  const AmalModel({
    required this.id,
    required this.titleEn,
    required this.titleBn,
    required this.titleUr,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionBn,
    required this.descriptionUr,
    required this.descriptionAr,
    required this.category,
    required this.subcategory,
    required this.contentType,
    required this.videoUrl,
    required this.videoThumbnailUrl,
    required this.duaTextEn,
    required this.duaTextAr,
    required this.noorCoins,
    required this.completionType,
    required this.difficulty,
    required this.source,
    required this.isScholarReviewed,
    required this.createdAt,
    required this.isActive,
  });

  final String id;

  // ── Localised titles ───────────────────────────────────────────────────
  final String titleEn;
  final String titleBn;
  final String titleUr;
  final String titleAr;

  // ── Localised descriptions ─────────────────────────────────────────────
  final String descriptionEn;
  final String descriptionBn;
  final String descriptionUr;
  final String descriptionAr;

  // ── Classification ─────────────────────────────────────────────────────
  final AmalCategory category;
  final String subcategory;
  final AmalContentType contentType;

  // ── Video ──────────────────────────────────────────────────────────────
  final String videoUrl;
  final String videoThumbnailUrl;

  // ── Dua ────────────────────────────────────────────────────────────────
  final String duaTextEn;
  final String duaTextAr;

  // ── Reward & progression ───────────────────────────────────────────────
  final int noorCoins;
  final AmalCompletionType completionType;
  final AmalDifficulty difficulty;

  // ── Provenance ─────────────────────────────────────────────────────────
  final String source; // Quran / Hadith reference
  final bool isScholarReviewed;
  final DateTime createdAt;
  final bool isActive;

  // ── Firestore factory ──────────────────────────────────────────────────

  factory AmalModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AmalModel(
      id: doc.id,
      titleEn: data['title_en'] as String? ?? '',
      titleBn: data['title_bn'] as String? ?? '',
      titleUr: data['title_ur'] as String? ?? '',
      titleAr: data['title_ar'] as String? ?? '',
      descriptionEn: data['description_en'] as String? ?? '',
      descriptionBn: data['description_bn'] as String? ?? '',
      descriptionUr: data['description_ur'] as String? ?? '',
      descriptionAr: data['description_ar'] as String? ?? '',
      category: AmalCategory.fromKey(data['category'] as String? ?? 'self'),
      subcategory: data['subcategory'] as String? ?? '',
      contentType:
          AmalContentType.fromKey(data['contentType'] as String? ?? 'static'),
      videoUrl: data['videoUrl'] as String? ?? '',
      videoThumbnailUrl: data['videoThumbnailUrl'] as String? ?? '',
      duaTextEn: data['duaText_en'] as String? ?? '',
      duaTextAr: data['duaText_ar'] as String? ?? '',
      noorCoins: (data['noorCoins'] as num?)?.toInt() ?? 0,
      completionType: AmalCompletionType.fromKey(
          data['completionType'] as String? ?? 'one_time'),
      difficulty:
          AmalDifficulty.fromKey(data['difficulty'] as String? ?? 'easy'),
      source: data['source'] as String? ?? '',
      isScholarReviewed: data['is_scholar_reviewed'] as bool? ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000),
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  // ── Localisation helpers ───────────────────────────────────────────────

  String localizedTitle(String locale) => switch (locale) {
        'bn' => titleBn.isNotEmpty ? titleBn : titleEn,
        'ur' => titleUr.isNotEmpty ? titleUr : titleEn,
        'ar' => titleAr.isNotEmpty ? titleAr : titleEn,
        _ => titleEn,
      };

  String localizedDescription(String locale) => switch (locale) {
        'bn' => descriptionBn.isNotEmpty ? descriptionBn : descriptionEn,
        'ur' => descriptionUr.isNotEmpty ? descriptionUr : descriptionEn,
        'ar' => descriptionAr.isNotEmpty ? descriptionAr : descriptionEn,
        _ => descriptionEn,
      };
}
