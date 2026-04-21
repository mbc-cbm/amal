import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_preferences.dart';

/// Current app locale. Initialized from SharedPreferences.
/// Updating this immediately re-renders all localised widgets.
final localeProvider = StateProvider<Locale>((ref) {
  final saved = AppPreferences.instance.locale;
  return Locale(saved);
});
