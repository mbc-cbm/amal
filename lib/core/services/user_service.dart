import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

/// Handles Firestore user document reads and non-wallet field updates.
///
/// INVARIANT: This service NEVER writes noorCoinBalance or totalNoorCoinsEarned.
/// Those fields are written exclusively by Cloud Functions.
class UserService {
  UserService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<DocumentSnapshot<Map<String, dynamic>>> fetchCurrentUser() {
    final uid = _requireUid();
    return _users.doc(uid).get();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> watchCurrentUser() {
    final uid = _requireUid();
    return _users.doc(uid).snapshots();
  }

  // ── Profile update ────────────────────────────────────────────────────────

  /// Updates safe (non-wallet) profile fields on the user document
  /// and syncs them to the Firebase Auth profile.
  Future<void> updateProfile({
    String? name,
    String? photoUrl,
    String? language,
    bool? notificationsEnabled,
    bool? biometricEnabled,
  }) async {
    final uid = _requireUid();
    final updates = <String, dynamic>{
      'lastActiveAt': FieldValue.serverTimestamp(),
      'name': ?name,
      'photoUrl': ?photoUrl,
      'language': ?language,
      'notificationsEnabled': ?notificationsEnabled,
      'biometricEnabled': ?biometricEnabled,
    };

    await _users.doc(uid).update(updates);

    // Mirror to Firebase Auth profile
    if (name != null || photoUrl != null) {
      await _auth.currentUser?.updateDisplayName(name);
      if (photoUrl != null) await _auth.currentUser?.updatePhotoURL(photoUrl);
    }
  }

  /// Uploads a profile image to Firebase Storage and returns its download URL.
  Future<String> uploadProfilePhoto(File imageFile) async {
    final uid = _requireUid();
    final ref = _storage.ref('profile_photos/$uid.jpg');
    await ref.putFile(imageFile);
    return ref.getDownloadURL();
  }

  // ── Onboarding setup ──────────────────────────────────────────────────────

  /// Saves prayer tradition + calculation method to the user document.
  Future<void> savePrayerPreferences({
    required String tradition,
    required String calculationMethod,
  }) async {
    final uid = _requireUid();
    await _users.doc(uid).update({
      'prayerTradition': tradition,
      'calculationMethod': calculationMethod,
      'lastActiveAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Soft delete ───────────────────────────────────────────────────────────

  /// Marks the user as soft-deleted. A scheduled Cloud Function permanently
  /// deletes the document 60 days after [deletedAt].
  Future<void> requestAccountDeletion() async {
    final uid = _requireUid();
    await _users.doc(uid).update({
      'isDeleted': true,
      'deletedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Restores a soft-deleted account (within the 60-day window).
  Future<void> restoreAccount() async {
    final uid = _requireUid();
    await _users.doc(uid).update({
      'isDeleted': false,
      'deletedAt': null,
    });
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _requireUid() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('User is not authenticated.');
    return uid;
  }
}
