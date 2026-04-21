import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/l10n/app_localizations.dart';
import '../../features/amal_gallery/amal_gallery_screen.dart';
import 'favourites_tab.dart';
import 'tracker_dashboard.dart';

// ── Main Amal Tracker shell with bottom navigation ─────────────────────────

class AmalTrackerScreen extends ConsumerStatefulWidget {
  const AmalTrackerScreen({super.key});

  @override
  ConsumerState<AmalTrackerScreen> createState() => _AmalTrackerScreenState();
}

class _AmalTrackerScreenState extends ConsumerState<AmalTrackerScreen> {
  int _currentIndex = 1; // Default to "My Tracker"

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          AmalGalleryScreen(),
          TrackerDashboard(),
          FavouritesTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        backgroundColor: cs.surface,
        selectedItemColor: AppColors.primaryGreen,
        unselectedItemColor: cs.onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: AppSpacing.cardElevation,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.grid_view_rounded),
            label: l10n.amalGallery,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.track_changes_rounded),
            label: l10n.trackerMyTracker,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite_rounded),
            label: l10n.trackerFavourites,
          ),
        ],
      ),
    );
  }
}
