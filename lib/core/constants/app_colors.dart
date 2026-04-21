import 'package:flutter/material.dart';

/// All color design tokens for Amal.
/// Raw hex values MUST NOT appear anywhere outside this file.
abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────────────────────
  static const Color primaryGreen = Color(0xFF1B6B3A);
  static const Color primaryGold = Color(0xFFC9A84C);
  static const Color creamWhite = Color(0xFFFFF8F0);

  // ── Light theme surfaces ───────────────────────────────────────────────────
  static const Color surfaceLight = Color(0xFFFFF8F0);
  static const Color surfaceVariantLight = Color(0xFFF0EBE1);
  static const Color backgroundLight = Color(0xFFFAF6F0);
  static const Color onSurfaceLight = Color(0xFF1A1A1A);
  static const Color onSurfaceVariantLight = Color(0xFF5A5A5A);

  // ── Dark theme surfaces ────────────────────────────────────────────────────
  static const Color surfaceDark = Color(0xFF121A14);
  static const Color surfaceVariantDark = Color(0xFF1E2820);
  static const Color backgroundDark = Color(0xFF0D1510);
  static const Color onSurfaceDark = Color(0xFFF0EDE8);
  static const Color onSurfaceVariantDark = Color(0xFFADADAD);

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFB71C1C);
  static const Color info = Color(0xFF0277BD);

  // ── Noor Coin accent ──────────────────────────────────────────────────────
  static const Color noorGold = Color(0xFFD4AF37);
  static const Color noorGoldLight = Color(0xFFF5E27A);

  // ── Garden ────────────────────────────────────────────────────────────────
  static const Color gardenGrass = Color(0xFF2E7D32);
  static const Color gardenSky = Color(0xFF87CEEB);
  static const Color gardenPath = Color(0xFFC8A96E);

  // ── Garden asset palette (Quranic Jannah-inspired) ────────────────────
  static const Color gardenGoldGlow = Color(0xFFFFE082);
  static const Color gardenPearl = Color(0xFFF5F0E8);
  static const Color gardenAquamarine = Color(0xFF80CBC4);
  static const Color gardenEmerald = Color(0xFF1B5E20);
  static const Color gardenIvory = Color(0xFFFFFFF0);
  static const Color gardenAmber = Color(0xFFFFB74D);
  static const Color gardenHoney = Color(0xFFE8A317);
  static const Color gardenMilk = Color(0xFFFFF8E1);
  static const Color gardenOpal = Color(0xFFE0D5C8);
  static const Color gardenCelestial = Color(0xFFFFF8DC);
  static const Color gardenTrunkBrown = Color(0xFF795548);
  static const Color gardenTrunkDark = Color(0xFF4E342E);
  static const Color gardenLeafDark = Color(0xFF33691E);
  static const Color gardenLeafLight = Color(0xFF8BC34A);
  static const Color gardenWaterGlow = Color(0xFFE0F7FA);
  static const Color gardenRuby = Color(0xFFD32F2F);
  static const Color gardenPurpleIridescent = Color(0xFF7B1FA2);
  static const Color gardenTeal = Color(0xFF00897B);
  static const Color gardenSilver = Color(0xFFE0E0E0);

  // ── Garden UI palette (shop, sheets, panels) ──────────────────────────
  static const Color gardenNightBg = Color(0xFF0D3B1A);
  static const Color gardenCardBg = Color(0xFF143D1E);
  static const Color gardenCardBorder = Color(0xFF1E5C2E);
  static const Color gardenSage = Color(0xFFB8C5A8);
  static const Color gardenWarmGold = Color(0xFFC9942A);
  static const Color gardenBrightGold = Color(0xFFE8C547);
  static const Color gardenDeepNight = Color(0xFF0A0A12);
  static const Color gardenGreenMedium = Color(0xFF66BB6A);
  static const Color gardenGoldBright = Color(0xFFFFE44D);
  static const Color gardenDarkGreen = Color(0xFF1A4D2E);
  static const Color gardenForestDark = Color(0xFF0A2414);
  static const Color gardenScrollParchment = Color(0xFFF5E6C8);
  static const Color gardenScrollTan = Color(0xFFEDD9A3);
  static const Color gardenPurpleDeep = Color(0xFF4A148C);
  static const Color gardenTealDark = Color(0xFF004D40);
  static const Color gardenOliveDark = Color(0xFF558B2F);
  static const Color gardenZone1A = Color(0xFF4CAF50);
  static const Color gardenSkyPurple = Color(0xFF1A1A3E);

  // ── Feature tile icons ─────────────────────────────────────────────────────
  static const Color featureTasbeeh = Color(0xFF6A1B9A);
  static const Color featureRamadan = Color(0xFF00838F);
  static const Color featureYwtl = Color(0xFFE65100);
  static const Color featureAmal = Color(0xFF1565C0);
  static const Color featureSettings = Color(0xFF546E7A);

  // ── Utility ───────────────────────────────────────────────────────────────
  static const Color transparent = Color(0x00000000);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color divider = Color(0x1F000000);
  static const Color dividerDark = Color(0x1FFFFFFF);
}
