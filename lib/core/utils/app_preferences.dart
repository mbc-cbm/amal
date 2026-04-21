import 'package:shared_preferences/shared_preferences.dart';

/// Thin synchronous wrapper around SharedPreferences.
/// Must be initialized via [AppPreferences.initialize()] in main()
/// before any call to [AppPreferences.instance].
class AppPreferences {
  AppPreferences._(this._prefs);

  static AppPreferences? _instance;

  static AppPreferences get instance {
    assert(_instance != null,
        'AppPreferences.initialize() must be called before accessing instance.');
    return _instance!;
  }

  static Future<void> initialize() async {
    _instance = AppPreferences._(await SharedPreferences.getInstance());
  }

  final SharedPreferences _prefs;

  // ── Onboarding ────────────────────────────────────────────────────────────
  bool get onboardingComplete => _prefs.getBool('onboardingComplete') ?? false;
  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool('onboardingComplete', value);

  // ── Locale ────────────────────────────────────────────────────────────────
  String get locale => _prefs.getString('locale') ?? 'en';
  Future<void> setLocale(String locale) => _prefs.setString('locale', locale);

  // ── Biometric ─────────────────────────────────────────────────────────────
  bool get biometricEnabled => _prefs.getBool('biometricEnabled') ?? false;
  Future<void> setBiometricEnabled(bool value) =>
      _prefs.setBool('biometricEnabled', value);

  // ── App lock ──────────────────────────────────────────────────────────────
  bool get appLocked => _prefs.getBool('appLocked') ?? false;
  Future<void> setAppLocked(bool value) => _prefs.setBool('appLocked', value);

  // ── Prayer location ───────────────────────────────────────────────────────
  /// Whether to use GPS for prayer times (true) or city fallback (false).
  bool get prayerUseGps => _prefs.getBool('prayer_use_gps') ?? true;
  Future<void> setPrayerUseGps(bool value) =>
      _prefs.setBool('prayer_use_gps', value);

  double? get prayerLastLat => _prefs.getDouble('prayer_last_lat');
  double? get prayerLastLng => _prefs.getDouble('prayer_last_lng');
  Future<void> setPrayerLastCoords(double lat, double lng) async {
    await _prefs.setDouble('prayer_last_lat', lat);
    await _prefs.setDouble('prayer_last_lng', lng);
  }

  String? get prayerCity => _prefs.getString('prayer_city');
  String? get prayerCountry => _prefs.getString('prayer_country');
  Future<void> setPrayerCity(String city, String country) async {
    await _prefs.setString('prayer_city', city);
    await _prefs.setString('prayer_country', country);
  }

  // ── Prayer times cache ────────────────────────────────────────────────────
  /// Returns cached prayer times JSON for [dateKey] (format: YYYY-MM-DD),
  /// or null if not cached.
  String? getPrayerTimesCache(String dateKey) =>
      _prefs.getString('pt_$dateKey');

  Future<void> setPrayerTimesCache(String dateKey, String json) =>
      _prefs.setString('pt_$dateKey', json);

  Future<void> removePrayerTimesCache(String dateKey) =>
      _prefs.remove('pt_$dateKey');

  /// Remove all cached prayer times (e.g. when location/method changes).
  Future<void> clearPrayerTimesCache() async {
    final keys = _prefs.getKeys().where((k) => k.startsWith('pt_')).toList();
    for (final k in keys) {
      await _prefs.remove(k);
    }
  }

  /// Stored location key used for cache invalidation.
  String? get prayerCacheLocationKey =>
      _prefs.getString('prayer_cache_location_key');
  Future<void> setPrayerCacheLocationKey(String key) =>
      _prefs.setString('prayer_cache_location_key', key);

  /// Stored method ID used for cache invalidation.
  int? get prayerCacheMethodId => _prefs.getInt('prayer_cache_method_id');
  Future<void> setPrayerCacheMethodId(int id) =>
      _prefs.setInt('prayer_cache_method_id', id);

  // ── Garden ────────────────────────────────────────────────────────────────

  /// Garden grid state stored as JSON.
  String? get gardenGridJson => _prefs.getString('garden_grid');
  Future<void> setGardenGridJson(String json) =>
      _prefs.setString('garden_grid', json);

  /// Whether the user has dismissed the garden warning dialog.
  bool get gardenWarningSeen => _prefs.getBool('garden_warning_seen') ?? false;
  Future<void> setGardenWarningSeen() =>
      _prefs.setBool('garden_warning_seen', true);

