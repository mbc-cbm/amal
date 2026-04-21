import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/amal_model.dart';

/// Reads from the `amals` collection and manages per-user amal interactions
/// (completions, favourites).
///
/// INVARIANT: Every query to the `amals` collection filters by
/// `is_scholar_reviewed == true` and `isActive == true`.
class AmalGalleryService {
  AmalGalleryService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseFunctions _functions;

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Fetches scholar-reviewed, active amals with optional filters.
  ///
  /// [category] — restricts to a single [AmalCategory].
  /// [searchQuery] — client-side filter on the localised title.
  /// [locale] — language code used for the client-side search filter.
  Future<List<AmalModel>> fetchAmals({
    AmalCategory? category,
    String? searchQuery,
    String locale = 'en',
  }) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('amals')
        .where('is_scholar_reviewed', isEqualTo: true)
        .where('isActive', isEqualTo: true);

    if (category != null) {
      query = query.where('category', isEqualTo: category.key);
    }

    final snap = await query.get();
    var amals = snap.docs.map(AmalModel.fromFirestore).toList();

    // Client-side search — Firestore does not support full-text search.
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final needle = searchQuery.toLowerCase();
      amals = amals.where((a) {
        return a.localizedTitle(locale).toLowerCase().contains(needle) ||
            a.localizedDescription(locale).toLowerCase().contains(needle);
      }).toList();
    }

    return amals;
  }

  /// Fetches a single amal by [amalId].
  Future<AmalModel> fetchAmalById(String amalId) async {
    final doc = await _firestore.collection('amals').doc(amalId).get();
    if (!doc.exists) {
      throw StateError('Amal $amalId not found.');
    }
    return AmalModel.fromFirestore(doc);
  }

  // ── Complete ─────────────────────────────────────────────────────────────

  /// Records an amal completion.
  ///
  /// Calls the `updateNoorWallet` Cloud Function with source `'amal'`,
  /// then writes a log entry to `users/{uid}/amalLog/{amalId}_{timestamp}`.
  Future<void> completeAmal({
    required String amalId,
    required int noorCoins,
  }) async {
    final uid = _requireUid();

    // 1. Award Noor Coins via Cloud Function.
    await _functions
        .httpsCallable('updateNoorWallet')
        .call<Map<String, dynamic>>({
      'uid': uid,
      'amount': noorCoins,
      'source': 'amal',
    });

    // 2. Write completion log entry.
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await _firestore
        .collection('users')
        .doc(uid)
        .collection('amalLog')
        .doc('${amalId}_$timestamp')
        .set({
      'amalId': amalId,
      'noorCoins': noorCoins,
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Favourites ───────────────────────────────────────────────────────────

  /// Toggles the favourite state of [amalId] for the current user.
  ///
  /// If the document exists it is deleted; otherwise it is created.
  Future<void> toggleFavourite(String amalId) async {
    final uid = _requireUid();
    final ref = _firestore
        .collection('users')
        .doc(uid)
        .collection('favourites')
        .doc(amalId);

    final snap = await ref.get();
    if (snap.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'amalId': amalId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Live stream of the current user's favourite amal IDs.
  Stream<Set<String>> watchFavourites() {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('favourites')
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toSet());
  }

  // ── Completion counts ────────────────────────────────────────────────────

  /// Returns the number of times the current user has completed [amalId]
  /// within the given [period]: `'today'`, `'this_week'`, or `'all_time'`.
  Future<int> fetchCompletionCount(
    String amalId, {
    required String period,
  }) async {
    final uid = _requireUid();
    Query<Map<String, dynamic>> query = _firestore
        .collection('users')
        .doc(uid)
        .collection('amalLog')
        .where('amalId', isEqualTo: amalId);

    final now = DateTime.now();

    switch (period) {
      case 'today':
        final startOfDay = DateTime(now.year, now.month, now.day);
        query = query.where('completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay));
        break;
      case 'this_week':
        final startOfWeek =
            DateTime(now.year, now.month, now.day - (now.weekday % 7));
        query = query.where('completedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfWeek));
        break;
      case 'all_time':
        // No additional filter.
        break;
    }

    final snap = await query.get();
    return snap.size;
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not authenticated.');
    return uid;
  }
}
