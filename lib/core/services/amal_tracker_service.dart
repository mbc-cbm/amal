import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../models/amal_model.dart';

// ── Data classes ─────────────────────────────────────────────────────────────

/// Aggregated tracker / streak statistics stored on the user document.
class AmalTrackerStats {
  const AmalTrackerStats({
    required this.currentDailyStreak,
    required this.longestDailyStreak,
    required this.currentWeeklyStreak,
    required this.longestWeeklyStreak,
    required this.lastAmalCompletedAt,
    required this.totalAmalsCompleted,
    required this.totalNoorCoinsFromAmals,
  });

  final int currentDailyStreak;
  final int longestDailyStreak;
  final int currentWeeklyStreak;
  final int longestWeeklyStreak;
  final DateTime? lastAmalCompletedAt;
  final int totalAmalsCompleted;
  final int totalNoorCoinsFromAmals;

  factory AmalTrackerStats.fromFirestore(Map<String, dynamic> data) {
    return AmalTrackerStats(
      currentDailyStreak:
          (data['currentDailyStreak'] as num?)?.toInt() ?? 0,
      longestDailyStreak:
          (data['longestDailyStreak'] as num?)?.toInt() ?? 0,
      currentWeeklyStreak:
          (data['currentWeeklyStreak'] as num?)?.toInt() ?? 0,
      longestWeeklyStreak:
          (data['longestWeeklyStreak'] as num?)?.toInt() ?? 0,
      lastAmalCompletedAt:
          (data['lastAmalCompletedAt'] as Timestamp?)?.toDate(),
      totalAmalsCompleted:
          (data['totalAmalsCompleted'] as num?)?.toInt() ?? 0,
      totalNoorCoinsFromAmals:
          (data['totalNoorCoinsFromAmals'] as num?)?.toInt() ?? 0,
    );
  }
}

/// A single amal completion log entry.
class AmalCompletion {
  const AmalCompletion({
    required this.amalId,
    required this.completedAt,
    required this.coinsAwarded,
  });

  final String amalId;
  final DateTime completedAt;
  final int coinsAwarded;

  factory AmalCompletion.fromFirestore(
      DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return AmalCompletion(
      amalId: data['amalId'] as String? ?? '',
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime(2000),
      coinsAwarded: (data['noorCoins'] as num?)?.toInt() ?? 0,
    );
  }
}

// ── Service ──────────────────────────────────────────────────────────────────

/// Reads tracker / streak data and daily-goal settings from Firestore.
class AmalTrackerService {
  AmalTrackerService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ── Tracker stats ────────────────────────────────────────────────────────

  /// Live stream of the current user's tracker / streak statistics.
  Stream<AmalTrackerStats> watchTrackerStats() {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) {
      final data = snap.data() ?? <String, dynamic>{};
      return AmalTrackerStats.fromFirestore(data);
    });
  }

  // ── Recent completions ───────────────────────────────────────────────────

  /// Fetches the most recent amal completions for the current user.
  Future<List<AmalCompletion>> fetchRecentCompletions({int limit = 10}) async {
    final uid = _requireUid();
    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('amalLog')
          .orderBy('completedAt', descending: true)
          .limit(limit)
          .get();

      return snap.docs.map(AmalCompletion.fromFirestore).toList();
    } catch (_) {
      // Collection may not exist yet for new users
      return [];
    }
  }

  // ── Amal of the Day ─────────────────────────────────────────────────────

  /// Returns the featured amal for today.
  ///
  /// Reads from `amalOfTheDay/{YYYY-MM-DD}`. If no document exists for
  /// today, falls back to the first scholar-reviewed amal in the `amals`
  /// collection.
  Future<AmalModel> fetchAmalOfTheDay() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final doc =
        await _firestore.collection('amalOfTheDay').doc(today).get();

    if (doc.exists) {
      final data = doc.data()!;
      final amalId = data['amalId'] as String?;
      if (amalId != null && amalId.isNotEmpty) {
        final amalDoc =
            await _firestore.collection('amals').doc(amalId).get();
        if (amalDoc.exists) {
          return AmalModel.fromFirestore(amalDoc);
        }
      }
    }

    // Fallback: first scholar-reviewed amal.
    final fallback = await _firestore
        .collection('amals')
        .where('is_scholar_reviewed', isEqualTo: true)
        .limit(1)
        .get();

    if (fallback.docs.isEmpty) {
      throw StateError('No scholar-reviewed amal found.');
    }

    return AmalModel.fromFirestore(fallback.docs.first);
  }

  // ── Daily goal ──────────────────────────────────────────────────────────

  /// Reads the user's daily amal goal. Returns `null` if not set.
  Future<int?> fetchDailyGoal() async {
    final uid = _requireUid();
    final snap = await _firestore.collection('users').doc(uid).get();
    final data = snap.data();
    if (data == null) return null;
    return (data['dailyAmalGoal'] as num?)?.toInt();
  }

  /// Writes or clears the daily amal goal on the user document.
  Future<void> setDailyGoal(int? goal) async {
    final uid = _requireUid();
    await _firestore.collection('users').doc(uid).update({
      'dailyAmalGoal': goal,
    });
  }

  // ── Today's completion count ────────────────────────────────────────────

  /// Counts how many amals the current user completed today.
  Future<int> fetchTodayCompletionCount() async {
    final uid = _requireUid();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    try {
      final snap = await _firestore
          .collection('users')
          .doc(uid)
          .collection('amalLog')
          .where('completedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .get();

      return snap.size;
    } catch (_) {
      return 0;
    }
  }

  // ── Favourite amals ─────────────────────────────────────────────────────

  /// Fetches the full [AmalModel] for each of the user's favourited amals.
  Future<List<AmalModel>> fetchFavouriteAmals() async {
    final uid = _requireUid();
    final favSnap = await _firestore
        .collection('users')
        .doc(uid)
        .collection('favourites')
        .get();

    if (favSnap.docs.isEmpty) return [];

    final amalIds = favSnap.docs.map((d) => d.id).toList();

    // Firestore `whereIn` supports at most 30 values per query.
    final amals = <AmalModel>[];
    for (var i = 0; i < amalIds.length; i += 30) {
      final batch = amalIds.sublist(
          i, i + 30 > amalIds.length ? amalIds.length : i + 30);
      final snap = await _firestore
          .collection('amals')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      amals.addAll(snap.docs.map(AmalModel.fromFirestore));
    }

    return amals;
  }

  // ── Private helpers ──────────────────────────────────────────────────────

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not authenticated.');
    return uid;
  }
}