  /// Outer garden visit counter for explainer screen.
  int get outerGardenVisitCount =>
      _prefs.getInt('outer_garden_visit_count') ?? 0;
  Future<void> incrementOuterGardenVisitCount() =>
      _prefs.setInt('outer_garden_visit_count', outerGardenVisitCount + 1);

  // ── Theme mode ────────────────────────────────────────────────────────────
  /// 'light', 'dark', or 'system'
  String get themeMode => _prefs.getString('theme_mode') ?? 'system';
  Future<void> setThemeMode(String mode) => _prefs.setString('theme_mode', mode);

  // ── Haptic feedback ───────────────────────────────────────────────────────
  bool get hapticEnabled => _prefs.getBool('haptic_enabled') ?? true;
  Future<void> setHapticEnabled(bool value) =>
      _prefs.setBool('haptic_enabled', value);

  // ── Sound effects ─────────────────────────────────────────────────────────
  bool get soundEnabled => _prefs.getBool('sound_enabled') ?? true;
  Future<void> setSoundEnabled(bool value) =>
      _prefs.setBool('sound_enabled', value);

  // ── Soul Stack reminder times ─────────────────────────────────────────────
  bool get soulStackRiseEnabled => _prefs.getBool('ss_rise_enabled') ?? true;
  Future<void> setSoulStackRiseEnabled(bool value) =>
      _prefs.setBool('ss_rise_enabled', value);

  int get soulStackRiseHour => _prefs.getInt('ss_rise_hour') ?? 6;
  int get soulStackRiseMinute => _prefs.getInt('ss_rise_minute') ?? 0;
  Future<void> setSoulStackRiseTime(int hour, int minute) async {
    await _prefs.setInt('ss_rise_hour', hour);
    await _prefs.setInt('ss_rise_minute', minute);
  }

  bool get soulStackShineEnabled => _prefs.getBool('ss_shine_enabled') ?? true;
  Future<void> setSoulStackShineEnabled(bool value) =>
      _prefs.setBool('ss_shine_enabled', value);

  int get soulStackShineHour => _prefs.getInt('ss_shine_hour') ?? 13;
  int get soulStackShineMinute => _prefs.getInt('ss_shine_minute') ?? 0;
  Future<void> setSoulStackShineTime(int hour, int minute) async {
    await _prefs.setInt('ss_shine_hour', hour);
    await _prefs.setInt('ss_shine_minute', minute);
  }

  bool get soulStackGlowEnabled => _prefs.getBool('ss_glow_enabled') ?? true;
  Future<void> setSoulStackGlowEnabled(bool value) =>
      _prefs.setBool('ss_glow_enabled', value);

  int get soulStackGlowHour => _prefs.getInt('ss_glow_hour') ?? 20;
  int get soulStackGlowMinute => _prefs.getInt('ss_glow_minute') ?? 0;
  Future<void> setSoulStackGlowTime(int hour, int minute) async {
    await _prefs.setInt('ss_glow_hour', hour);
    await _prefs.setInt('ss_glow_minute', minute);
  }

  // ── YWTL reminder ─────────────────────────────────────────────────────────
  bool get ywtlReminderEnabled => _prefs.getBool('ywtl_reminder_enabled') ?? true;
  Future<void> setYwtlReminderEnabled(bool value) =>
      _prefs.setBool('ywtl_reminder_enabled', value);

  int get ywtlReminderHour => _prefs.getInt('ywtl_reminder_hour') ?? 9;
  int get ywtlReminderMinute => _prefs.getInt('ywtl_reminder_minute') ?? 0;
  Future<void> setYwtlReminderTime(int hour, int minute) async {
    await _prefs.setInt('ywtl_reminder_hour', hour);
    await _prefs.setInt('ywtl_reminder_minute', minute);
  }

  // ── Streak at risk reminder ───────────────────────────────────────────────
  bool get streakAtRiskEnabled => _prefs.getBool('streak_at_risk_enabled') ?? true;
  Future<void> setStreakAtRiskEnabled(bool value) =>
      _prefs.setBool('streak_at_risk_enabled', value);

  // ── Asset fading warning ──────────────────────────────────────────────────
  bool get assetFadingEnabled => _prefs.getBool('asset_fading_enabled') ?? true;
  Future<void> setAssetFadingEnabled(bool value) =>
      _prefs.setBool('asset_fading_enabled', value);

  // ── Azan audio preference ─────────────────────────────────────────────────
  String get azanAudio => _prefs.getString('azan_audio') ?? 'makkah';
  Future<void> setAzanAudio(String value) =>
      _prefs.setString('azan_audio', value);
}
