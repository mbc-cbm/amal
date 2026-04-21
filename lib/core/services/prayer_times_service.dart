import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/prayer_times_model.dart';
import '../utils/app_preferences.dart';

/// Fetches prayer times from the AlAdhan API and caches them locally
/// for up to 7 days per date so the app works fully offline.
///
/// AlAdhan API is free, requires no API key.
/// Docs: https://aladhan.com/prayer-times-api
class PrayerTimesService {
  static const _baseUrl = 'https://api.aladhan.com/v1';

  // ── Public API ────────────────────────────────────────────────────────────

  /// Returns prayer times for [date] using GPS coordinates.
  ///
  /// Tries cache first; fetches from API on cache miss or stale entry.
  /// Falls back to any cached data when offline.
  Future<PrayerTimes> getByCoordinates({
    required double lat,
    required double lng,
    required int methodId,
    DateTime? date,
  }) async {
    final target = date ?? DateTime.now();
    final dateKey = _dateKey(target);
    final locKey = _coordKey(lat, lng);

    // Check cache
    final cached = _readCache(dateKey, locKey, methodId);
    if (cached != null) return cached;

    // Fetch from API (full month for efficiency)
    try {
      final times = await _fetchMonthByCoords(
        lat: lat,
        lng: lng,
        methodId: methodId,
        year: target.year,
        month: target.month,
        locKey: locKey,
        locLabel: 'GPS',
      );
      // Return today's entry
      return times.firstWhere((t) => t.date == dateKey, orElse: () => times.first);
    } on SocketException {
      // Offline — return any cached entry for this date
      return _readCacheAny(dateKey) ??
          (throw Exception('No prayer times available. Connect to the internet to download times.'));
    }
  }

  /// Returns prayer times for [date] using a city + country name.
  Future<PrayerTimes> getByCity({
    required String city,
    required String country,
    required int methodId,
    DateTime? date,
  }) async {
    final target = date ?? DateTime.now();
    final dateKey = _dateKey(target);
    final locKey = _cityKey(city, country);

    final cached = _readCache(dateKey, locKey, methodId);
    if (cached != null) return cached;

    try {
      final times = await _fetchMonthByCity(
        city: city,
        country: country,
        methodId: methodId,
        year: target.year,
        month: target.month,
        locKey: locKey,
      );
      return times.firstWhere((t) => t.date == dateKey, orElse: () => times.first);
    } on SocketException {
      return _readCacheAny(dateKey) ??
          (throw Exception('No prayer times available. Connect to the internet to download times.'));
    }
  }

  /// Pre-fetches and caches prayer times for the next [days] days.
  /// Call this on app startup in the background.
  Future<void> prefetch({
    required bool useGps,
    required int methodId,
    double? lat,
    double? lng,
    String? city,
    String? country,
  }) async {
    final now = DateTime.now();
    // Determine which months we need (today + 6 days may span two months)
    final months = <({int year, int month})>{
      (year: now.year, month: now.month),
    };
    final endDate = now.add(const Duration(days: 6));
    if (endDate.month != now.month) {
      months.add((year: endDate.year, month: endDate.month));
    }

    for (final m in months) {
      try {
        if (useGps && lat != null && lng != null) {
          final locKey = _coordKey(lat, lng);
          await _fetchMonthByCoords(
            lat: lat,
            lng: lng,
            methodId: methodId,
            year: m.year,
            month: m.month,
            locKey: locKey,
            locLabel: 'GPS',
          );
        } else if (!useGps && city != null && country != null) {
          final locKey = _cityKey(city, country);
          await _fetchMonthByCity(
            city: city,
            country: country,
            methodId: methodId,
            year: m.year,
            month: m.month,
            locKey: locKey,
          );
        }
      } catch (_) {
        // Prefetch is best-effort; ignore errors
      }
    }
  }

  // ── Private: fetch ────────────────────────────────────────────────────────

