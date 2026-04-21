import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';

// ── Primary ───────────────────────────────────────────────────────────────
class AmalPrimaryButton extends StatelessWidget {
  const AmalPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: cs.primary,
          foregroundColor: cs.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: cs.onPrimary,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon!,
                      const SizedBox(width: AppSpacing.sm),
                      Text(label, style: AppTypography.labelLarge),
                    ],
                  )
                : Text(label, style: AppTypography.labelLarge),
      ),
    );
  }
}

// ── Outlined ──────────────────────────────────────────────────────────────
class AmalOutlinedButton extends StatelessWidget {
  const AmalOutlinedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: cs.onSurface,
          side: BorderSide(color: cs.outline),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: cs.primary,
                ),
              )
            : icon != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      icon!,
                      const SizedBox(width: AppSpacing.sm),
                      Text(label, style: AppTypography.labelLarge),
                    ],
                  )
                : Text(label, style: AppTypography.labelLarge),
      ),
    );
  }
}

// ── Gold / accent ─────────────────────────────────────────────────────────
class AmalGoldButton extends StatelessWidget {
  const AmalGoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

// ── Text button ───────────────────────────────────────────────────────────
class AmalTextButton extends StatelessWidget {
  const AmalTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.subtle = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onPressed,
      child: Text(
        label,
        style: AppTypography.labelLarge.copyWith(
          color: subtle ? cs.onSurfaceVariant : cs.primary,
        ),
      ),
    );
  }
}
