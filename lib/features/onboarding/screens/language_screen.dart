import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_typography.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/app_preferences.dart';
import '../../../shared/widgets/amal_button.dart';
import '../providers/onboarding_provider.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key});

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  String? _selected;

  static const _languages = [
    (code: 'en', nativeName: 'English',  flag: '🇬🇧'),
    (code: 'bn', nativeName: 'বাংলা',    flag: '🇧🇩'),
    (code: 'ur', nativeName: 'اردو',     flag: '🇵🇰'),
    (code: 'ar', nativeName: 'العربية',  flag: '🇸🇦'),
  ];

  @override
  void initState() {
    super.initState();
    _selected = AppPreferences.instance.locale;
  }

  Future<void> _apply(String code) async {
    setState(() => _selected = code);
    ref.read(localeProvider.notifier).state = Locale(code);
    await AppPreferences.instance.setLocale(code);
    ref.read(onboardingProvider.notifier).setLanguage(code);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xxl),

              Text(
                l10n.selectLanguageTitle,
                style: AppTypography.headlineMedium.copyWith(color: cs.onSurface),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                l10n.selectLanguageSubtitle,
                style: AppTypography.bodyMedium.copyWith(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.xl),

              // ── Language cards ─────────────────────────────────────────
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppSpacing.md,
                  crossAxisSpacing: AppSpacing.md,
                  childAspectRatio: 1.3,
                  children: _languages.map((lang) {
                    final isSelected = _selected == lang.code;
                    final isRtl = lang.code == 'ar' || lang.code == 'ur';
                    return GestureDetector(
                      onTap: () => _apply(lang.code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryGreen.withAlpha(20)
                              : cs.surfaceContainerHighest,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGreen
                                : AppColors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(lang.flag, style: const TextStyle(fontSize: 32)),
                            const SizedBox(height: AppSpacing.sm),
                            Directionality(
                              textDirection: isRtl
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Text(
                                lang.nativeName,
                                style: AppTypography.titleMedium.copyWith(
                                  color: isSelected
                                      ? AppColors.primaryGreen
                                      : cs.onSurface,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                            if (isSelected) ...[
                              const SizedBox(height: AppSpacing.xs),
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.primaryGreen,
                                size: 18,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),
              AmalPrimaryButton(
                label: l10n.continueButton,
                onPressed: _selected == null
                    ? null
                    : () => context.go(AppRoutes.onboardingPrayerTradition),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
