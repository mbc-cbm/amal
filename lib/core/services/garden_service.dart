import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

import '../models/asset_model.dart';
import '../storage/garden_asset_hive.dart';
import '../storage/hive_boxes.dart';
import '../utils/app_preferences.dart';

// ── Data classes ─────────────────────────────────────────────────────────────

enum AssetCategory { treesAndPlants, waterFeatures, flowersAndGrass, structures, skyAndLighting, animals }

extension AssetCategoryX on AssetCategory {
  String get key => switch (this) {
    AssetCategory.treesAndPlants => 'trees_and_plants',
    AssetCategory.waterFeatures => 'water_features',
    AssetCategory.flowersAndGrass => 'flowers_and_grass',
    AssetCategory.structures => 'structures',
    AssetCategory.skyAndLighting => 'sky_and_lighting',
    AssetCategory.animals => 'animals',
  };

  static AssetCategory? fromKey(String key) {
    for (final cat in AssetCategory.values) {
      if (cat.key == key) return cat;
    }
    return null;
  }
}

class GardenAccessStatus {
  GardenAccessStatus({
    required this.isPremium,
    this.hasActiveTimer = false,
    this.expiresAt,
    this.remaining,
  });

  final bool isPremium;
  final bool hasActiveTimer;
  final DateTime? expiresAt;
  final Duration? remaining;

  /// Can place, move, buy assets, etc.
  bool get canDoActions => isPremium || hasActiveTimer;

  /// Everyone can enter the garden and explore.
  bool get canEnterGarden => true;

  // Backward compat
  bool get hasAccess => canDoActions;
}

class PlacedAsset {
  PlacedAsset({
    required this.assetId,
    required this.gridX,
    required this.gridY,
    required this.vitality,
    required this.placedAt,
    required this.lastVitalityUpdate,
  });

  final String assetId;
  final int gridX;
  final int gridY;
  final int vitality; // 0-100
  final DateTime placedAt;
  final DateTime lastVitalityUpdate;

  Map<String, dynamic> toJson() => {
        'assetId': assetId,
        'gridX': gridX,
        'gridY': gridY,
        'vitality': vitality,
        'placedAt': placedAt.toIso8601String(),
        'lastVitalityUpdate': lastVitalityUpdate.toIso8601String(),
      };

  factory PlacedAsset.fromJson(Map<String, dynamic> json) => PlacedAsset(
        assetId: json['assetId'] as String,
        gridX: (json['gridX'] as num).toInt(),
        gridY: (json['gridY'] as num).toInt(),
        vitality: (json['vitality'] as num).toInt(),
        placedAt: DateTime.parse(json['placedAt'] as String),
        lastVitalityUpdate:
            DateTime.parse(json['lastVitalityUpdate'] as String),
      );
}

class GardenGridState {
  GardenGridState({
    required this.spots,
    required this.savedAt,
  });

  final Map<String, PlacedAsset> spots; // key = "x,y"
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'spots': spots.map((k, v) => MapEntry(k, v.toJson())),
        'savedAt': savedAt.toIso8601String(),
      };

  factory GardenGridState.fromJson(Map<String, dynamic> json) {
    final rawSpots = json['spots'] as Map<String, dynamic>;
    return GardenGridState(
      spots: rawSpots.map(
        (k, v) => MapEntry(k, PlacedAsset.fromJson(v as Map<String, dynamic>)),
      ),
      savedAt: DateTime.parse(json['savedAt'] as String),
    );
  }
}

// ── Service ──────────────────────────────────────────────────────────────────

