import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Writes a heartbeat to Firestore every 60 seconds while the app is open.
/// Used by aggregateRainfallIntensity to detect active users.
class HeartbeatService {
  HeartbeatService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  Timer? _timer;

  /// Start the heartbeat timer. Call once from app initialization.
  void start() {
    _timer?.cancel();
    // Write immediately on start
    _writeHeartbeat();
    // Then every 60 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      _writeHeartbeat();
    });
  }

  Future<void> _writeHeartbeat() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      await _firestore.collection('users').doc(uid).update({
        'lastHeartbeatAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('HeartbeatService: write failed: $e');
    }
  }

  /// Stop the heartbeat timer. Call on app dispose.
  void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