  Future<List<PrayerTimes>> _fetchMonthByCoords({
    required double lat,
    required double lng,
    required int methodId,
    required int year,
    required int month,
    required String locKey,
    required String locLabel,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/calendar/$year/$month'
      '?latitude=$lat&longitude=$lng&method=$methodId',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    _checkStatus(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseCalendarResponse(
      body,
      locKey: locKey,
      locLabel: locLabel,
      methodId: methodId,
      year: year,
      month: month,
    );
  }

  Future<List<PrayerTimes>> _fetchMonthByCity({
    required String city,
    required String country,
    required int methodId,
    required int year,
    required int month,
    required String locKey,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/calendarByCity/$year/$month'
      '?city=${Uri.encodeComponent(city)}&country=${Uri.encodeComponent(country)}&method=$methodId',
    );
    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    _checkStatus(response);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    return _parseCalendarResponse(
      body,
      locKey: locKey,
      locLabel: '$city, $country',
      methodId: methodId,
      year: year,
      month: month,
    );
  }

  // ── Private: parsing ──────────────────────────────────────────────────────

  List<PrayerTimes> _parseCalendarResponse(
    Map<String, dynamic> body, {
    required String locKey,
    required String locLabel,
    required int methodId,
    required int year,
    required int month,
  }) {
    final data = body['data'] as List<dynamic>;
    final result = <PrayerTimes>[];
    final fetchedAt = DateTime.now();

    for (int i = 0; i < data.length; i++) {
      final dayData = data[i] as Map<String, dynamic>;
      final timings = dayData['timings'] as Map<String, dynamic>;

      final day = i + 1;
      final dateKey = '${year.toString().padLeft(4, '0')}-'
          '${month.toString().padLeft(2, '0')}-'
          '${day.toString().padLeft(2, '0')}';

      final times = PrayerTimes(
        date: dateKey,
        fajr: _parseTime(timings['Fajr'] as String, year, month, day),
        sunrise: _parseTime(timings['Sunrise'] as String, year, month, day),
        dhuhr: _parseTime(timings['Dhuhr'] as String, year, month, day),
        asr: _parseTime(timings['Asr'] as String, year, month, day),
        maghrib: _parseTime(timings['Maghrib'] as String, year, month, day),
        isha: _parseTime(timings['Isha'] as String, year, month, day),
        locationLabel: locLabel,
        locationKey: locKey,
        methodId: methodId,
        fetchedAt: fetchedAt,
      );
      result.add(times);
      _writeCache(dateKey, times);
    }

    // Store location + method for cache invalidation
    AppPreferences.instance.setPrayerCacheLocationKey(locKey);
    AppPreferences.instance.setPrayerCacheMethodId(methodId);

    return result;
  }

  /// Parses AlAdhan time string "HH:mm (TZ)" → DateTime for the given date.
  DateTime _parseTime(String raw, int year, int month, int day) {
    // Strip timezone abbreviation, e.g. "05:23 (BST)" → "05:23"
    final clean = raw.split(' ').first.trim();
    final parts = clean.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(year, month, day, hour, minute);
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode != 200) {
      throw Exception('AlAdhan API error ${response.statusCode}: ${response.body}');
    }
  }

  // ── Private: cache ────────────────────────────────────────────────────────

  void _writeCache(String dateKey, PrayerTimes times) {
    AppPreferences.instance.setPrayerTimesCache(dateKey, times.toJsonString());
  }

  /// Returns cached entry if it exists and is still valid.
  PrayerTimes? _readCache(String dateKey, String locKey, int methodId) {
    final json = AppPreferences.instance.getPrayerTimesCache(dateKey);
    if (json == null) return null;
    try {
      final times = PrayerTimes.fromJsonString(json);
      if (times.isValidFor(dateKey: dateKey, locationKey: locKey, methodId: methodId)) {
        return times;
      }
    } catch (_) {}
    return null;
  }

  /// Returns any cached entry for [dateKey], regardless of location/method.
  /// Used as offline fallback.
  PrayerTimes? _readCacheAny(String dateKey) {
    final json = AppPreferences.instance.getPrayerTimesCache(dateKey);
    if (json == null) return null;
    try {
      return PrayerTimes.fromJsonString(json);
    } catch (_) {
      return null;
    }
  }

  // ── Key helpers ───────────────────────────────────────────────────────────

  static String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  /// Rounds to ~11 km precision (2 decimal places) to improve cache hit rate.
  static String _coordKey(double lat, double lng) =>
      'g${lat.toStringAsFixed(2)}_${lng.toStringAsFixed(2)}';

  static String _cityKey(String city, String country) =>
      'c_${city.toLowerCase()}_${country.toLowerCase()}';

  // ── Utility: prayer day date ──────────────────────────────────────────────

  /// Returns the YYYY-MM-DD key for the current prayer day.
  ///
  /// The prayer day starts at Fajr, not midnight. Before Fajr we are still
  /// in the previous calendar day's prayer cycle.
  static String currentPrayerDateKey(DateTime? fajrToday) {
    final now = DateTime.now();
    if (fajrToday != null && now.isBefore(fajrToday)) {
      final yesterday = now.subtract(const Duration(days: 1));
      return _dateKey(yesterday);
    }
    return _dateKey(now);
  }
}
