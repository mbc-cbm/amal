import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/amal_model.dart';

// ── Data classes ─────────────────────────────────────────────────────────────

enum StackName { rise, shine, glow }

extension StackNameX on StackName {
  String get key => name; // 'rise', 'shine', 'glow'
}

class DailyStackContent {
  DailyStackContent({
    required this.videoAmalIds,
    required this.createdAt,
  });

  final List<String> videoAmalIds; // 5 amal IDs
  final DateTime createdAt;
}

class StackDayLog {
  StackDayLog({
    required this.completed,
    required this.count,
    this.firstCompletedAt,
  });

  final bool completed;
  final int count;
  final DateTime? firstCompletedAt;

  factory StackDayLog.empty() =>
      StackDayLog(completed: false, count: 0);

  factory StackDayLog.fromMap(Map<String, dynamic>? data) {
    if (data == null) return StackDayLog.empty();
    return StackDayLog(
      completed: data['completed'] as bool? ?? false,
      count: (data['count'] as num?)?.toInt() ?? 0,
      firstCompletedAt:
          (data['firstCompletedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class SoulStackDayStatus {
  SoulStackDayStatus({
    required this.rise,
    required this.shine,
    required this.glow,
  });

  final StackDayLog rise;
  final StackDayLog shine;
  final StackDayLog glow;
}

// ── Service ──────────────────────────────────────────────────────────────────

class SoulStackService {
  SoulStackService({
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

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not authenticated.');
    return uid;
  }

  static const _placeholderAmalIds = [
    'placeholder_amal_1',
    'placeholder_amal_2',
    'placeholder_amal_3',
    'placeholder_amal_4',
    'placeholder_amal_5',
  ];

  // ── fetchDailyStackContent ─────────────────────────────────────────────────

  /// Reads `dailyStacks/{YYYY-MM-DD}/{stack.key}`.
  /// Returns [DailyStackContent]. If the doc doesn't exist, returns a fallback
  /// with 5 placeholder amal IDs.
  Future<DailyStackContent> fetchDailyStackContent(StackName stack) async {
    final dateKey = _todayKey();
    final doc = await _firestore
        .collection('dailyStacks')
        .doc(dateKey)
        .collection(stack.key)
        .doc('content')
        .get();

    if (!doc.exists) {
      return DailyStackContent(
        videoAmalIds: List.unmodifiable(_placeholderAmalIds),
        createdAt: DateTime.now(),
      );
    }

    final data = doc.data()!;
    final ids = (data['videoAmalIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        List.unmodifiable(_placeholderAmalIds);

    return DailyStackContent(
      videoAmalIds: ids,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ── watchDayStatus ─────────────────────────────────────────────────────────

  /// Returns a live stream of [SoulStackDayStatus] from
  /// `users/{uid}/soulStackLog/{YYYY-MM-DD}`.
  Stream<SoulStackDayStatus> watchDayStatus() {
    final uid = _requireUid();
    final dateKey = _todayKey();

    return _firestore
        .collection('users')
        .doc(uid)
        .collection('soulStackLog')
        .doc(dateKey)
        .snapshots()
        .map((snap) {
      final data = snap.data() ?? {};
      return SoulStackDayStatus(
        rise: StackDayLog.fromMap(data['rise'] as Map<String, dynamic>?),
        shine: StackDayLog.fromMap(data['shine'] as Map<String, dynamic>?),
        glow: StackDayLog.fromMap(data['glow'] as Map<String, dynamic>?),
      );
    });
  }

  // ── completeStack ──────────────────────────────────────────────────────────

  /// Completes a soul stack:
  /// 1. Awards 25 000 Noor Coins via `updateNoorWallet`.
  /// 2. Extends garden access by 6 hours via `extendGardenAccess`.
  /// 3. Updates the day's stack log (increments count, sets completed, records
  ///    firstCompletedAt on first completion).
  ///
  /// Returns the new completion count for this stack.
  Future<int> completeStack(StackName stack) async {
    final uid = _requireUid();
    final dateKey = _todayKey();

    // 1. Award Noor Coins.
    await _functions
        .httpsCallable('updateNoorWallet')
        .call<Map<String, dynamic>>({
      'uid': uid,
      'amount': 25000,
      'source': 'soul_stack',
      'stackName': stack.key,
    });

    // 2. Extend garden access (legacy + new timer).
    await _functions
        .httpsCallable('extendGardenAccess')
        .call<Map<String, dynamic>>({
      'uid': uid,
      'hours': 6,
    });
    // Also update the new daily-capped timer.
    try {
      await _functions
          .httpsCallable('updateGardenAccessTimer')
          .call<Map<String, dynamic>>({
        'uid': uid,
        'hoursToAdd': 6,
      });
    } catch (_) {
      // Non-critical — legacy timer still works
    }

    // 3. Update soul stack log.
    final docRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('soulStackLog')
        .doc(dateKey);

    final snap = await docRef.get();
    final existing = snap.data() ?? {};
    final stackData =
        (existing[stack.key] as Map<String, dynamic>?) ?? {};

    final currentCount = (stackData['count'] as num?)?.toInt() ?? 0;
    final newCount = currentCount + 1;
    final isFirstCompletion = stackData['firstCompletedAt'] == null;

    final updateData = <String, dynamic>{
      '${stack.key}.completed': true,
      '${stack.key}.count': newCount,
    };

    if (isFirstCompletion) {
      updateData['${stack.key}.firstCompletedAt'] =
          FieldValue.serverTimestamp();
    }

    await docRef.set(updateData, SetOptions(merge: true));

    return newCount;
  }

  // ── fetchVideoAmals ────────────────────────────────────────────────────────

  /// Fetches the actual [AmalModel] objects for the given [amalIds].
  Future<List<AmalModel>> fetchVideoAmals(List<String> amalIds) async {
    if (amalIds.isEmpty) return [];

    final futures = amalIds.map((id) =>
        _firestore.collection('amals').doc(id).get());
    final docs = await Future.wait(futures);

    return docs
        .where((doc) => doc.exists)
        .map(AmalModel.fromFirestore)
        .toList();
  }
}
