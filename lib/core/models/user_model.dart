import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  const UserModel({
    required this.uid,
    required this.displayName,
    required this.email,
    required this.photoUrl,
    required this.noorCoinBalance,
    required this.totalNoorCoinsEarned,
    required this.preferredLocale,
    required this.createdAt,
    required this.gardenAccessExpiresAt,
  });

  final String uid;
  final String displayName;
  final String email;
  final String photoUrl;

  /// Current spendable balance. Server-authoritative — never write from client.
  final int noorCoinBalance;

  /// Lifetime earned total. Server-authoritative — never decrements.
  final int totalNoorCoinsEarned;

  final String preferredLocale; // 'en' | 'bn' | 'ur' | 'ar'
  final DateTime createdAt;
  final DateTime? gardenAccessExpiresAt;

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      displayName: data['displayName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      noorCoinBalance: (data['noorCoinBalance'] as num?)?.toInt() ?? 0,
      totalNoorCoinsEarned:
          (data['totalNoorCoinsEarned'] as num?)?.toInt() ?? 0,
      preferredLocale: data['preferredLocale'] as String? ?? 'en',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      gardenAccessExpiresAt:
          (data['gardenAccessExpiresAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'displayName': displayName,
        'email': email,
        'photoUrl': photoUrl,
        'preferredLocale': preferredLocale,
        'createdAt': Timestamp.fromDate(createdAt),
        if (gardenAccessExpiresAt != null)
          'gardenAccessExpiresAt':
              Timestamp.fromDate(gardenAccessExpiresAt!),
        // NOTE: noorCoinBalance and totalNoorCoinsEarned are NEVER written
        // from client code. They are managed exclusively by Cloud Functions.
      };

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? preferredLocale,
    DateTime? gardenAccessExpiresAt,
  }) =>
      UserModel(
        uid: uid,
        displayName: displayName ?? this.displayName,
        email: email,
        photoUrl: photoUrl ?? this.photoUrl,
        noorCoinBalance: noorCoinBalance,
        totalNoorCoinsEarned: totalNoorCoinsEarned,
        preferredLocale: preferredLocale ?? this.preferredLocale,
        createdAt: createdAt,
        gardenAccessExpiresAt:
            gardenAccessExpiresAt ?? this.gardenAccessExpiresAt,
      );
}
