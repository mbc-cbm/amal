import 'package:cloud_firestore/cloud_firestore.dart';
import 'prayer_times_model.dart';

/// A single prayer's completion record within a day's log.
class PrayerLogEntry {
  const PrayerLogEntry({
    required this.completed,
    this.completedAt,
    this.coinsAwarded = 0,
  });

  final bool completed;
  final DateTime? completedAt;
  final int coinsAwarded;

  factory PrayerLogEntry.fromMap(Map<String, dynamic> data) => PrayerLogEntry(
        completed: data['completed'] as bool? ?? false,
        completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
        coinsAwarded: (data['coinsAwarded'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toMap() => {
        'completed': completed,
        if (completedAt != null)
          'completedAt': Timestamp.fromDate(completedAt!),
        'coinsAwarded': coinsAwarded,
      };

  static const empty = PrayerLogEntry(completed: false, coinsAwarded: 0);
}

/// The full prayer log for a single day (Firestore doc: users/{uid}/prayerLog/{YYYY-MM-DD}).
class DayPrayerLog {
  const DayPrayerLog({
    required this.date,
    required this.entries,
  });

  /// YYYY-MM-DD of the prayer day (starts at Fajr, not midnight).
  final String date;

  /// Map from PrayerName to its log entry.
  final Map<PrayerName, PrayerLogEntry> entries;

  bool isCompleted(PrayerName prayer) =>
      entries[prayer]?.completed ?? false;

  PrayerLogEntry entryFor(PrayerName prayer) =>
      entries[prayer] ?? PrayerLogEntry.empty;

  int get completedCount =>
      entries.values.where((e) => e.completed).length;

  factory DayPrayerLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final entries = <PrayerName, PrayerLogEntry>{};
    for (final prayer in PrayerName.values) {
      final raw = data[prayer.key] as Map<String, dynamic>?;
      if (raw != null) {
        entries[prayer] = PrayerLogEntry.fromMap(raw);
      }
    }
    return DayPrayerLog(date: doc.id, entries: entries);
  }

  /// Empty log for [date] — all prayers incomplete.
  static DayPrayerLog empty(String date) =>
      DayPrayerLog(date: date, entries: {});
}