class GardenService {
  GardenService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not authenticated.');
    return uid;
  }

  // ── watchGardenAccess ─────────────────────────────────────────────────────

  /// Live stream of [GardenAccessStatus] derived from the user document.
  /// Reads `gardenAccessTimer.expiresAt` and `subscriptionStatus`.
  Stream<GardenAccessStatus> watchGardenAccess() {
    final uid = _requireUid();

    return _firestore.collection('users').doc(uid).snapshots().map((snap) {
      final data = snap.data() ?? {};

      // Developer accounts always have full garden access
      final email = _auth.currentUser?.email ?? '';
      const devEmails = {'amal.app2026@gmail.com'};
      if (devEmails.contains(email)) {
        return GardenAccessStatus(isPremium: true, hasActiveTimer: true);
      }

      final subStatus = data['subscriptionStatus'] as String? ?? '';
      final isPremium = subStatus == 'premium';

      if (isPremium) {
        return GardenAccessStatus(isPremium: true, hasActiveTimer: true);
      }

      final timerData =
          data['gardenAccessTimer'] as Map<String, dynamic>? ?? {};
      final expiresTs = timerData['expiresAt'] as Timestamp?;
      final expiresAt = expiresTs?.toDate();

      if (expiresAt == null) {
        return GardenAccessStatus(isPremium: false);
      }

      final now = DateTime.now();
      final remaining = expiresAt.difference(now);
      final hasTimer = !remaining.isNegative;

      return GardenAccessStatus(
        isPremium: false,
        hasActiveTimer: hasTimer,
        expiresAt: expiresAt,
        remaining: hasTimer ? remaining : Duration.zero,
      );
    });
  }

  // ── fetchStoreAssets ──────────────────────────────────────────────────────

  /// Queries the `assetTemplates` collection.
  /// Filters: isScholarReviewed == true, isAvailableInShop == true,
  /// and requiredLevel <= [userLevel].
  /// Optionally filtered by [category].
  Future<List<AssetModel>> fetchStoreAssets({
    AssetCategory? category,
    int userLevel = 1,
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('assetTemplates')
        .where('isScholarReviewed', isEqualTo: true)
        .where('isAvailableInShop', isEqualTo: true)
        .where('requiredLevel', isLessThanOrEqualTo: userLevel);

    if (category != null) {
      query = query.where('category', isEqualTo: category.key);
    }

    final snap = await query.get();
    return snap.docs.map(AssetModel.fromFirestore).toList();
  }

  // ── fetchOwnedAssetIds ────────────────────────────────────────────────────

  /// Reads `users/{uid}/gardenAssets` sub-collection and returns a set of
  /// owned asset IDs.
  Future<Set<String>> fetchOwnedAssetIds() async {
    final uid = _requireUid();
    final snap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('gardenAssets')
        .get();

    return snap.docs.map((d) => d.id).toSet();
  }

  // ── purchaseAsset ─────────────────────────────────────────────────────────

  /// Calls the `spendNoorCoins` Cloud Function to purchase an asset.
  Future<void> purchaseAsset(String assetId, int cost) async {
    final uid = _requireUid();
    await _functions
        .httpsCallable('spendNoorCoins')
        .call<Map<String, dynamic>>({
      'uid': uid,
      'amount': cost,
      'source': 'garden_purchase',
      'assetId': assetId,
    });
  }

  // ── restoreAsset ──────────────────────────────────────────────────────────

  /// Calls the `spendNoorCoins` Cloud Function to restore a withered asset
  /// at half the original cost.
  Future<void> restoreAsset(String assetId, int cost) async {
    final uid = _requireUid();
    final halfCost = (cost / 2).ceil();
    await _functions
        .httpsCallable('spendNoorCoins')
        .call<Map<String, dynamic>>({
      'uid': uid,
      'amount': halfCost,
      'source': 'garden_restore',
      'assetId': assetId,
    });
  }

  // ── Grid state (SharedPreferences) ────────────────────────────────────────

  /// Saves the garden grid state to SharedPreferences as JSON.
  Future<void> saveGridState(GardenGridState state) async {
    final json = jsonEncode(state.toJson());
    await AppPreferences.instance.setGardenGridJson(json);
  }

  /// Loads the garden grid state from SharedPreferences.
  GardenGridState? loadGridState() {
    final raw = AppPreferences.instance.gardenGridJson;
    if (raw == null) return null;
    return GardenGridState.fromJson(
      jsonDecode(raw) as Map<String, dynamic>,
    );
  }

  // ── fetchRainforestIntensity ──────────────────────────────────────────────

  /// Reads `rainforestIntensity` from the user document. Returns 0-100.
  Future<int> fetchRainforestIntensity() async {
    final uid = _requireUid();
    final snap = await _firestore.collection('users').doc(uid).get();
    final data = snap.data() ?? {};
    return (data['rainforestIntensity'] as num?)?.toInt() ?? 0;
  }

  // ── fetchReferralCode ─────────────────────────────────────────────────────

  /// Reads `referralCode` from the user document.
  Future<String> fetchReferralCode() async {
    final uid = _requireUid();
    final snap = await _firestore.collection('users').doc(uid).get();
    final data = snap.data() ?? {};
    return data['referralCode'] as String? ?? '';
  }

  // ── Garden warning (SharedPreferences) ────────────────────────────────────

  /// Whether the user has already seen the garden warning dialog.
  bool hasSeenGardenWarning() => AppPreferences.instance.gardenWarningSeen;

  /// Marks the garden warning as seen.
  Future<void> setGardenWarningSeen() =>
      AppPreferences.instance.setGardenWarningSeen();

  // ── Hive garden grid storage ──────────────────────────────────────────────

  /// Saves a single asset to the Hive garden grid box, keyed by slotKey.
  Future<void> saveAssetToHive(GardenAssetHive asset) async {
    final box = Hive.box<GardenAssetHive>(HiveBoxes.gardenGrid);
    await box.put(asset.slotKey, asset);
  }

  /// Removes an asset from the Hive garden grid box by slotKey.
  Future<void> removeAssetFromHive(String slotKey) async {
    final box = Hive.box<GardenAssetHive>(HiveBoxes.gardenGrid);
    await box.delete(slotKey);
  }

  /// Loads all placed assets from Hive.
  Map<String, GardenAssetHive> loadAllAssetsFromHive() {
    final box = Hive.box<GardenAssetHive>(HiveBoxes.gardenGrid);
    return Map.fromEntries(
      box.keys.map((k) => MapEntry(k.toString(), box.get(k)!)),
    );
  }

  /// One-time migration from SharedPreferences JSON to Hive.
  /// No-op if Hive already has data.
  Future<void> migrateFromSharedPreferences() async {
    final box = Hive.box<GardenAssetHive>(HiveBoxes.gardenGrid);
    if (box.isNotEmpty) return; // already migrated

    final oldJson = AppPreferences.instance.gardenGridJson;
    if (oldJson == null) return;

    try {
      final data = jsonDecode(oldJson) as Map<String, dynamic>;
      final spots = data['spots'] as Map<String, dynamic>? ?? {};
      for (final entry in spots.entries) {
        final v = entry.value as Map<String, dynamic>;
        final asset = GardenAssetHive(
          slotKey: entry.key,
          assetTemplateId: v['assetId'] as String? ?? '',
          positionX: 0,
          positionY: 0,
          tier: 'common',
          isDiscovered: false,
          currentHealthState: 1,
          originalNcPrice: (v['vitality'] as num?)?.toInt() ?? 0,
          purchaseType: 'nc',
          isPlaced: true,
          purchasedAtMs: DateTime.now().millisecondsSinceEpoch,
        );
        await box.put(entry.key, asset);
      }
    } catch (_) {
      // Ignore parse errors on old data
    }
  }
}
