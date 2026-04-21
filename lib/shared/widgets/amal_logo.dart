import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';

/// Placeholder logo widget — replace with real SVG asset when available.
/// Uses the Arabic letter ع (first letter of عمل / Amal) in a gold circle.
class AmalLogo extends StatelessWidget {
  const AmalLogo({super.key, this.size = 80});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.primaryGold,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'ع',
          style: AppTypography.arabicBody.copyWith(
            fontSize: size * 0.48,
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Horizontal wordmark: logo + "Amal" text side by side.
class AmalWordmark extends StatelessWidget {
  const AmalWordmark({super.key, this.size = 48, this.light = false});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final textColor = light ? AppColors.white : AppColors.primaryGreen;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AmalLogo(size: size),
        SizedBox(width: size * 0.2),
        Text(
          'Amal',
          style: AppTypography.headlineLarge.copyWith(
            color: textColor,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
