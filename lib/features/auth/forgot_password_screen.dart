import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/providers/auth_provider.dart';
import '../../shared/widgets/amal_button.dart';
import '../../shared/widgets/amal_text_field.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _linkSent = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);
      await authService.sendPasswordResetEmail(_emailController.text.trim());
      if (mounted) {
        setState(() {
          _isLoading = false;
          _linkSent = true;
        });
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _isLoading = false;
          _errorMessage = l10n.resetLinkError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.forgotPasswordTitle),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: _linkSent ? _buildSuccess(l10n, cs) : _buildForm(l10n, cs),
        ),
      ),
    );
  }

  Widget _buildForm(AppLocalizations l10n, ColorScheme cs) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Icon(
            Icons.lock_reset_rounded,
            size: 64,
            color: AppColors.primaryGreen,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            l10n.forgotPasswordSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: cs.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          AmalTextField(
            controller: _emailController,
            label: l10n.emailLabel,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.errorInvalidEmail;
              }
              if (!value.contains('@')) {
                return l10n.errorInvalidEmail;
              }
              return null;
            },
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                _errorMessage!,
                style: AppTypography.bodySmall.copyWith(
                  color: cs.onErrorContainer,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          AmalPrimaryButton(
            label: l10n.sendResetLink,
            isLoading: _isLoading,
            onPressed: _sendResetLink,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(AppLocalizations l10n, ColorScheme cs) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.mark_email_read_rounded,
          size: 80,
          color: AppColors.primaryGreen,
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          l10n.resetLinkSent,
          style: AppTypography.titleMedium.copyWith(
            color: cs.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xl),
        AmalPrimaryButton(
          label: l10n.signIn,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
