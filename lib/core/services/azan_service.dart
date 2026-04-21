import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/prayer_times_model.dart';

/// Handles Azan audio playback and prayer-time local notification scheduling.
///
/// ## Azan audio licensing
/// The Azan audio files must be sourced with appropriate licensing before
/// uploading to Firebase Storage. Recommended sources:
///   - Recordings from Masjid al-Haram / Masjid an-Nabawi (widely broadcast
///     for non-commercial religious use).
///   - CC0 / royalty-free Islamic audio repositories.
/// Consult an IP lawyer if redistributing commercially. The app only
/// streams/plays; it does not redistribute the audio files themselves.
///
/// ## Platform setup required (one-time, outside Dart code)
/// **Android** — add to `android/app/src/main/AndroidManifest.xml`:
///   `<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>`
///   `<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>`
///   And declare the notification channel receiver inside `<application>`.
///
/// **iOS** — enable "Background Audio" + "Background Processing" capabilities
///   in Xcode → Runner → Signing & Capabilities.
class AzanService {
  AzanService() : _player = AudioPlayer();

  final AudioPlayer _player;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  // ── Firebase Storage Azan audio paths ─────────────────────────────────────
  // Upload your licensed recordings to Firebase Storage at these paths.
  // Use Firebase Storage download URLs or configure a CDN.
  static const String _sunniStandardAzanUrl =
      'gs://amal-app-production.appspot.com/azan/sunni_standard.mp3';
  static const String _sunniFajrAzanUrl =
      'gs://amal-app-production.appspot.com/azan/sunni_fajr.mp3';
  static const String _shiaStandardAzanUrl =
      'gs://amal-app-production.appspot.com/azan/shia_standard.mp3';
  static const String _shiaFajrAzanUrl =
      'gs://amal-app-production.appspot.com/azan/shia_fajr.mp3';

  // ── Initialise ────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _notifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  // ── Schedule notifications for a day's prayer times ───────────────────────

  /// Schedules (or re-schedules) local notifications for all prayers in
  /// [times], respecting the per-prayer [settings].
  ///
  /// Call this:
  ///   - On app startup when prayer times are loaded.
  ///   - Whenever the user changes notification settings.
  ///   - After midnight (to re-schedule for the new day).
  Future<void> schedulePrayerNotifications({
    required PrayerTimes times,
    required PrayerNotificationSettings settings,
    required String tradition, // 'sunni' | 'shia'
    required String Function(PrayerName) prayerLabel,
  }) async {
    await initialize();

    // Cancel existing scheduled notifications before re-scheduling
    await _notifications.cancelAll();

    for (final prayer in PrayerName.values) {
      final mode = settings.modeFor(prayer);
      if (mode == PrayerNotificationMode.silent) continue;

      final prayerTime = times.timeFor(prayer);
      if (prayerTime.isBefore(DateTime.now())) continue;

      final tzTime = tz.TZDateTime.from(prayerTime, tz.local);
      final label = prayerLabel(prayer);
      final isAzan = mode == PrayerNotificationMode.azan;
      final isFajr = prayer == PrayerName.fajr;

      await _notifications.zonedSchedule(
        _notificationId(prayer),
        label,
        isAzan ? 'Azan playing…' : 'It\'s time for $label',
        tzTime,
        NotificationDetails(
          android: AndroidNotificationDetails(
            isAzan ? 'azan_channel' : 'prayer_channel',
            isAzan ? 'Azan' : 'Prayer Reminders',
            channelDescription: isAzan
                ? 'Plays Azan audio at prayer time'
                : 'Silent prayer time reminders',
            importance: Importance.high,
            priority: Priority.high,
            playSound: false, // audio handled by audioplayers
            enableVibration: isAzan,
            // Payload carries the mode + tradition so we know to play Azan
            // when the notification is received/tapped
          ),
          iOS: const DarwinNotificationDetails(
            presentSound: false,
            presentAlert: true,
            presentBadge: false,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: '${prayer.key}|${isAzan ? 'azan' : 'notification'}|${isFajr ? 'fajr' : 'standard'}|$tradition',
      );
    }
  }

  Future<void> cancelAll() => _notifications.cancelAll();

  // ── In-app Azan playback ──────────────────────────────────────────────────

  /// Plays the appropriate Azan audio for [prayer] and [tradition].
  ///
  /// Streams from Firebase Storage. Requires internet on first play;
  /// audioplayers caches internally on subsequent plays.
  Future<void> playAzan({
    required PrayerName prayer,
    required String tradition,
  }) async {
    await _player.stop();
    final isFajr = prayer == PrayerName.fajr;
    final isShia = tradition == 'shia';

    final url = isShia
        ? (isFajr ? _shiaFajrAzanUrl : _shiaStandardAzanUrl)
        : (isFajr ? _sunniFajrAzanUrl : _sunniStandardAzanUrl);

    // Firebase Storage gs:// URLs must be converted to https download URLs.
    // Replace with actual HTTPS download URLs after uploading to Storage.
    // Example: https://storage.googleapis.com/amal-app-production.appspot.com/azan/sunni_standard.mp3
    final httpsUrl = url
        .replaceFirst('gs://amal-app-production.appspot.com/', 'https://storage.googleapis.com/amal-app-production.appspot.com/');

    await _player.play(UrlSource(httpsUrl));
  }

  Future<void> stopAzan() => _player.stop();

  void dispose() {
    _player.dispose();
  }

  // ── Private ───────────────────────────────────────────────────────────────

  /// Unique notification ID per prayer (stable across re-schedules).
  int _notificationId(PrayerName prayer) => prayer.index + 100;

  void _onNotificationTapped(NotificationResponse response) {
    final payload = response.payload;
    if (payload == null) return;

    // payload format: "prayerName|mode|fajrOrStandard|tradition"
    final parts = payload.split('|');
    if (parts.length < 4) return;

    final mode = parts[1];
    if (mode != 'azan') return;

    final isFajr = parts[2] == 'fajr';
    final tradition = parts[3];
    final prayer = isFajr ? PrayerName.fajr : PrayerName.dhuhr; // approximate

    playAzan(prayer: prayer, tradition: tradition);
  }
}
