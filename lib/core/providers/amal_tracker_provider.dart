import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/amal_model.dart';
import '../services/amal_tracker_service.dart';

// ── Service provider ────────────────────────────────────────────────────────

final amalTrackerServiceProvider =
    Provider<AmalTrackerService>((_) => AmalTrackerService());

// ── Tracker stats ───────────────────────────────────────────────────────────

/// Live stream of the current user's streak and tracker statistics.
final trackerStatsProvider = StreamProvider<AmalTrackerStats>((ref) {
  final svc = ref.read(amalTrackerServiceProvider);
  return svc.watchTrackerStats();
});

// ── Recent completions ──────────────────────────────────────────────────────

/// Fetches the most recent amal completions for the current user.
final recentCompletionsProvider =
    FutureProvider<List<AmalCompletion>>((ref) {
  final svc = ref.read(amalTrackerServiceProvider);
  return svc.fetchRecentCompletions();
});

// ── Amal of the Day ─────────────────────────────────────────────────────────

/// Fetches the featured amal for today.
final amalOfTheDayProvider = FutureProvider<AmalModel>((ref) {
  final svc = ref.read(amalTrackerServiceProvider);
  return svc.fetchAmalOfTheDay();
});

// ── Daily goal ──────────────────────────────────────────────────────────────

/// Reads the user's daily amal goal (nullable).
final dailyGoalProvider = FutureProvider<int?>((ref) {
  final svc = ref.read(amalTrackerServiceProvider);
  return svc.fetchDailyGoal();
});

// ── Today's completion count ────────────────────────────────────────────────

/// Counts how many amals the current user completed today.
final todayCompletionCountProvider = FutureProvider<int>((ref) {
  final svc = ref.read(amalTrackerServiceProvider);
  return svc.fetchTodayCompletionCount();
});

// ── Favourite amals ─────────────────────────────────────────────────────────

/// Fetches full AmalModel objects for the user's favourited amals.
final favouriteAmalsProvider = FutureProvider<List<AmalModel>>((ref) {
  final svc = ref.read(amalTrackerServiceProvider);
  return svc.fetchFavouriteAmals();
});
