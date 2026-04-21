import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Global navigator key used for deep-linking from notifications.
/// Set this from main.dart or app.dart if needed.
typedef DeepLinkHandler = void Function(String route);

/// Handles Firebase Cloud Messaging setup and incoming message routing.
class NotificationService {
  NotificationService({FirebaseMessaging? messaging})
      : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  /// Set this externally to enable deep-link navigation from notifications.
  static DeepLinkHandler? onDeepLink;

  /// Call this once during app bootstrap (after Firebase.initializeApp).
  Future<void> initialize() async {
    // Request permission (iOS requires explicit request; Android 13+ also).
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Save FCM token to Firestore for Cloud Function targeting.
    _saveFcmToken();
    _messaging.onTokenRefresh.listen((_) => _saveFcmToken());

    // Handle messages that open the app from a terminated state.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Handle messages when the app is in the foreground.
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps when app is in background (not terminated).
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  /// Returns the FCM token for this device, used to target push notifications.
  Future<String?> getDeviceToken() => _messaging.getToken();

  Future<void> _saveFcmToken() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final token = await _messaging.getToken();
      if (token == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'fcmToken': token});
    } catch (e) {
      debugPrint('NotificationService: Failed to save FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('NotificationService: Foreground message: ${message.data}');
    // Foreground messages are displayed by the system notification tray.
    // We don't need to show a custom banner for neglect/referral notifications.
  }

  void _handleMessage(RemoteMessage message) {
    final data = message.data;
    final deepLink = data['deepLink'] as String?;
    final type = data['type'] as String?;

    debugPrint('NotificationService: Handling message type=$type deepLink=$deepLink');

    if (deepLink != null && deepLink.isNotEmpty) {
      // Neglect states 4-5: auto-show Hayat sheet after 1.5s
      final level = int.tryParse(data['level'] ?? '') ?? 0;
      if (type == 'neglect' && level >= 4) {
        onDeepLink?.call('/jannah-garden/hayat');
      } else {
        onDeepLink?.call(deepLink);
      }
    }
  }
}
