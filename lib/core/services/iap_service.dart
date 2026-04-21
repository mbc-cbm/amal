import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Product IDs — must match App Store Connect and Google Play Console exactly.
abstract final class IapProductIds {
  // NC packages (consumable)
  static const ncStarter = 'com.amal.app.nc_starter';   // 1,000 NC  $0.35
  static const ncHandful = 'com.amal.app.nc_handful';   // 5,000 NC  $1.25
  static const ncGarden  = 'com.amal.app.nc_garden';    // 10,000 NC $2.49
  static const ncHarvest = 'com.amal.app.nc_harvest';   // 25,000 NC $4.99

  // Hayat (consumable)
  static const hayatDrop  = 'com.amal.app.hayat_drop';  // $0.50
  static const hayatBloom = 'com.amal.app.hayat_bloom';  // $1.50

  // Subscription (managed separately in profile/subscription screen)
  static const premiumMonthly = 'com.amal.app.premium_monthly';
  static const premiumAnnual  = 'com.amal.app.premium_annual';

  static const List<String> allConsumables = [
    ncStarter, ncHandful, ncGarden, ncHarvest,
    hayatDrop, hayatBloom,
  ];
}

/// In-App Purchase service.
///
/// NOTE: in_app_purchase package temporarily disabled due to native assets
/// build issue on Flutter 3.41.6 / macOS 26. This stub provides the same
/// API surface so all calling code compiles. Re-enable when Flutter patches
/// the native assets build system.
class IapService {
  IapService({
    FirebaseFunctions? functions,
    FirebaseAuth? auth,
  })  : _functions = functions ?? FirebaseFunctions.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  bool get isAvailable => false;

  /// Optional callback for showing errors to the user.
  void Function(String message)? onError;

  /// Optional callback for notifying the UI of a successful purchase.
  void Function(String productId)? onPurchaseSuccess;

  Future<void> initialize() async {
    debugPrint('IapService: Stub mode — in_app_purchase disabled for this build.');
  }

  Future<void> buyProduct(String productId) async {
    debugPrint('IapService: buyProduct($productId) — stub, IAP disabled.');
    onError?.call('In-app purchases coming soon.');
  }

  String priceForProduct(String productId, {String fallback = ''}) {
    return fallback;
  }

  void dispose() {}
}
