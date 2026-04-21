import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/services/firebase_service.dart';
import 'core/services/iap_service.dart';
import 'core/services/notification_service.dart';
import 'core/storage/garden_asset_hive.dart';
import 'core/storage/hive_boxes.dart';
import 'core/utils/app_preferences.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive before Firebase
  try {
    await Hive.initFlutter();
    Hive.registerAdapter(GardenAssetHiveAdapter());
    await Hive.openBox<GardenAssetHive>(HiveBoxes.gardenGrid);
    await Hive.openBox(HiveBoxes.gardenMeta);
    await Hive.openBox<bool>('firstPlacements');
  } catch (e) {
    debugPrint('Hive init failed: $e');
  }

  try {
    await FirebaseService.initialize()
        .timeout(const Duration(seconds: 10));
  } catch (e) {
    debugPrint('Firebase init failed or timed out: $e');
  }

  try {
    await AppPreferences.initialize()
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('AppPreferences init failed or timed out: $e');
  }

  try {
    await NotificationService().initialize()
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('Notification init failed or timed out: $e');
  }

  // Initialize IAP service (non-blocking)
  try {
    await IapService().initialize()
        .timeout(const Duration(seconds: 5));
  } catch (e) {
    debugPrint('IAP init failed or timed out: $e');
  }

  runApp(
    const ProviderScope(
      child: AmalApp(),
    ),
  );
}
