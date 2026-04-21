import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/prayer_log_model.dart';
import '../models/prayer_times_model.dart';
import '../services/azan_service.dart';
import '../services/prayer_log_service.dart';
import '../services/prayer_times_service.dart';
import '../services/prayer_service.dart';
import '../utils/app_preferences.dart';

// ── Service providers ──────────────────────────────────────────────────────

final prayerTimesServiceProvider =
    Provider<PrayerTimesService>((_) => PrayerTimesService());

final prayerLogServiceProvider =
    Provider<PrayerLogService>((_) => PrayerLogService());

final azanServiceProvider = Provider<AzanService>((_) => AzanService());

final locationServiceProvider =
    Provider<PrayerService>((_) => PrayerService());

// ── Location state ─────────────────────────────────────────────────────────

/// Current device position. Null if permission denied or unavailable.
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final svc = ref.read(locationServiceProvider);
  final enabled = await svc.isLocationServiceEnabled();
  if (!enabled) return null;
  return svc.getCurrentPosition();
});

// ── Calculation method from Firestore ──────────────────────────────────────

/// Reads the user's calculationMethod from their Firestore document.
/// Falls back to 2 (ISNA) if not set.
final userCalculationMethodProvider = FutureProvider<int>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 2;
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  final raw = doc.data()?['calculationMethod'] as String?;
  return int.tryParse(raw ?? '') ?? 2;
});

/// Reads the user's prayer tradition ('sunni' | 'shia') from Firestore.
final userTraditionProvider = FutureProvider<String>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return 'sunni';
  final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.data()?['prayerTradition'] as String? ?? 'sunni';
});

// ── Today's prayer times ────────────────────────────────────────────────────

/// Loads today's prayer times, using GPS when available, city fallback otherwise.
/// Automatically caches the result; retries on network error with cached data.
final todayPrayerTimesProvider = FutureProvider<PrayerTimes>((ref) async {
  final svc = ref.read(prayerTimesServiceProvider);
  final methodAsync = ref.watch(userCalculationMethodProvider);
  final methodId = methodAsync.valueOrNull ?? 2;

  final prefs = AppPreferences.instance;

  if (prefs.prayerUseGps) {
    final posAsync = ref.watch(currentPositionProvider);
    final pos = posAsync.valueOrNull;
    if (pos != null) {
      await prefs.setPrayerLastCoords(pos.latitude, pos.longitude);
      return svc.getByCoordinates(
        lat: pos.latitude,
        lng: pos.longitude,
        methodId: methodId,
      );
    }
    // GPS failed — fall through to city or last-known coords
    final lastLat = prefs.prayerLastLat;
    final lastLng = prefs.prayerLastLng;
    if (lastLat != null && lastLng != null) {
      return svc.getByCoordinates(
        lat: lastLat,
        lng: lastLng,
        methodId: methodId,
      );
    }
  }

  // City fallback
  final city = prefs.prayerCity;
  final country = prefs.prayerCountry;
  if (city != null && country != null) {
    return svc.getByCity(city: city, country: country, methodId: methodId);
  }

  throw Exception('Location not available. Please set your city in Prayer settings.');
});

// ── Today's prayer log ─────────────────────────────────────────────────────

/// Live stream of today's prayer completion log.
/// The date key accounts for Fajr-based day reset.
final todayPrayerLogProvider = StreamProvider<DayPrayerLog>((ref) {
  final timesAsync = ref.watch(todayPrayerTimesProvider);
  final times = timesAsync.valueOrNull;

  final dateKey = PrayerTimesService.currentPrayerDateKey(times?.fajr);
  return ref.read(prayerLogServiceProvider).watchDayLog(dateKey);
});

// ── Next prayer ────────────────────────────────────────────────────────────

/// The next upcoming prayer (or null after Isha).
final nextPrayerProvider = Provider<PrayerName?>((ref) {
  final timesAsync = ref.watch(todayPrayerTimesProvider);
  final times = timesAsync.valueOrNull;
  if (times == null) return null;

  final now = DateTime.now();
  for (final prayer in PrayerName.values) {
    if (times.timeFor(prayer).isAfter(now)) return prayer;
  }
  return null; // past Isha
});

// ── Notification settings ──────────────────────────────────────────────────

final prayerNotificationSettingsProvider =
    StateNotifierProvider<PrayerNotificationSettingsNotifier,
        AsyncValue<PrayerNotificationSettings>>(
  (ref) => PrayerNotificationSettingsNotifier(
    ref.read(prayerLogServiceProvider),
  ),
);

class PrayerNotificationSettingsNotifier
    extends StateNotifier<AsyncValue<PrayerNotificationSettings>> {
  PrayerNotificationSettingsNotifier(this._logSvc)
      : super(const AsyncValue.loading()) {
    _load();
  }

  final PrayerLogService _logSvc;

  Future<void> _load() async {
    try {
      final settings = await _logSvc.fetchNotificationSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> setMode(PrayerName prayer, PrayerNotificationMode mode) async {
    final current = state.valueOrNull ?? PrayerNotificationSettings.defaults;
    final updated = current.copyWithPrayer(prayer, mode);
    state = AsyncValue.data(updated);
    await _logSvc.saveNotificationSettings(updated);
  }
}

// ── Prayer log action ──────────────────────────────────────────────────────

/// Notifier that handles tapping a prayer's completion checkbox.
final prayerLogActionProvider =
    StateNotifierProvider<PrayerLogActionNotifier, AsyncValue<void>>(
  (ref) => PrayerLogActionNotifier(
    ref.read(prayerLogServiceProvider),
  ),
);

class PrayerLogActionNotifier extends StateNotifier<AsyncValue<void>> {
  PrayerLogActionNotifier(this._logSvc) : super(const AsyncValue.data(null));

  final PrayerLogService _logSvc;

  /// Marks [prayer] complete for [dateKey]. Returns coins awarded (0 if already done).
  Future<int> complete({
    required PrayerName prayer,
    required String dateKey,
  }) async {
    state = const AsyncValue.loading();
    try {
      final coins = await _logSvc.logPrayer(prayer: prayer, dateKey: dateKey);
      state = const AsyncValue.data(null);
      return coins;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
