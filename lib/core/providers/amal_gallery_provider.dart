import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/amal_model.dart';
import '../services/amal_gallery_service.dart';

// ── Service provider ──────────────────────────────────────────────────────

final amalGalleryServiceProvider =
    Provider<AmalGalleryService>((_) => AmalGalleryService());

// ── Amals list ────────────────────────────────────────────────────────────

/// Parameter record for [amalsProvider].
typedef AmalsFilter = ({AmalCategory? category, String? search, String locale});

/// Fetches scholar-reviewed amals, optionally filtered by category and search.
final amalsProvider =
    FutureProvider.family<List<AmalModel>, AmalsFilter>((ref, filter) {
  final svc = ref.read(amalGalleryServiceProvider);
  return svc.fetchAmals(
    category: filter.category,
    searchQuery: filter.search,
    locale: filter.locale,
  );
});

// ── Single amal detail ────────────────────────────────────────────────────

/// Fetches a single amal by its Firestore document ID.
final amalDetailProvider =
    FutureProvider.family<AmalModel, String>((ref, amalId) {
  final svc = ref.read(amalGalleryServiceProvider);
  return svc.fetchAmalById(amalId);
});

// ── Favourites ────────────────────────────────────────────────────────────

/// Live stream of the current user's favourite amal IDs.
final favouriteAmalIdsProvider = StreamProvider<Set<String>>((ref) {
  final svc = ref.read(amalGalleryServiceProvider);
  return svc.watchFavourites();
});

// ── Completion counts ─────────────────────────────────────────────────────

/// Parameter record for [amalCompletionCountProvider].
typedef AmalCountFilter = ({String amalId, String period});

/// Returns the completion count for an amal within a given period.
final amalCompletionCountProvider =
    FutureProvider.family<int, AmalCountFilter>((ref, filter) {
  final svc = ref.read(amalGalleryServiceProvider);
  return svc.fetchCompletionCount(filter.amalId, period: filter.period);
});
