import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';

/// Manages all Noor Coin operations.
///
/// INVARIANT: This service NEVER writes directly to any Firestore wallet
/// field (noorCoinBalance, totalNoorCoinsEarned, wallet_transactions).
/// ALL mutations are delegated to Cloud Functions which use the Admin SDK
/// and therefore bypass Firestore security rules.
class WalletService {
  WalletService({
    FirebaseFunctions? functions,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFunctions _functions;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // ── Earn ──────────────────────────────────────────────────────────────────

  /// Award Noor Coins for a completed action.
  ///
  /// [source] must be one of the canonical source identifiers:
  ///   'prayer', 'fast', 'tasbeeh', 'soul_stack', 'ywtl'
  ///
  /// Calls the 'updateNoorWallet' Cloud Function, which atomically updates
  /// noorCoinBalance AND totalNoorCoinsEarned in the same Firestore
  /// transaction.
  Future<void> earnNoorCoins({
    required String source,
    required int amount,
  }) async {
    final uid = _requireUid();
    final callable =
        _functions.httpsCallable('updateNoorWallet');
    await callable.call<Map<String, dynamic>>({
      'uid': uid,
      'amount': amount,
      'source': source,
    });
  }

  // ── Spend ─────────────────────────────────────────────────────────────────

  /// Spend Noor Coins to unlock an asset.
  ///
  /// Calls the 'spendNoorCoins' Cloud Function, which atomically:
  ///   1. Deducts [amount] from noorCoinBalance (never from totalNoorCoinsEarned).
  ///   2. Unlocks [itemId] in users/{uid}/gardenAssets.
  ///
  /// Throws if the user has insufficient balance (Cloud Function validates).
  Future<void> spendNoorCoins({
    required int amount,
    required String itemId,
  }) async {
    final uid = _requireUid();
    final callable =
        _functions.httpsCallable('spendNoorCoins');
    await callable.call<Map<String, dynamic>>({
      'uid': uid,
      'amount': amount,
      'itemId': itemId,
    });
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Stream of the user's Noor Coin balance (read-only, server-authoritative).
  Stream<int> watchNoorCoinBalance() {
    final uid = _requireUid();
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snap) =>
            (snap.data()?['noorCoinBalance'] as num?)?.toInt() ?? 0);
  }

  /// Paginates wallet transaction history for the current user.
  Future<QuerySnapshot<Map<String, dynamic>>> fetchTransactionPage({
    DocumentSnapshot? startAfter,
    int pageSize = 20,
  }) {
    final uid = _requireUid();
    var query = _firestore
        .collection('users')
        .doc(uid)
        .collection('wallet_transactions')
        .orderBy('createdAt', descending: true)
        .limit(pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.get();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not authenticated.');
    return uid;
  }
}
