import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ad_service.dart';
import '../services/soul_stack_service.dart';

// ── Service providers ────────────────────────────────────────────────────────

final soulStackServiceProvider =
    Provider<SoulStackService>((_) => SoulStackService());

final adServiceProvider = Provider<AdService>((_) => AdService());

// ── Day status stream ────────────────────────────────────────────────────────

/// Live stream of today's Soul Stack completion status for the current user.
final soulStackDayStatusProvider = StreamProvider<SoulStackDayStatus>((ref) {
  try {
    final svc = ref.read(soulStackServiceProvider);
    return svc.watchDayStatus().handleError((_) {
      // Return empty status on Firestore permission/missing doc errors
      return SoulStackDayStatus(
        rise: StackDayLog.empty(),
        shine: StackDayLog.empty(),
        glow: StackDayLog.empty(),
      );
    });
  } catch (_) {
    // User not authenticated yet
    return Stream.value(SoulStackDayStatus(
      rise: StackDayLog.empty(),
      shine: StackDayLog.empty(),
      glow: StackDayLog.empty(),
    ));
  }
});

// ── Daily stack content ──────────────────────────────────────────────────────

/// Fetches the daily stack content (5 video amal IDs) for a given [StackName].
final dailyStackContentProvider =
    FutureProvider.family<DailyStackContent, StackName>((ref, stack) {
  final svc = ref.read(soulStackServiceProvider);
  return svc.fetchDailyStackContent(stack);
});
