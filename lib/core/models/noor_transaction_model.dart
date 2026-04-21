import 'package:cloud_firestore/cloud_firestore.dart';

enum NoorTransactionType { earn, spend }

/// Represents a single Noor Coin transaction in
/// users/{uid}/wallet_transactions.
/// This sub-collection is written exclusively by Cloud Functions.
/// Clients have read-only access to their own transactions.
class NoorTransactionModel {
  const NoorTransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.source,
    required this.balanceAfter,
    required this.createdAt,
    this.itemId,
  });

  final String id;
  final NoorTransactionType type;

  /// Positive for earn, positive for spend (direction encoded by [type]).
  final int amount;

  /// Source identifier: e.g. 'prayer', 'fast', 'tasbeeh', 'soul_stack',
  /// 'ywtl', or itemId for spend transactions.
  final String source;

  /// Balance snapshot after this transaction — written by Cloud Function.
  final int balanceAfter;

  final DateTime createdAt;

  /// Present for spend transactions — the purchased asset ID.
  final String? itemId;

  factory NoorTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NoorTransactionModel(
      id: doc.id,
      type: (data['type'] as String?) == 'spend'
          ? NoorTransactionType.spend
          : NoorTransactionType.earn,
      amount: (data['amount'] as num?)?.toInt() ?? 0,
      source: data['source'] as String? ?? '',
      balanceAfter: (data['balanceAfter'] as num?)?.toInt() ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      itemId: data['itemId'] as String?,
    );
  }
}
