import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../constants/noor_coin_values.dart' show NoorCoinValues;
import '../models/prayer_log_model.dart';
import '../models/prayer_times_model.dart';

/// Manages the users/{uid}/prayerLog/{YYYY-MM-DD} Firestore collection.
///
/// Prayer completion is ALWAYS routed through the [logPrayer] method, which:
///   1. Calls the updateNoorWallet Cloud Function (awards coins + writes prayerLog atomically).
///   2. Is idempotent — the Cloud Function checks the log before awarding.
class PrayerLogService {
  PrayerLogService({
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

  /// Live stream of the prayer log for [dateKey] (YYYY-MM-DD).
  Stream<DayPrayerLog> watchDayLog(String dateKey) {
    final uid = _requireUid();
    return _logDoc(uid, dateKey).snapshots().map((snap) {
      if (!snap.exists) return DayPrayerLog.empty(dateKey);
      return DayPrayerLog.fromFirestore(snap);
    });
  }

  /// One-time fetch of the prayer log for [dateKey].
  Future<DayPrayerLog> fetchDayLog(String dateKey) async {
    final uid = _requireUid();
    final snap = await _logDoc(uid, dateKey).get();
    if (!snap.exists) return DayPrayerLog.empty(dateKey);
    return DayPrayerLog.fromFirestore(snap);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Marks [prayer] as complete for [dateKey].
  ///
  /// Calls the `updateNoorWallet` Cloud Function which atomically:
  ///   1. Checks whether this prayer is already logged (idempotency guard).
  ///   2. Awards [NoorCoinValues.kPrayerNoorCoins] Noor Coins.
  ///   3. Writes the prayerLog entry.
  ///
  /// Returns the coins awarded (300), or 0 if already logged (idempotent).
  ///
  /// Throws on network/auth error.
  Future<int> logPrayer({
    required PrayerName prayer,
    required String dateKey,
  }) async {
    final uid = _requireUid();

    final result = await _functions
        .httpsCallable('updateNoorWallet')
        .call<Map<String, dynamic>>({
      'uid': uid,
      'amount': NoorCoinValues.kPrayerNoorCoins,
      'source': 'prayer',
      'prayerName': prayer.key,
      'date': dateKey,
    });

    final data = result.data as Map<String, dynamic>? ?? {};
    // Cloud Function returns { alreadyLogged: true } when idempotent
    if (data['alreadyLogged'] == true) return 0;
    return NoorCoinValues.kPrayerNoorCoins;
  }

  // ── Notification settings ─────────────────────────────────────────────────

  /// Reads the per-prayer notification settings from the user document.
  Future<PrayerNotificationSettings> fetchNotificationSettings() async {
    final uid = _requireUid();
    final snap = await _firestore.collection('users').doc(uid).get();
    final data = snap.data()?['prayerSettings'] as Map<String, dynamic>?;
    if (data == null) return PrayerNotificationSettings.defaults;
    return PrayerNotificationSettings.fromFirestore(data);
  }

  /// Persists updated per-prayer notification settings to the user document.
  Future<void> saveNotificationSettings(
      PrayerNotificationSettings settings) async {
    final uid = _requireUid();
    await _firestore.collection('users').doc(uid).update({
      'prayerSettings': settings.toFirestore(),
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DocumentReference<Map<String, dynamic>> _logDoc(String uid, String dateKey) =>
      _firestore
          .collection('users')
          .doc(uid)
          .collection('prayerLog')
          .doc(dateKey);

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not authenticated.');
    return uid;
  }
}
