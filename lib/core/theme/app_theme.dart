import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(Brightness.light);
  static ThemeData get dark => _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primaryGreen,
      onPrimary: AppColors.white,
      primaryContainer: isDark
          ? const Color(0xFF1E4A2A)
          : const Color(0xFFB7DFC6),
      onPrimaryContainer: isDark ? AppColors.creamWhite : AppColors.primaryGreen,
      secondary: AppColors.primaryGold,
      onSecondary: AppColors.white,
      secondaryContainer: isDark
          ? const Color(0xFF3D2F00)
          : const Color(0xFFF5E6B2),
      onSecondaryContainer: isDark ? AppColors.primaryGold : const Color(0xFF4A3800),
      tertiary: isDark
          ? const Color(0xFF6ABFB0)
          : const Color(0xFF1A6B5A),
      onTertiary: AppColors.white,
      tertiaryContainer: isDark
          ? const Color(0xFF1A3D35)
          : const Color(0xFFB2E0D6),
      onTertiaryContainer: isDark
          ? const Color(0xFFB2E0D6)
          : const Color(0xFF0D3B30),
      surface: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      onSurface: isDark ? AppColors.onSurfaceDark : AppColors.onSurfaceLight,
      surfaceContainer: isDark
          ? const Color(0xFF1A231C)
          : const Color(0xFFF5EFE5),
      surfaceContainerHighest: isDark
          ? AppColors.surfaceVariantDark
          : AppColors.surfaceVariantLight,
      onSurfaceVariant: isDark
          ? AppColors.onSurfaceVariantDark
          : AppColors.onSurfaceVariantLight,
      error: AppColors.error,
      onError: AppColors.white,
      errorContainer: isDark
          ? const Color(0xFF3B0A0A)
          : const Color(0xFFF9DEDC),
      onErrorContainer: isDark
          ? const Color(0xFFF9DEDC)
          : const Color(0xFF410E0B),
      outline: isDark ? AppColors.dividerDark : AppColors.divider,
      outlineVariant: isDark
          ? const Color(0xFF2E3830)
          : const Color(0xFFDBD5CB),
      shadow: AppColors.black,
      scrim: AppColors.black,
      inverseSurface: isDark ? AppColors.surfaceLight : AppColors.surfaceDark,
      onInverseSurface: isDark ? AppColors.onSurfaceLight : AppColors.onSurfaceDark,
      inversePrimary: AppColors.primaryGold,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: AppSpacing.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size(double.infinity, 52),
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: AppTypography.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ).apply(
        bodyColor: colorScheme.onSurface,
        displayColor: colorScheme.onSurface,
      ),
    );
  }
}
