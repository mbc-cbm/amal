import 'dart:convert';

/// The five fard prayers + Sunrise (display only, not tracked).
enum PrayerName { fajr, dhuhr, asr, maghrib, isha }

extension PrayerNameX on PrayerName {
  String get key => name; // 'fajr', 'dhuhr', etc.

  /// AlAdhan API response key for this prayer.
  String get apiKey {
    switch (this) {
      case PrayerName.fajr:
        return 'Fajr';
      case PrayerName.dhuhr:
        return 'Dhuhr';
      case PrayerName.asr:
        return 'Asr';
      case PrayerName.maghrib:
        return 'Maghrib';
      case PrayerName.isha:
        return 'Isha';
    }
  }

  static PrayerName? fromKey(String key) {
    for (final p in PrayerName.values) {
      if (p.key == key) return p;
    }
    return null;
  }
}

/// Per-prayer notification / Azan mode.
enum PrayerNotificationMode { silent, notification, azan }

extension PrayerNotificationModeX on PrayerNotificationMode {
  String get key => name;
  static PrayerNotificationMode fromKey(String key) {
    return PrayerNotificationMode.values.firstWhere(
      (m) => m.key == key,
      orElse: () => PrayerNotificationMode.notification,
    );
  }
}

/// Prayer times for a single day (all times in device-local DateTime).
class PrayerTimes {
  const PrayerTimes({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.locationLabel,
    required this.locationKey,
    required this.methodId,
    required this.fetchedAt,
  });

  /// YYYY-MM-DD
  final String date;
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;

  /// Human-readable location string shown in UI (e.g. "London, GB" or "GPS").
  final String locationLabel;

  /// Opaque key used for cache invalidation (changes when location changes).
  final String locationKey;

  final int methodId;
  final DateTime fetchedAt;

  /// Returns the DateTime for the given [prayer].
  DateTime timeFor(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return fajr;
      case PrayerName.dhuhr:
        return dhuhr;
      case PrayerName.asr:
        return asr;
      case PrayerName.maghrib:
        return maghrib;
      case PrayerName.isha:
        return isha;
    }
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'fajr': fajr.millisecondsSinceEpoch,
        'sunrise': sunrise.millisecondsSinceEpoch,
        'dhuhr': dhuhr.millisecondsSinceEpoch,
        'asr': asr.millisecondsSinceEpoch,
        'maghrib': maghrib.millisecondsSinceEpoch,
        'isha': isha.millisecondsSinceEpoch,
        'locationLabel': locationLabel,
        'locationKey': locationKey,
        'methodId': methodId,
        'fetchedAt': fetchedAt.millisecondsSinceEpoch,
      };

  factory PrayerTimes.fromJson(Map<String, dynamic> json) => PrayerTimes(
        date: json['date'] as String,
        fajr: DateTime.fromMillisecondsSinceEpoch(json['fajr'] as int),
        sunrise: DateTime.fromMillisecondsSinceEpoch(json['sunrise'] as int),
        dhuhr: DateTime.fromMillisecondsSinceEpoch(json['dhuhr'] as int),
        asr: DateTime.fromMillisecondsSinceEpoch(json['asr'] as int),
        maghrib: DateTime.fromMillisecondsSinceEpoch(json['maghrib'] as int),
        isha: DateTime.fromMillisecondsSinceEpoch(json['isha'] as int),
        locationLabel: json['locationLabel'] as String,
        locationKey: json['locationKey'] as String,
        methodId: json['methodId'] as int,
        fetchedAt:
            DateTime.fromMillisecondsSinceEpoch(json['fetchedAt'] as int),
      );

  String toJsonString() => jsonEncode(toJson());
  factory PrayerTimes.fromJsonString(String s) =>
      PrayerTimes.fromJson(jsonDecode(s) as Map<String, dynamic>);

  /// True if this cache entry is still valid for [today].
  ///
  /// Cache is valid when:
  /// - The date matches today's date key
  /// - The locationKey and methodId still match (not changed in settings)
  /// - fetchedAt is within 7 days (prevents stale data accumulation)
  bool isValidFor({
    required String dateKey,
    required String locationKey,
    required int methodId,
  }) {
    if (date != dateKey) return false;
    if (this.locationKey != locationKey) return false;
    if (this.methodId != methodId) return false;
    final age = DateTime.now().difference(fetchedAt);
    return age.inDays < 7;
  }
}

/// Notification mode settings for all five prayers.
class PrayerNotificationSettings {
  const PrayerNotificationSettings({
    this.fajr = PrayerNotificationMode.azan,
    this.dhuhr = PrayerNotificationMode.notification,
    this.asr = PrayerNotificationMode.notification,
    this.maghrib = PrayerNotificationMode.azan,
    this.isha = PrayerNotificationMode.azan,
  });

  final PrayerNotificationMode fajr;
  final PrayerNotificationMode dhuhr;
  final PrayerNotificationMode asr;
  final PrayerNotificationMode maghrib;
  final PrayerNotificationMode isha;

  PrayerNotificationMode modeFor(PrayerName prayer) {
    switch (prayer) {
      case PrayerName.fajr:
        return fajr;
      case PrayerName.dhuhr:
        return dhuhr;
      case PrayerName.asr:
        return asr;
      case PrayerName.maghrib:
        return maghrib;
      case PrayerName.isha:
        return isha;
    }
  }

  PrayerNotificationSettings copyWithPrayer(
    PrayerName prayer,
    PrayerNotificationMode mode,
  ) {
    return PrayerNotificationSettings(
      fajr: prayer == PrayerName.fajr ? mode : fajr,
      dhuhr: prayer == PrayerName.dhuhr ? mode : dhuhr,
      asr: prayer == PrayerName.asr ? mode : asr,
      maghrib: prayer == PrayerName.maghrib ? mode : maghrib,
      isha: prayer == PrayerName.isha ? mode : isha,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'fajr': fajr.key,
        'dhuhr': dhuhr.key,
        'asr': asr.key,
        'maghrib': maghrib.key,
        'isha': isha.key,
      };

  factory PrayerNotificationSettings.fromFirestore(Map<String, dynamic> data) {
    return PrayerNotificationSettings(
      fajr: PrayerNotificationModeX.fromKey(data['fajr'] as String? ?? 'azan'),
      dhuhr: PrayerNotificationModeX.fromKey(
          data['dhuhr'] as String? ?? 'notification'),
      asr: PrayerNotificationModeX.fromKey(
          data['asr'] as String? ?? 'notification'),
      maghrib:
          PrayerNotificationModeX.fromKey(data['maghrib'] as String? ?? 'azan'),
      isha:
          PrayerNotificationModeX.fromKey(data['isha'] as String? ?? 'azan'),
    );
  }

  static const defaults = PrayerNotificationSettings();
}
