import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/asset_model.dart';
import '../services/garden_neglect_service.dart';
import '../services/garden_service.dart';
import '../storage/garden_asset_hive.dart';

// ── Service provider ────────────────────────────────────────────────────────

final gardenServiceProvider = Provider<GardenService>((_) => GardenService());

// ── Hive migration (runs once on first garden access) ────────────────────

final gardenHiveMigrationProvider = FutureProvider<void>((ref) async {
  final svc = ref.read(gardenServiceProvider);
  await svc.migrateFromSharedPreferences();
});

// ── Garden access stream ────────────────────────────────────────────────────

/// Live stream of the current user's garden access status.
final gardenAccessProvider = StreamProvider<GardenAccessStatus>((ref) {
  try {
    final svc = ref.read(gardenServiceProvider);
    return svc.watchGardenAccess().handleError((_) {
      return GardenAccessStatus(isPremium: false);
    });
  } catch (_) {
    return Stream.value(GardenAccessStatus(isPremium: false));
  }
});

// ── Store assets ────────────────────────────────────────────────────────────

/// Fetches store assets, optionally filtered by [AssetCategory].
final storeAssetsProvider =
    FutureProvider.family<List<AssetModel>, AssetCategory?>((ref, category) {
  final svc = ref.read(gardenServiceProvider);
  return svc.fetchStoreAssets(category: category);
});

// ── Owned asset IDs ─────────────────────────────────────────────────────────

/// Returns the set of asset IDs the current user owns.
final ownedAssetIdsProvider = FutureProvider<Set<String>>((ref) {
  final svc = ref.read(gardenServiceProvider);
  return svc.fetchOwnedAssetIds();
});

// ═══════════════════════════════════════════════════════════════════════════
// GARDEN STATE (level, neglect, sacred centre)
// ═══════════════════════════════════════════════════════════════════════════

/// Raw garden state document from Firestore (real-time stream).
final gardenStateProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value({});
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('gardenState')
      .doc('state')
      .snapshots()
      .map((s) => s.data() ?? {})
      .handleError((_) => <String, dynamic>{});
});

/// User's current garden level (computed from totalNcEverEarned).
/// Level 1: Al-Rawdah (< 20,000)
/// Level 2: Al-Firdaws (20,000+)
/// Level 3: Al-Na'im (50,000+)
/// Level 4: Jannat al-Ma'wa (100,000+)
final gardenLevelProvider = Provider<int>((ref) {
  final state = ref.watch(gardenStateProvider).valueOrNull ?? {};
  final totalEarned = (state['totalNcEverEarned'] as num?)?.toInt() ?? 0;
  if (totalEarned >= 100000) return 4;
  if (totalEarned >= 50000) return 3;
  if (totalEarned >= 20000) return 2;
  return 1;
});

/// Computed neglect state from garden state data.
final gardenNeglectStateProvider = Provider<GardenNeglectState>((ref) {
  final state = ref.watch(gardenStateProvider).valueOrNull ?? {};
  final lastActiveTs = state['lastActiveDate'] as Timestamp?;
  final consecutive =
      (state['consecutiveActiveDays'] as num?)?.toInt() ?? 0;

  if (lastActiveTs == null) return GardenNeglectState.flourishing;

  return GardenNeglectService().computeState(
    lastActiveDate: lastActiveTs.toDate(),
    consecutiveActiveDays: consecutive,
  );
});

/// Sacred centre slot key ("x,y") from gardenState.
final sacredCentreProvider = Provider<String?>((ref) {
  final state = ref.watch(gardenStateProvider).valueOrNull ?? {};
  return state['sacredCentreSlotKey'] as String?;
});

// ═══════════════════════════════════════════════════════════════════════════
// PLACED ASSETS (Hive local storage)
// ═══════════════════════════════════════════════════════════════════════════

/// All placed assets from Hive (local).
final placedAssetsProvider = Provider<Map<String, GardenAssetHive>>((ref) {
  ref.watch(gardenHiveMigrationProvider);
  final svc = ref.read(gardenServiceProvider);
  return svc.loadAllAssetsFromHive();
});

// ═══════════════════════════════════════════════════════════════════════════
// QUESTION MARKS (active, from Firestore)
// ═══════════════════════════════════════════════════════════════════════════

/// Active question marks that haven't expired.
final questionMarksProvider =
    StreamProvider<List<Map<String, dynamic>>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('questionMarks')
      .where('isActive', isEqualTo: true)
      .where('expiresAt', isGreaterThan: Timestamp.now())
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()).toList())
      .handleError((_) => <Map<String, dynamic>>[]);
});

// ═══════════════════════════════════════════════════════════════════════════
// OUTER GARDEN (rainfall intensity + referral stats)
// ═══════════════════════════════════════════════════════════════════════════

/// Real-time rainfall intensity (0.0–1.0).
final outerGardenIntensityProvider = StreamProvider<double>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(0.0);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('outerGardenStats')
      .doc('stats')
      .snapshots()
      .map((s) =>
          (s.data()?['currentRainfallIntensity'] as num?)?.toDouble() ?? 0.0)
      .handleError((_) => 0.0);
});

/// Outer garden referral stats (real-time).
final outerGardenStatsProvider =
    StreamProvider<Map<String, dynamic>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value({});
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .collection('outerGardenStats')
      .doc('stats')
      .snapshots()
      .map((s) => s.data() ?? {})
      .handleError((_) => <String, dynamic>{});
});

// ═══════════════════════════════════════════════════════════════════════════
// NOOR COIN BALANCE (real-time)
// ═══════════════════════════════════════════════════════════════════════════

// ── Pending placement (after purchase, awaiting slot tap) ────────────────

/// Asset template ID pending placement in the garden.
final pendingPlacementProvider = StateProvider<String?>((ref) => null);

// ═══════════════════════════════════════════════════════════════════════════
// NOOR COIN BALANCE (real-time)
// ═══════════════════════════════════════════════════════════════════════════

/// Real-time Noor Coin balance from user document.
final noorBalanceProvider = StreamProvider<int>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(0);
  return FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .snapshots()
      .map((s) =>
          (s.data()?['noorCoinBalance'] as num?)?.toInt() ?? 0)
      .handleError((_) => 0);
});

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY PROVIDERS (kept for backward compat, delegate to new ones)
// ═══════════════════════════════════════════════════════════════════════════

/// Reads the user's rainforest intensity (0-100) — legacy FutureProvider.
final rainforestIntensityProvider = FutureProvider<int>((ref) {
  final svc = ref.read(gardenServiceProvider);
  return svc.fetchRainforestIntensity();
});

/// Reads the user's referral code string.
final referralCodeProvider = FutureProvider<String>((ref) {
  final svc = ref.read(gardenServiceProvider);
  return svc.fetchReferralCode();
});
